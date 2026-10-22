SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 11b & 13 - Chi tiết Phiếu Xuất Kho (XKR - Raw Data)
   Table: dbo.tbl_DM_Xuat_Kho_Raw_Data
   Ma_Bang: 124, VT: XKR, Ma_Chuc_Nang: 2223
   ========================================================= */


-- 1. List chi tiết theo Xuat_Kho_ID
CREATE OR ALTER PROCEDURE dbo.FQ_124_XKR_sp_sel_List_By_Xuat_Kho_ID
    @Xuat_Kho_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        raw.Auto_ID,
        raw.Xuat_Kho_ID,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Xuat,
        raw.Don_Gia_Xuat,
        (raw.SL_Xuat * raw.Don_Gia_Xuat) AS Tri_Gia,
        raw.deleted,
        raw.Created,
        raw.Created_By,
        raw.Created_By_Function,
        raw.Last_Updated,
        raw.Last_Updated_By,
        raw.Last_Updated_By_Function
    FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE raw.Xuat_Kho_ID = @Xuat_Kho_ID
      AND raw.deleted = 0
    ORDER BY raw.Auto_ID ASC;
END;
GO


-- 2. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_124_XKR_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        raw.Auto_ID,
        raw.Xuat_Kho_ID,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Xuat,
        raw.Don_Gia_Xuat,
        (raw.SL_Xuat * raw.Don_Gia_Xuat) AS Tri_Gia,
        raw.deleted,
        raw.Created,
        raw.Created_By,
        raw.Created_By_Function,
        raw.Last_Updated,
        raw.Last_Updated_By,
        raw.Last_Updated_By_Function
    FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE raw.Auto_ID = @Auto_ID
      AND raw.deleted = 0;
END;
GO


-- 3. Insert chi tiết phiếu xuất (Yêu cầu: Mã SP, SL, Đơn giá đầy đủ)
CREATE OR ALTER PROCEDURE dbo.FQ_124_XKR_sp_ins_Insert
    @Xuat_Kho_ID              bigint,
    @San_Pham_ID              bigint,
    @SL_Xuat                  float,
    @Don_Gia_Xuat             float,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF ISNULL(@Xuat_Kho_ID, 0) <= 0
        THROW 50001, N'Phiếu xuất kho không hợp lệ.', 1;

    IF ISNULL(@San_Pham_ID, 0) <= 0
        THROW 50002, N'Vui lòng chọn sản phẩm.', 1;

    IF ISNULL(@SL_Xuat, 0) <= 0
        THROW 50003, N'Số lượng xuất phải lớn hơn 0.', 1;

    IF ISNULL(@Don_Gia_Xuat, 0) < 0
        THROW 50004, N'Đơn giá xuất không được âm.', 1;

    DECLARE @Kho_ID bigint;
    DECLARE @Ngay_Xuat_Kho datetime;
    DECLARE @SL_Ton_Kho float;
    DECLARE @Kho_Lock_ID bigint;
    DECLARE @Auto_ID bigint;
    DECLARE @ErrorMessage nvarchar(2048);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @Kho_ID = xk.Kho_ID,
            @Ngay_Xuat_Kho = xk.Ngay_Xuat_Kho
        FROM dbo.tbl_DM_Xuat_Kho xk WITH (UPDLOCK, HOLDLOCK)
        WHERE xk.Auto_ID = @Xuat_Kho_ID
          AND xk.deleted = 0;

        IF @Kho_ID IS NULL
            THROW 50005, N'Phiếu xuất kho không tồn tại hoặc đã bị xóa.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.tbl_DM_San_Pham
            WHERE Auto_ID = @San_Pham_ID
              AND deleted = 0
        )
            THROW 50006, N'Sản phẩm không tồn tại hoặc đã bị xóa.', 1;

        SELECT @Kho_Lock_ID = Auto_ID
        FROM dbo.tbl_DM_Kho WITH (UPDLOCK, HOLDLOCK)
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0;

        IF @Kho_Lock_ID IS NULL
            THROW 50007, N'Kho của phiếu xuất không tồn tại hoặc đã bị xóa.', 1;

        SELECT @SL_Ton_Kho =
            ISNULL
            (
                (
                    SELECT SUM(raw.SL_Nhap)
                    FROM dbo.tbl_DM_Nhap_Kho_Raw_Data raw
                    INNER JOIN dbo.tbl_DM_Nhap_Kho nk
                        ON nk.Auto_ID = raw.Nhap_Kho_ID
                    WHERE raw.San_Pham_ID = @San_Pham_ID
                      AND raw.deleted = 0
                      AND nk.Kho_ID = @Kho_ID
                      AND nk.deleted = 0
                      AND nk.Ngay_Nhap_Kho < DATEADD(day, 1, CONVERT(date, @Ngay_Xuat_Kho))
                ),
                0
            )
            -
            ISNULL
            (
                (
                    SELECT SUM(raw.SL_Xuat)
                    FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw
                    INNER JOIN dbo.tbl_DM_Xuat_Kho xk
                        ON xk.Auto_ID = raw.Xuat_Kho_ID
                    WHERE raw.San_Pham_ID = @San_Pham_ID
                      AND raw.deleted = 0
                      AND xk.Kho_ID = @Kho_ID
                      AND xk.deleted = 0
                      AND xk.Ngay_Xuat_Kho < DATEADD(day, 1, CONVERT(date, @Ngay_Xuat_Kho))
                ),
                0
            );

        IF @SL_Xuat > @SL_Ton_Kho
        BEGIN
            SET @ErrorMessage = N'Tồn kho không đủ để xuất sản phẩm này. Tồn khả dụng tại ngày xuất: '
                + CONVERT(nvarchar(50), @SL_Ton_Kho) + N'.';
            THROW 50008, @ErrorMessage, 1;
        END;

        INSERT INTO dbo.tbl_DM_Xuat_Kho_Raw_Data
        (
            Xuat_Kho_ID,
            San_Pham_ID,
            SL_Xuat,
            Don_Gia_Xuat,
            deleted,
            Created,
            Created_By,
            Created_By_Function,
            Last_Updated,
            Last_Updated_By,
            Last_Updated_By_Function
        )
        VALUES
        (
            @Xuat_Kho_ID,
            @San_Pham_ID,
            @SL_Xuat,
            @Don_Gia_Xuat,
            0,
            GETDATE(),
            @Last_Updated_By,
            @Last_Updated_By_Function,
            GETDATE(),
            @Last_Updated_By,
            @Last_Updated_By_Function
        );

        SET @Auto_ID = CONVERT(bigint, SCOPE_IDENTITY());
        COMMIT TRANSACTION;

        SELECT @Auto_ID AS Auto_ID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- 4. Update chi tiết (Yêu cầu Bài 13: Chỉ sửa số lượng, đơn giá - không sửa mã sản phẩm)
CREATE OR ALTER PROCEDURE dbo.FQ_124_XKR_sp_upd_Update
    @Auto_ID                  bigint,
    @SL_Xuat                  float,
    @Don_Gia_Xuat             float,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF ISNULL(@SL_Xuat, 0) <= 0
        THROW 50001, N'Số lượng xuất phải lớn hơn 0.', 1;

    IF ISNULL(@Don_Gia_Xuat, 0) < 0
        THROW 50002, N'Đơn giá xuất không được âm.', 1;

    DECLARE @Xuat_Kho_ID bigint;
    DECLARE @San_Pham_ID bigint;
    DECLARE @Kho_ID bigint;
    DECLARE @Ngay_Xuat_Kho datetime;
    DECLARE @SL_Ton_Kho float;
    DECLARE @Kho_Lock_ID bigint;
    DECLARE @ErrorMessage nvarchar(2048);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @Xuat_Kho_ID = raw.Xuat_Kho_ID,
            @San_Pham_ID = raw.San_Pham_ID
        FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw
        WHERE raw.Auto_ID = @Auto_ID
          AND raw.deleted = 0;

        IF @Xuat_Kho_ID IS NULL
            THROW 50003, N'Không tìm thấy chi tiết phiếu xuất đang hoạt động.', 1;

        SELECT
            @Kho_ID = xk.Kho_ID,
            @Ngay_Xuat_Kho = xk.Ngay_Xuat_Kho
        FROM dbo.tbl_DM_Xuat_Kho xk WITH (UPDLOCK, HOLDLOCK)
        WHERE xk.Auto_ID = @Xuat_Kho_ID
          AND xk.deleted = 0;

        IF @Kho_ID IS NULL
            THROW 50004, N'Phiếu xuất kho không tồn tại hoặc đã bị xóa.', 1;

        SELECT @Kho_Lock_ID = Auto_ID
        FROM dbo.tbl_DM_Kho WITH (UPDLOCK, HOLDLOCK)
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0;

        IF @Kho_Lock_ID IS NULL
            THROW 50005, N'Kho của phiếu xuất không tồn tại hoặc đã bị xóa.', 1;

        DECLARE @Xuat_Kho_ID_Locked bigint;
        DECLARE @San_Pham_ID_Locked bigint;

        SELECT
            @Xuat_Kho_ID_Locked = raw.Xuat_Kho_ID,
            @San_Pham_ID_Locked = raw.San_Pham_ID
        FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (UPDLOCK, HOLDLOCK)
        WHERE raw.Auto_ID = @Auto_ID
          AND raw.deleted = 0;

        IF @Xuat_Kho_ID_Locked IS NULL
            THROW 50003, N'Không tìm thấy chi tiết phiếu xuất đang hoạt động.', 1;

        IF @Xuat_Kho_ID_Locked <> @Xuat_Kho_ID OR @San_Pham_ID_Locked <> @San_Pham_ID
            THROW 50007, N'Dữ liệu chi tiết đã thay đổi. Vui lòng tải lại phiếu xuất.', 1;

        SELECT @SL_Ton_Kho =
            ISNULL
            (
                (
                    SELECT SUM(raw.SL_Nhap)
                    FROM dbo.tbl_DM_Nhap_Kho_Raw_Data raw
                    INNER JOIN dbo.tbl_DM_Nhap_Kho nk
                        ON nk.Auto_ID = raw.Nhap_Kho_ID
                    WHERE raw.San_Pham_ID = @San_Pham_ID
                      AND raw.deleted = 0
                      AND nk.Kho_ID = @Kho_ID
                      AND nk.deleted = 0
                      AND nk.Ngay_Nhap_Kho < DATEADD(day, 1, CONVERT(date, @Ngay_Xuat_Kho))
                ),
                0
            )
            -
            ISNULL
            (
                (
                    SELECT SUM(raw.SL_Xuat)
                    FROM dbo.tbl_DM_Xuat_Kho_Raw_Data raw
                    INNER JOIN dbo.tbl_DM_Xuat_Kho xk
                        ON xk.Auto_ID = raw.Xuat_Kho_ID
                    WHERE raw.San_Pham_ID = @San_Pham_ID
                      AND raw.deleted = 0
                      AND raw.Auto_ID <> @Auto_ID
                      AND xk.Kho_ID = @Kho_ID
                      AND xk.deleted = 0
                      AND xk.Ngay_Xuat_Kho < DATEADD(day, 1, CONVERT(date, @Ngay_Xuat_Kho))
                ),
                0
            );

        IF @SL_Xuat > @SL_Ton_Kho
        BEGIN
            SET @ErrorMessage = N'Tồn kho không đủ để xuất sản phẩm này. Tồn khả dụng tại ngày xuất: '
                + CONVERT(nvarchar(50), @SL_Ton_Kho) + N'.';
            THROW 50006, @ErrorMessage, 1;
        END;

        UPDATE dbo.tbl_DM_Xuat_Kho_Raw_Data
        SET
            SL_Xuat = @SL_Xuat,
            Don_Gia_Xuat = @Don_Gia_Xuat,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50003, N'Không tìm thấy chi tiết phiếu xuất đang hoạt động.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- 5. Delete mềm chi tiết theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_124_XKR_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_Xuat_Kho_Raw_Data
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50004, N'Không tìm thấy chi tiết phiếu xuất đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @XK_ID bigint, @NK_ID bigint, @SP_ID bigint, @Kho_ID bigint, @NCC_ID bigint;
DECLARE @LSP_ID bigint, @DVT_ID bigint;
DECLARE @TestDate datetime = GETDATE();
DECLARE @TestToken nvarchar(36) = CONVERT(nvarchar(36), NEWID());

BEGIN TRY
    BEGIN TRANSACTION;

    -- Tạo phiếu và sản phẩm riêng để kiểm thử mà không phụ thuộc tồn kho sẵn có.
    SELECT TOP 1 @Kho_ID = Auto_ID FROM dbo.tbl_DM_Kho WHERE deleted = 0;
    IF @Kho_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created)
        VALUES (N'__Test Kho XKR ' + @TestToken + N'__', 0, GETDATE());
        SET @Kho_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @NCC_ID = Auto_ID FROM dbo.tbl_DM_NCC WHERE deleted = 0;
    IF @NCC_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_NCC (Ma_NCC, Ten_NCC, deleted, Created)
        VALUES (N'__TNCC_XKR_' + REPLACE(@TestToken, N'-', N''), N'__Test NCC XKR ' + @TestToken, 0, GETDATE());
        SET @NCC_ID = SCOPE_IDENTITY();
    END;

    INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created)
    VALUES (N'__TLSP_XKR_' + REPLACE(@TestToken, N'-', N''), N'__Test LSP XKR ' + @TestToken, 0, GETDATE());
    SET @LSP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created)
    VALUES (N'__Test DVT XKR ' + @TestToken, 0, GETDATE());
    SET @DVT_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_San_Pham (Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, deleted, Created)
    VALUES (N'__TSP_XKR_' + REPLACE(@TestToken, N'-', N''), N'__Test SP XKR ' + @TestToken, @LSP_ID, @DVT_ID, 0, GETDATE());
    SET @SP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, deleted, Created)
    VALUES (N'__TEST_PNK_XKR_' + REPLACE(@TestToken, N'-', N''), @Kho_ID, @NCC_ID, @TestDate, 0, GETDATE());
    SET @NK_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID, San_Pham_ID, SL_Nhap, Don_Gia_Nhap, deleted, Created)
    VALUES (@NK_ID, @SP_ID, 1000, 0, 0, GETDATE());

    INSERT INTO dbo.tbl_DM_Xuat_Kho (So_Phieu_Xuat_Kho, Kho_ID, Ngay_Xuat_Kho, deleted, Created)
    VALUES (N'__TEST_PXK_XKR_' + REPLACE(@TestToken, N'-', N''), @Kho_ID, @TestDate, 0, GETDATE());
    SET @XK_ID = SCOPE_IDENTITY();

    -- Insert chi tiết xuất
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_124_XKR_sp_ins_Insert
        @Xuat_Kho_ID = @XK_ID,
        @San_Pham_ID = @SP_ID,
        @SL_Xuat = 5,
        @Don_Gia_Xuat = 60000,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2223';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_124_XKR_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- List theo Xuat_Kho_ID
    EXEC dbo.FQ_124_XKR_sp_sel_List_By_Xuat_Kho_ID
        @Xuat_Kho_ID = @XK_ID;

    -- Update chỉ SL và Đơn giá (không đổi mã SP)
    EXEC dbo.FQ_124_XKR_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @SL_Xuat = 8,
        @Don_Gia_Xuat = 65000,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2223';

    -- Delete mềm
    EXEC dbo.FQ_124_XKR_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2223';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_124_XKR thành công (đã rollback, sạch dữ liệu).';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Kiểm tra danh sách SP đã tạo
SELECT name
FROM sys.procedures
WHERE name LIKE N'FQ[_]124[_]XKR[_]%'
ORDER BY name;

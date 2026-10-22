SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 11 & 12 - Quản lý Phiếu Xuất Kho (XK)
   Table: dbo.tbl_DM_Xuat_Kho
   Ma_Bang: 123, VT: XK, Ma_Chuc_Nang: 2221 (List), 2222 (Header Edit)
   ========================================================= */


-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_sel_List_By_Created
    @FromDate datetime = NULL,
    @ToDate   datetime = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FromDate IS NULL
        SET @FromDate = DATEADD(day, -30, GETDATE());

    IF @ToDate IS NULL
        SET @ToDate = GETDATE();

    SELECT
        xk.Auto_ID,
        xk.So_Phieu_Xuat_Kho,
        xk.Kho_ID,
        k.Ten_Kho,
        xk.Ngay_Xuat_Kho,
        xk.Ghi_Chu,
        xk.deleted,
        xk.Created,
        xk.Created_By,
        xk.Created_By_Function,
        xk.Last_Updated,
        xk.Last_Updated_By,
        xk.Last_Updated_By_Function
    FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON xk.Kho_ID = k.Auto_ID AND k.deleted = 0
    WHERE xk.deleted = 0
      AND xk.Ngay_Xuat_Kho >= @FromDate
      AND xk.Ngay_Xuat_Kho < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY xk.Ngay_Xuat_Kho DESC, xk.Auto_ID DESC;
END;
GO


-- 2. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        xk.Auto_ID,
        xk.So_Phieu_Xuat_Kho,
        xk.Kho_ID,
        k.Ten_Kho,
        xk.Ngay_Xuat_Kho,
        xk.Ghi_Chu,
        xk.deleted,
        xk.Created,
        xk.Created_By,
        xk.Created_By_Function,
        xk.Last_Updated,
        xk.Last_Updated_By,
        xk.Last_Updated_By_Function
    FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON xk.Kho_ID = k.Auto_ID AND k.deleted = 0
    WHERE xk.Auto_ID = @Auto_ID
      AND xk.deleted = 0;
END;
GO


-- 3. Insert
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_ins_Insert
    @So_Phieu_Xuat_Kho        nvarchar(100),
    @Kho_ID                   bigint,
    @Ngay_Xuat_Kho            datetime,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@So_Phieu_Xuat_Kho)), N'') IS NULL
        THROW 50001, N'Số phiếu xuất kho không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    IF @Ngay_Xuat_Kho IS NULL
        THROW 50003, N'Ngày xuất kho không được để trống.', 1;

    SET @So_Phieu_Xuat_Kho = LTRIM(RTRIM(@So_Phieu_Xuat_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0
    )
        THROW 50004, N'Kho không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Xuat_Kho
        WHERE deleted = 0
          AND So_Phieu_Xuat_Kho = @So_Phieu_Xuat_Kho
    )
        THROW 50005, N'Số phiếu xuất kho đã tồn tại.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Xuat_Kho
        (
            So_Phieu_Xuat_Kho,
            Kho_ID,
            Ngay_Xuat_Kho,
            Ghi_Chu,
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
            @So_Phieu_Xuat_Kho,
            @Kho_ID,
            @Ngay_Xuat_Kho,
            @Ghi_Chu,
            0,
            GETDATE(),
            @Last_Updated_By,
            @Last_Updated_By_Function,
            GETDATE(),
            @Last_Updated_By,
            @Last_Updated_By_Function
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50005, N'Số phiếu xuất kho đã tồn tại.', 1;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 4. Update (Bài 12: Hiệu chỉnh header phiếu xuất)
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_upd_Update
    @Auto_ID                  bigint,
    @So_Phieu_Xuat_Kho        nvarchar(100),
    @Kho_ID                   bigint,
    @Ngay_Xuat_Kho            datetime,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@So_Phieu_Xuat_Kho)), N'') IS NULL
        THROW 50001, N'Số phiếu xuất kho không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    IF @Ngay_Xuat_Kho IS NULL
        THROW 50003, N'Ngày xuất kho không được để trống.', 1;

    SET @So_Phieu_Xuat_Kho = LTRIM(RTRIM(@So_Phieu_Xuat_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Xuat_Kho
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50006, N'Không tìm thấy phiếu xuất kho đang hoạt động.', 1;

    -- Nếu phiếu đã có chi tiết → không cho đổi Kho hoặc Ngày xuất
    -- (đổi sẽ làm sai tồn kho đã kiểm tra khi thêm/sửa chi tiết)
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Xuat_Kho_Raw_Data
        WHERE Xuat_Kho_ID = @Auto_ID
          AND deleted = 0
    )
    AND EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Xuat_Kho
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
          AND (Kho_ID <> @Kho_ID OR CONVERT(date, Ngay_Xuat_Kho) <> CONVERT(date, @Ngay_Xuat_Kho))
    )
        THROW 50008, N'Phiếu xuất đã có chi tiết, không thể thay đổi Kho hoặc Ngày xuất kho. Vui lòng xóa hết chi tiết trước khi hiệu chỉnh.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0
    )
        THROW 50004, N'Kho không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Xuat_Kho
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND So_Phieu_Xuat_Kho = @So_Phieu_Xuat_Kho
    )
        THROW 50005, N'Số phiếu xuất kho đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Xuat_Kho
        SET
            So_Phieu_Xuat_Kho = @So_Phieu_Xuat_Kho,
            Kho_ID = @Kho_ID,
            Ngay_Xuat_Kho = @Ngay_Xuat_Kho,
            Ghi_Chu = @Ghi_Chu,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50006, N'Không tìm thấy phiếu xuất kho đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50005, N'Số phiếu xuất kho đã tồn tại.', 1;

        THROW;
    END CATCH;
END;
GO


-- 5. Delete mềm theo ID (Xóa phiếu và xóa mềm toàn bộ chi tiết xuất)
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Soft delete chi tiết xuất
        UPDATE dbo.tbl_DM_Xuat_Kho_Raw_Data
        SET
            deleted = 1,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Xuat_Kho_ID = @Auto_ID
          AND deleted = 0;

        -- Soft delete header
        UPDATE dbo.tbl_DM_Xuat_Kho
        SET
            deleted = 1,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50007, N'Không tìm thấy phiếu xuất kho đang hoạt động để xóa.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- 6. Dữ liệu in phiếu xuất (Bài 14: In phiếu xuất)
CREATE OR ALTER PROCEDURE dbo.FQ_123_XK_sp_sel_Report_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        xk.Auto_ID AS Xuat_Kho_ID,
        xk.So_Phieu_Xuat_Kho,
        xk.Ngay_Xuat_Kho,
        k.Ten_Kho,
        xk.Ghi_Chu AS Ghi_Chu_Header,
        raw.Auto_ID AS Raw_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Xuat,
        raw.Don_Gia_Xuat,
        (raw.SL_Xuat * raw.Don_Gia_Xuat) AS Tri_Gia
    FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON xk.Kho_ID = k.Auto_ID
    LEFT JOIN dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
        ON raw.Xuat_Kho_ID = xk.Auto_ID AND raw.deleted = 0
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID
    WHERE xk.Auto_ID = @Auto_ID
      AND xk.deleted = 0
    ORDER BY raw.Auto_ID ASC;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @Kho_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Lấy hoặc tạo Kho tạm
    SELECT TOP 1 @Kho_ID = Auto_ID FROM dbo.tbl_DM_Kho WHERE deleted = 0;
    IF @Kho_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho XK__', 0, GETDATE());
        SET @Kho_ID = SCOPE_IDENTITY();
    END;

    -- Insert phiếu xuất
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_123_XK_sp_ins_Insert
        @So_Phieu_Xuat_Kho = N'__TEST_PXK_CRUD__',
        @Kho_ID = @Kho_ID,
        @Ngay_Xuat_Kho = '2026-10-15',
        @Ghi_Chu = N'Test CRUD PXK',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2221';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_123_XK_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update header
    EXEC dbo.FQ_123_XK_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @So_Phieu_Xuat_Kho = N'__TEST_PXK_UPD__',
        @Kho_ID = @Kho_ID,
        @Ngay_Xuat_Kho = '2026-10-15',
        @Ghi_Chu = N'Test update PXK',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2222';

    -- List theo ngày
    EXEC dbo.FQ_123_XK_sp_sel_List_By_Created
        @FromDate = '2026-10-01',
        @ToDate = '2026-10-31';

    -- Dữ liệu in phiếu xuất
    EXEC dbo.FQ_123_XK_sp_sel_Report_By_ID
        @Auto_ID = @Auto_ID;

    -- Delete mềm
    EXEC dbo.FQ_123_XK_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2221';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_123_XK thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]123[_]XK[_]%'
ORDER BY name;

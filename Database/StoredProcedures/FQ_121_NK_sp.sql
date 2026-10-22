SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 7 & 8 - Quản lý Phiếu Nhập Kho (NK)
   Table: dbo.tbl_DM_Nhap_Kho
   Ma_Bang: 121, VT: NK, Ma_Chuc_Nang: 2211 (List), 2212 (Header Edit)
   ========================================================= */


-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_sel_List_By_Created
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
        nk.Auto_ID,
        nk.So_Phieu_Nhap_Kho,
        nk.Kho_ID,
        k.Ten_Kho,
        nk.NCC_ID,
        ncc.Ten_NCC,
        nk.Ngay_Nhap_Kho,
        nk.Ghi_Chu,
        nk.deleted,
        nk.Created,
        nk.Created_By,
        nk.Created_By_Function,
        nk.Last_Updated,
        nk.Last_Updated_By,
        nk.Last_Updated_By_Function
    FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON nk.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_DM_NCC ncc WITH (NOLOCK)
        ON nk.NCC_ID = ncc.Auto_ID AND ncc.deleted = 0
    WHERE nk.deleted = 0
      AND nk.Ngay_Nhap_Kho >= @FromDate
      AND nk.Ngay_Nhap_Kho < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY nk.Ngay_Nhap_Kho DESC, nk.Auto_ID DESC;
END;
GO


-- 2. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        nk.Auto_ID,
        nk.So_Phieu_Nhap_Kho,
        nk.Kho_ID,
        k.Ten_Kho,
        nk.NCC_ID,
        ncc.Ten_NCC,
        nk.Ngay_Nhap_Kho,
        nk.Ghi_Chu,
        nk.deleted,
        nk.Created,
        nk.Created_By,
        nk.Created_By_Function,
        nk.Last_Updated,
        nk.Last_Updated_By,
        nk.Last_Updated_By_Function
    FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON nk.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_DM_NCC ncc WITH (NOLOCK)
        ON nk.NCC_ID = ncc.Auto_ID AND ncc.deleted = 0
    WHERE nk.Auto_ID = @Auto_ID
      AND nk.deleted = 0;
END;
GO


-- 3. Insert
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_ins_Insert
    @So_Phieu_Nhap_Kho        nvarchar(100),
    @Kho_ID                   bigint,
    @NCC_ID                   bigint,
    @Ngay_Nhap_Kho            datetime,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@So_Phieu_Nhap_Kho)), N'') IS NULL
        THROW 50001, N'Số phiếu nhập kho không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    IF ISNULL(@NCC_ID, 0) <= 0
        THROW 50003, N'Nhà cung cấp không được để trống.', 1;

    IF @Ngay_Nhap_Kho IS NULL
        THROW 50004, N'Ngày nhập kho không được để trống.', 1;

    SET @So_Phieu_Nhap_Kho = LTRIM(RTRIM(@So_Phieu_Nhap_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0
    )
        THROW 50005, N'Kho không tồn tại hoặc đã bị xóa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_NCC
        WHERE Auto_ID = @NCC_ID
          AND deleted = 0
    )
        THROW 50006, N'Nhà cung cấp không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho
        WHERE deleted = 0
          AND So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho
    )
        THROW 50007, N'Số phiếu nhập kho đã tồn tại.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Nhap_Kho
        (
            So_Phieu_Nhap_Kho,
            Kho_ID,
            NCC_ID,
            Ngay_Nhap_Kho,
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
            @So_Phieu_Nhap_Kho,
            @Kho_ID,
            @NCC_ID,
            @Ngay_Nhap_Kho,
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
            THROW 50007, N'Số phiếu nhập kho đã tồn tại.', 1;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 4. Update (Bài 8: Hiệu chỉnh header phiếu nhập)
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_upd_Update
    @Auto_ID                  bigint,
    @So_Phieu_Nhap_Kho        nvarchar(100),
    @Kho_ID                   bigint,
    @NCC_ID                   bigint,
    @Ngay_Nhap_Kho            datetime,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@So_Phieu_Nhap_Kho)), N'') IS NULL
        THROW 50001, N'Số phiếu nhập kho không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    IF ISNULL(@NCC_ID, 0) <= 0
        THROW 50003, N'Nhà cung cấp không được để trống.', 1;

    IF @Ngay_Nhap_Kho IS NULL
        THROW 50004, N'Ngày nhập kho không được để trống.', 1;

    SET @So_Phieu_Nhap_Kho = LTRIM(RTRIM(@So_Phieu_Nhap_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50008, N'Không tìm thấy phiếu nhập kho đang hoạt động.', 1;

    -- Nếu phiếu đã có chi tiết → không cho đổi Kho hoặc Ngày nhập
    -- (đổi sẽ làm sai tồn kho của các phiếu xuất liên quan)
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho_Raw_Data
        WHERE Nhap_Kho_ID = @Auto_ID
          AND deleted = 0
    )
    AND EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
          AND (Kho_ID <> @Kho_ID OR CONVERT(date, Ngay_Nhap_Kho) <> CONVERT(date, @Ngay_Nhap_Kho))
    )
        THROW 50010, N'Phiếu nhập đã có chi tiết, không thể thay đổi Kho hoặc Ngày nhập kho. Vui lòng xóa hết chi tiết trước khi hiệu chỉnh.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE Auto_ID = @Kho_ID
          AND deleted = 0
    )
        THROW 50005, N'Kho không tồn tại hoặc đã bị xóa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_NCC
        WHERE Auto_ID = @NCC_ID
          AND deleted = 0
    )
        THROW 50006, N'Nhà cung cấp không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho
    )
        THROW 50007, N'Số phiếu nhập kho đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Nhap_Kho
        SET
            So_Phieu_Nhap_Kho = @So_Phieu_Nhap_Kho,
            Kho_ID = @Kho_ID,
            NCC_ID = @NCC_ID,
            Ngay_Nhap_Kho = @Ngay_Nhap_Kho,
            Ghi_Chu = @Ghi_Chu,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50008, N'Không tìm thấy phiếu nhập kho đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50007, N'Số phiếu nhập kho đã tồn tại.', 1;

        THROW;
    END CATCH;
END;
GO


-- 5. Delete mềm theo ID (Xóa phiếu và xóa mềm toàn bộ chi tiết)
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Soft delete chi tiết
        UPDATE dbo.tbl_DM_Nhap_Kho_Raw_Data
        SET
            deleted = 1,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Nhap_Kho_ID = @Auto_ID
          AND deleted = 0;

        -- Soft delete header
        UPDATE dbo.tbl_DM_Nhap_Kho
        SET
            deleted = 1,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50009, N'Không tìm thấy phiếu nhập kho đang hoạt động để xóa.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- 6. Dữ liệu in phiếu nhập (Bài 10: In phiếu nhập)
CREATE OR ALTER PROCEDURE dbo.FQ_121_NK_sp_sel_Report_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        nk.Auto_ID AS Nhap_Kho_ID,
        nk.So_Phieu_Nhap_Kho,
        nk.Ngay_Nhap_Kho,
        k.Ten_Kho,
        ncc.Ten_NCC,
        nk.Ghi_Chu AS Ghi_Chu_Header,
        raw.Auto_ID AS Raw_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Nhap,
        raw.Don_Gia_Nhap,
        (raw.SL_Nhap * raw.Don_Gia_Nhap) AS Tri_Gia
    FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON nk.Kho_ID = k.Auto_ID
    LEFT JOIN dbo.tbl_DM_NCC ncc WITH (NOLOCK)
        ON nk.NCC_ID = ncc.Auto_ID
    LEFT JOIN dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
        ON raw.Nhap_Kho_ID = nk.Auto_ID AND raw.deleted = 0
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID
    WHERE nk.Auto_ID = @Auto_ID
      AND nk.deleted = 0
    ORDER BY raw.Auto_ID ASC;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @Kho_ID bigint, @NCC_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Lấy hoặc tạo Kho và NCC tạm để test
    SELECT TOP 1 @Kho_ID = Auto_ID FROM dbo.tbl_DM_Kho WHERE deleted = 0;
    IF @Kho_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho NK__', 0, GETDATE());
        SET @Kho_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @NCC_ID = Auto_ID FROM dbo.tbl_DM_NCC WHERE deleted = 0;
    IF @NCC_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_NCC (Ma_NCC, Ten_NCC, deleted, Created) VALUES (N'__TEST_NCC_NK__', N'__Test NCC NK__', 0, GETDATE());
        SET @NCC_ID = SCOPE_IDENTITY();
    END;

    -- Insert phiếu nhập
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_121_NK_sp_ins_Insert
        @So_Phieu_Nhap_Kho = N'__TEST_PNK_CRUD__',
        @Kho_ID = @Kho_ID,
        @NCC_ID = @NCC_ID,
        @Ngay_Nhap_Kho = '2026-10-15',
        @Ghi_Chu = N'Test CRUD PNK',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2211';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_121_NK_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update header
    EXEC dbo.FQ_121_NK_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @So_Phieu_Nhap_Kho = N'__TEST_PNK_UPD__',
        @Kho_ID = @Kho_ID,
        @NCC_ID = @NCC_ID,
        @Ngay_Nhap_Kho = '2026-10-15',
        @Ghi_Chu = N'Test update PNK',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2212';

    -- List theo ngày
    EXEC dbo.FQ_121_NK_sp_sel_List_By_Created
        @FromDate = '2026-10-01',
        @ToDate = '2026-10-31';

    -- Dữ liệu in phiếu
    EXEC dbo.FQ_121_NK_sp_sel_Report_By_ID
        @Auto_ID = @Auto_ID;

    -- Delete mềm
    EXEC dbo.FQ_121_NK_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2211';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_121_NK thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]121[_]NK[_]%'
ORDER BY name;

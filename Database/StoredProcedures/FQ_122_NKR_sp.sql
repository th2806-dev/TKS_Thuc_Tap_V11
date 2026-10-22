SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 7b & 9 - Chi tiết Phiếu Nhập Kho (NKR - Raw Data)
   Table: dbo.tbl_DM_Nhap_Kho_Raw_Data
   Ma_Bang: 122, VT: NKR, Ma_Chuc_Nang: 2213
   ========================================================= */


-- 1. List chi tiết theo Nhap_Kho_ID
CREATE OR ALTER PROCEDURE dbo.FQ_122_NKR_sp_sel_List_By_Nhap_Kho_ID
    @Nhap_Kho_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        raw.Auto_ID,
        raw.Nhap_Kho_ID,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Nhap,
        raw.Don_Gia_Nhap,
        (raw.SL_Nhap * raw.Don_Gia_Nhap) AS Tri_Gia,
        raw.deleted,
        raw.Created,
        raw.Created_By,
        raw.Created_By_Function,
        raw.Last_Updated,
        raw.Last_Updated_By,
        raw.Last_Updated_By_Function
    FROM dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE raw.Nhap_Kho_ID = @Nhap_Kho_ID
      AND raw.deleted = 0
    ORDER BY raw.Auto_ID ASC;
END;
GO


-- 2. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_122_NKR_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        raw.Auto_ID,
        raw.Nhap_Kho_ID,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Nhap,
        raw.Don_Gia_Nhap,
        (raw.SL_Nhap * raw.Don_Gia_Nhap) AS Tri_Gia,
        raw.deleted,
        raw.Created,
        raw.Created_By,
        raw.Created_By_Function,
        raw.Last_Updated,
        raw.Last_Updated_By,
        raw.Last_Updated_By_Function
    FROM dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE raw.Auto_ID = @Auto_ID
      AND raw.deleted = 0;
END;
GO


-- 3. Insert chi tiết phiếu nhập (Yêu cầu: Mã SP, SL, Đơn giá đầy đủ)
CREATE OR ALTER PROCEDURE dbo.FQ_122_NKR_sp_ins_Insert
    @Nhap_Kho_ID              bigint,
    @San_Pham_ID              bigint,
    @SL_Nhap                  float,
    @Don_Gia_Nhap             float,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@Nhap_Kho_ID, 0) <= 0
        THROW 50001, N'Phiếu nhập kho không hợp lệ.', 1;

    IF ISNULL(@San_Pham_ID, 0) <= 0
        THROW 50002, N'Vui lòng chọn sản phẩm.', 1;

    IF ISNULL(@SL_Nhap, 0) <= 0
        THROW 50003, N'Số lượng nhập phải lớn hơn 0.', 1;

    IF ISNULL(@Don_Gia_Nhap, 0) < 0
        THROW 50004, N'Đơn giá nhập không được âm.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho
        WHERE Auto_ID = @Nhap_Kho_ID
          AND deleted = 0
    )
        THROW 50005, N'Phiếu nhập kho không tồn tại hoặc đã bị xóa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_San_Pham
        WHERE Auto_ID = @San_Pham_ID
          AND deleted = 0
    )
        THROW 50006, N'Sản phẩm không tồn tại hoặc đã bị xóa.', 1;

    INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data
    (
        Nhap_Kho_ID,
        San_Pham_ID,
        SL_Nhap,
        Don_Gia_Nhap,
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
        @Nhap_Kho_ID,
        @San_Pham_ID,
        @SL_Nhap,
        @Don_Gia_Nhap,
        0,
        GETDATE(),
        @Last_Updated_By,
        @Last_Updated_By_Function,
        GETDATE(),
        @Last_Updated_By,
        @Last_Updated_By_Function
    );

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 4. Update chi tiết (Yêu cầu Bài 9: Chỉ sửa số lượng, đơn giá - không sửa mã sản phẩm)
CREATE OR ALTER PROCEDURE dbo.FQ_122_NKR_sp_upd_Update
    @Auto_ID                  bigint,
    @SL_Nhap                  float,
    @Don_Gia_Nhap             float,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@SL_Nhap, 0) <= 0
        THROW 50001, N'Số lượng nhập phải lớn hơn 0.', 1;

    IF ISNULL(@Don_Gia_Nhap, 0) < 0
        THROW 50002, N'Đơn giá nhập không được âm.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Nhap_Kho_Raw_Data
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50003, N'Không tìm thấy chi tiết phiếu nhập đang hoạt động.', 1;

    UPDATE dbo.tbl_DM_Nhap_Kho_Raw_Data
    SET
        SL_Nhap = @SL_Nhap,
        Don_Gia_Nhap = @Don_Gia_Nhap,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50003, N'Không tìm thấy chi tiết phiếu nhập đang hoạt động.', 1;
END;
GO


-- 5. Delete mềm chi tiết theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_122_NKR_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_Nhap_Kho_Raw_Data
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50004, N'Không tìm thấy chi tiết phiếu nhập đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @NK_ID bigint, @SP_ID bigint, @Kho_ID bigint, @NCC_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Lấy hoặc tạo Kho, NCC, Nhập kho và Sản phẩm tạm
    SELECT TOP 1 @Kho_ID = Auto_ID FROM dbo.tbl_DM_Kho WHERE deleted = 0;
    IF @Kho_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho NKR__', 0, GETDATE());
        SET @Kho_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @NCC_ID = Auto_ID FROM dbo.tbl_DM_NCC WHERE deleted = 0;
    IF @NCC_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_NCC (Ma_NCC, Ten_NCC, deleted, Created) VALUES (N'__TEST_NCC_NKR__', N'__Test NCC NKR__', 0, GETDATE());
        SET @NCC_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @NK_ID = Auto_ID FROM dbo.tbl_DM_Nhap_Kho WHERE deleted = 0;
    IF @NK_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, deleted, Created)
        VALUES (N'__TEST_PNK_FOR_RAW__', @Kho_ID, @NCC_ID, GETDATE(), 0, GETDATE());
        SET @NK_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @SP_ID = Auto_ID FROM dbo.tbl_DM_San_Pham WHERE deleted = 0;
    IF @SP_ID IS NULL
    BEGIN
        DECLARE @LSP_ID bigint, @DVT_ID bigint;
        INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created) VALUES (N'__TLSP_NKR__', N'__TLSP__', 0, GETDATE());
        SET @LSP_ID = SCOPE_IDENTITY();
        INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created) VALUES (N'__TDVT_NKR__', 0, GETDATE());
        SET @DVT_ID = SCOPE_IDENTITY();

        INSERT INTO dbo.tbl_DM_San_Pham (Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, deleted, Created)
        VALUES (N'__TSP_NKR__', N'__Test SP NKR__', @LSP_ID, @DVT_ID, 0, GETDATE());
        SET @SP_ID = SCOPE_IDENTITY();
    END;

    -- Insert chi tiết
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_122_NKR_sp_ins_Insert
        @Nhap_Kho_ID = @NK_ID,
        @San_Pham_ID = @SP_ID,
        @SL_Nhap = 10,
        @Don_Gia_Nhap = 50000,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2213';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_122_NKR_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- List theo Nhap_Kho_ID
    EXEC dbo.FQ_122_NKR_sp_sel_List_By_Nhap_Kho_ID
        @Nhap_Kho_ID = @NK_ID;

    -- Update chỉ SL và Đơn giá (không đổi mã SP)
    EXEC dbo.FQ_122_NKR_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @SL_Nhap = 15,
        @Don_Gia_Nhap = 55000,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2213';

    -- Delete mềm
    EXEC dbo.FQ_122_NKR_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2213';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_122_NKR thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]122[_]NKR[_]%'
ORDER BY name;


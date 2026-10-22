SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 3 - Danh mục Sản phẩm (SP)
   Table: dbo.tbl_DM_San_Pham
   Ma_Bang: 113, VT: SP, Ma_Chuc_Nang: 2113
   ========================================================= */


-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_sel_List_By_Created
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
        sp.Auto_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        sp.Loai_San_Pham_ID,
        lsp.Ten_LSP AS Ten_Loai_San_Pham,
        sp.Don_Vi_Tinh_ID,
        dvt.Ten_Don_Vi_Tinh,
        sp.Ghi_Chu,
        sp.deleted,
        sp.Created,
        sp.Created_By,
        sp.Created_By_Function,
        sp.Last_Updated,
        sp.Last_Updated_By,
        sp.Last_Updated_By_Function
    FROM dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Loai_San_Pham lsp WITH (NOLOCK)
        ON sp.Loai_San_Pham_ID = lsp.Auto_ID AND lsp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE sp.deleted = 0
      AND sp.Created >= @FromDate
      AND sp.Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY sp.Created DESC;
END;
GO


-- 2. List cho cache
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_sel_List_For_Cache
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sp.Auto_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        sp.Loai_San_Pham_ID,
        lsp.Ten_LSP AS Ten_Loai_San_Pham,
        sp.Don_Vi_Tinh_ID,
        dvt.Ten_Don_Vi_Tinh,
        sp.Ghi_Chu,
        sp.deleted,
        sp.Created,
        sp.Created_By,
        sp.Created_By_Function,
        sp.Last_Updated,
        sp.Last_Updated_By,
        sp.Last_Updated_By_Function
    FROM dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Loai_San_Pham lsp WITH (NOLOCK)
        ON sp.Loai_San_Pham_ID = lsp.Auto_ID AND lsp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE sp.deleted = 0
    ORDER BY sp.Ten_San_Pham ASC;
END;
GO


-- 3. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sp.Auto_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        sp.Loai_San_Pham_ID,
        lsp.Ten_LSP AS Ten_Loai_San_Pham,
        sp.Don_Vi_Tinh_ID,
        dvt.Ten_Don_Vi_Tinh,
        sp.Ghi_Chu,
        sp.deleted,
        sp.Created,
        sp.Created_By,
        sp.Created_By_Function,
        sp.Last_Updated,
        sp.Last_Updated_By,
        sp.Last_Updated_By_Function
    FROM dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Loai_San_Pham lsp WITH (NOLOCK)
        ON sp.Loai_San_Pham_ID = lsp.Auto_ID AND lsp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE sp.Auto_ID = @Auto_ID
      AND sp.deleted = 0;
END;
GO


-- 4. Insert
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_ins_Insert
    @Ma_San_Pham              nvarchar(100),
    @Ten_San_Pham             nvarchar(400),
    @Loai_San_Pham_ID         bigint,
    @Don_Vi_Tinh_ID           bigint,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_San_Pham)), N'') IS NULL
        THROW 50001, N'Mã sản phẩm không được để trống.', 1;

    IF NULLIF(LTRIM(RTRIM(@Ten_San_Pham)), N'') IS NULL
        THROW 50002, N'Tên sản phẩm không được để trống.', 1;

    IF ISNULL(@Loai_San_Pham_ID, 0) <= 0
        THROW 50003, N'Loại sản phẩm không được để trống.', 1;

    IF ISNULL(@Don_Vi_Tinh_ID, 0) <= 0
        THROW 50004, N'Đơn vị tính không được để trống.', 1;

    SET @Ma_San_Pham = LTRIM(RTRIM(@Ma_San_Pham));
    SET @Ten_San_Pham = LTRIM(RTRIM(@Ten_San_Pham));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE Auto_ID = @Loai_San_Pham_ID
          AND deleted = 0
    )
        THROW 50005, N'Loại sản phẩm không tồn tại hoặc đã bị xóa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Don_Vi_Tinh
        WHERE Auto_ID = @Don_Vi_Tinh_ID
          AND deleted = 0
    )
        THROW 50006, N'Đơn vị tính không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_San_Pham
        WHERE deleted = 0
          AND Ma_San_Pham = @Ma_San_Pham
    )
        THROW 50007, N'Mã sản phẩm đã tồn tại.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_San_Pham
        (
            Ma_San_Pham,
            Ten_San_Pham,
            Loai_San_Pham_ID,
            Don_Vi_Tinh_ID,
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
            @Ma_San_Pham,
            @Ten_San_Pham,
            @Loai_San_Pham_ID,
            @Don_Vi_Tinh_ID,
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
            THROW 50007, N'Mã sản phẩm đã tồn tại.', 1;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 5. Update
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_upd_Update
    @Auto_ID                  bigint,
    @Ma_San_Pham              nvarchar(100),
    @Ten_San_Pham             nvarchar(400),
    @Loai_San_Pham_ID         bigint,
    @Don_Vi_Tinh_ID           bigint,
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_San_Pham)), N'') IS NULL
        THROW 50001, N'Mã sản phẩm không được để trống.', 1;

    IF NULLIF(LTRIM(RTRIM(@Ten_San_Pham)), N'') IS NULL
        THROW 50002, N'Tên sản phẩm không được để trống.', 1;

    IF ISNULL(@Loai_San_Pham_ID, 0) <= 0
        THROW 50003, N'Loại sản phẩm không được để trống.', 1;

    IF ISNULL(@Don_Vi_Tinh_ID, 0) <= 0
        THROW 50004, N'Đơn vị tính không được để trống.', 1;

    SET @Ma_San_Pham = LTRIM(RTRIM(@Ma_San_Pham));
    SET @Ten_San_Pham = LTRIM(RTRIM(@Ten_San_Pham));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_San_Pham
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50008, N'Không tìm thấy sản phẩm đang hoạt động.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE Auto_ID = @Loai_San_Pham_ID
          AND deleted = 0
    )
        THROW 50005, N'Loại sản phẩm không tồn tại hoặc đã bị xóa.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Don_Vi_Tinh
        WHERE Auto_ID = @Don_Vi_Tinh_ID
          AND deleted = 0
    )
        THROW 50006, N'Đơn vị tính không tồn tại hoặc đã bị xóa.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_San_Pham
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ma_San_Pham = @Ma_San_Pham
    )
        THROW 50007, N'Mã sản phẩm đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_San_Pham
        SET
            Ma_San_Pham = @Ma_San_Pham,
            Ten_San_Pham = @Ten_San_Pham,
            Loai_San_Pham_ID = @Loai_San_Pham_ID,
            Don_Vi_Tinh_ID = @Don_Vi_Tinh_ID,
            Ghi_Chu = @Ghi_Chu,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50008, N'Không tìm thấy sản phẩm đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50007, N'Mã sản phẩm đã tồn tại.', 1;

        THROW;
    END CATCH;
END;
GO


-- 6. Delete mềm theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_113_SP_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_San_Pham
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50009, N'Không tìm thấy sản phẩm đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @Loai_SP_ID bigint, @DVT_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Lấy hoặc tạo ID tạm thời cho Loại SP và Đơn vị tính
    SELECT TOP 1 @Loai_SP_ID = Auto_ID FROM dbo.tbl_DM_Loai_San_Pham WHERE deleted = 0;
    IF @Loai_SP_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created)
        VALUES (N'__TEST_LSP__', N'__Test LSP__', 0, GETDATE());
        SET @Loai_SP_ID = SCOPE_IDENTITY();
    END;

    SELECT TOP 1 @DVT_ID = Auto_ID FROM dbo.tbl_DM_Don_Vi_Tinh WHERE deleted = 0;
    IF @DVT_ID IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created)
        VALUES (N'__Test DVT__', 0, GETDATE());
        SET @DVT_ID = SCOPE_IDENTITY();
    END;

    -- Insert
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_113_SP_sp_ins_Insert
        @Ma_San_Pham = N'__TEST_SP_CRUD__',
        @Ten_San_Pham = N'__Test Sản phẩm CRUD__',
        @Loai_San_Pham_ID = @Loai_SP_ID,
        @Don_Vi_Tinh_ID = @DVT_ID,
        @Ghi_Chu = N'Test CRUD SP',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2113';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_113_SP_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update
    EXEC dbo.FQ_113_SP_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @Ma_San_Pham = N'__TEST_SP_UPD__',
        @Ten_San_Pham = N'__Test Sản phẩm Updated__',
        @Loai_San_Pham_ID = @Loai_SP_ID,
        @Don_Vi_Tinh_ID = @DVT_ID,
        @Ghi_Chu = N'Test update SP',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2113';

    -- List cache
    EXEC dbo.FQ_113_SP_sp_sel_List_For_Cache;

    -- Delete mềm
    EXEC dbo.FQ_113_SP_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2113';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_113_SP thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]113[_]SP[_]%'
ORDER BY name;
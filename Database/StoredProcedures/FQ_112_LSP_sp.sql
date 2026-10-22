SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 2 - Loại sản phẩm (LSP)
   Table: dbo.tbl_DM_Loai_San_Pham
   Ma_Bang: 112, VT: LSP, Ma_Chuc_Nang: 2112
   ========================================================= */

-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_sel_List_By_Created

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
        Auto_ID,
        Ma_LSP,
        Ten_LSP,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Loai_San_Pham
    WHERE deleted = 0
      AND Created >= @FromDate
      AND Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY Created DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_sel_List_For_Cache
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ma_LSP,
        Ten_LSP,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Loai_San_Pham
    WHERE deleted = 0
    ORDER BY Ten_LSP;
END;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ma_LSP,
        Ten_LSP,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Loai_San_Pham
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;
END;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_ins_Insert
    @Ma_LSP                   nvarchar(100),
    @Ten_LSP                  nvarchar(400),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_LSP)), N'') IS NULL
        THROW 50011, N'Mã loại sản phẩm không được để trống.', 1;

    IF NULLIF(LTRIM(RTRIM(@Ten_LSP)), N'') IS NULL
        THROW 50012, N'Tên loại sản phẩm không được để trống.', 1;

    SET @Ma_LSP = LTRIM(RTRIM(@Ma_LSP));
    SET @Ten_LSP = LTRIM(RTRIM(@Ten_LSP));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE deleted = 0
          AND Ma_LSP = @Ma_LSP
    )
        THROW 50013, N'Mã loại sản phẩm đã tồn tại.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE deleted = 0
          AND Ten_LSP = @Ten_LSP
    )
        THROW 50014, N'Tên loại sản phẩm đã tồn tại.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Loai_San_Pham
        (
            Ma_LSP,
            Ten_LSP,
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
            @Ma_LSP,
            @Ten_LSP,
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
        BEGIN
            IF EXISTS
            (
                SELECT 1
                FROM dbo.tbl_DM_Loai_San_Pham
                WHERE deleted = 0
                  AND Ma_LSP = @Ma_LSP
            )
                THROW 50013, N'Mã loại sản phẩm đã tồn tại.', 1;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.tbl_DM_Loai_San_Pham
                WHERE deleted = 0
                  AND Ten_LSP = @Ten_LSP
            )
                THROW 50014, N'Tên loại sản phẩm đã tồn tại.', 1;
        END;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_upd_Update
    @Auto_ID                  bigint,
    @Ma_LSP                   nvarchar(100),
    @Ten_LSP                  nvarchar(400),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_LSP)), N'') IS NULL
        THROW 50021, N'Mã loại sản phẩm không được để trống.', 1;

    IF NULLIF(LTRIM(RTRIM(@Ten_LSP)), N'') IS NULL
        THROW 50022, N'Tên loại sản phẩm không được để trống.', 1;

    SET @Ma_LSP = LTRIM(RTRIM(@Ma_LSP));
    SET @Ten_LSP = LTRIM(RTRIM(@Ten_LSP));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50023, N'Không tìm thấy loại sản phẩm đang hoạt động.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ma_LSP = @Ma_LSP
    )
        THROW 50024, N'Mã loại sản phẩm đã tồn tại.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Loai_San_Pham
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ten_LSP = @Ten_LSP
    )
        THROW 50025, N'Tên loại sản phẩm đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Loai_San_Pham
        SET
            Ma_LSP = @Ma_LSP,
            Ten_LSP = @Ten_LSP,
            Ghi_Chu = @Ghi_Chu,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50023, N'Không tìm thấy loại sản phẩm đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            IF EXISTS
            (
                SELECT 1
                FROM dbo.tbl_DM_Loai_San_Pham
                WHERE deleted = 0
                  AND Auto_ID <> @Auto_ID
                  AND Ma_LSP = @Ma_LSP
            )
                THROW 50024, N'Mã loại sản phẩm đã tồn tại.', 1;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.tbl_DM_Loai_San_Pham
                WHERE deleted = 0
                  AND Auto_ID <> @Auto_ID
                  AND Ten_LSP = @Ten_LSP
            )
                THROW 50025, N'Tên loại sản phẩm đã tồn tại.', 1;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.FQ_112_LSP_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_Loai_San_Pham
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50031, N'Không tìm thấy loại sản phẩm đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_112_LSP_sp_ins_Insert
        @Ma_LSP = N'__TEST_LSP_CRUD__',
        @Ten_LSP = N'__Test Loại sản phẩm CRUD__',
        @Ghi_Chu = N'Test CRUD',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2112';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_112_LSP_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update
    EXEC dbo.FQ_112_LSP_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @Ma_LSP = N'__TEST_LSP_UPD__',
        @Ten_LSP = N'__Test Loại sản phẩm Updated__',
        @Ghi_Chu = N'Test update',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2112';

    -- List cache
    EXEC dbo.FQ_112_LSP_sp_sel_List_For_Cache;

    -- Delete mềm
    EXEC dbo.FQ_112_LSP_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2112';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_112_LSP thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]112[_]LSP[_]%'
ORDER BY name;


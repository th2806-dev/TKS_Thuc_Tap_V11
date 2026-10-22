SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 5 - Danh mục Kho (Kho)
   Table: dbo.tbl_DM_Kho
   Ma_Bang: 115, VT: Kho, Ma_Chuc_Nang: 2115
   ========================================================= */


-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_sel_List_By_Created
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
        Ten_Kho,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho WITH (NOLOCK)
    WHERE deleted = 0
      AND Created >= @FromDate
      AND Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY Created DESC;
END;
GO


-- 2. List cho cache
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_sel_List_For_Cache
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ten_Kho,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho WITH (NOLOCK)
    WHERE deleted = 0
    ORDER BY Ten_Kho ASC;
END;
GO


-- 3. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ten_Kho,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho WITH (NOLOCK)
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;
END;
GO


-- 4. Insert
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_ins_Insert
    @Ten_Kho                  nvarchar(400),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ten_Kho)), N'') IS NULL
        THROW 50001, N'Tên kho không được để trống.', 1;

    SET @Ten_Kho = LTRIM(RTRIM(@Ten_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE deleted = 0
          AND Ten_Kho = @Ten_Kho
    )
        THROW 50002, N'Tên kho đã tồn tại.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Kho
        (
            Ten_Kho,
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
            @Ten_Kho,
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
            THROW 50002, N'Tên kho đã tồn tại.', 1;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 5. Update
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_upd_Update
    @Auto_ID                  bigint,
    @Ten_Kho                  nvarchar(400),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ten_Kho)), N'') IS NULL
        THROW 50001, N'Tên kho không được để trống.', 1;

    SET @Ten_Kho = LTRIM(RTRIM(@Ten_Kho));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50003, N'Không tìm thấy kho đang hoạt động.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ten_Kho = @Ten_Kho
    )
        THROW 50002, N'Tên kho đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Kho
        SET
            Ten_Kho = @Ten_Kho,
            Ghi_Chu = @Ghi_Chu,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50003, N'Không tìm thấy kho đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50002, N'Tên kho đã tồn tại.', 1;

        THROW;
    END CATCH;
END;
GO


-- 6. Delete mềm theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_115_Kho_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_Kho
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50004, N'Không tìm thấy kho đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Insert
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_115_Kho_sp_ins_Insert
        @Ten_Kho = N'__Test Kho CRUD__',
        @Ghi_Chu = N'Test CRUD Kho',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2115';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_115_Kho_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update
    EXEC dbo.FQ_115_Kho_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @Ten_Kho = N'__Test Kho Updated__',
        @Ghi_Chu = N'Test update Kho',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2115';

    -- List cache
    EXEC dbo.FQ_115_Kho_sp_sel_List_For_Cache;

    -- Delete mềm
    EXEC dbo.FQ_115_Kho_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2115';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_115_Kho thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]115[_]Kho[_]%'
ORDER BY name;


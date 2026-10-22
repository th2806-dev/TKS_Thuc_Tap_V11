SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 6 - Phân quyền Kho - User (KU)
   Table: dbo.tbl_DM_Kho_User
   Ma_Bang: 116, VT: KU, Ma_Chuc_Nang: 2116
   ========================================================= */


-- 1. List theo ngày tạo
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_sel_List_By_Created
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
        ku.Auto_ID,
        ku.Ma_Dang_Nhap,
        tv.Ho_Ten,
        ku.Kho_ID,
        k.Ten_Kho,
        ku.deleted,
        ku.Created,
        ku.Created_By,
        ku.Created_By_Function,
        ku.Last_Updated,
        ku.Last_Updated_By,
        ku.Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho_User ku WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON ku.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_Sys_Thanh_Vien tv WITH (NOLOCK)
        ON ku.Ma_Dang_Nhap = tv.Ma_Dang_Nhap AND tv.deleted = 0
    WHERE ku.deleted = 0
      AND ku.Created >= @FromDate
      AND ku.Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY ku.Created DESC;
END;
GO


-- 2. List theo Mã Đăng Nhập
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_sel_List_By_Ma_Dang_Nhap
    @Ma_Dang_Nhap nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ku.Auto_ID,
        ku.Ma_Dang_Nhap,
        tv.Ho_Ten,
        ku.Kho_ID,
        k.Ten_Kho,
        ku.deleted,
        ku.Created,
        ku.Created_By,
        ku.Created_By_Function,
        ku.Last_Updated,
        ku.Last_Updated_By,
        ku.Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho_User ku WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON ku.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_Sys_Thanh_Vien tv WITH (NOLOCK)
        ON ku.Ma_Dang_Nhap = tv.Ma_Dang_Nhap AND tv.deleted = 0
    WHERE ku.deleted = 0
      AND ku.Ma_Dang_Nhap = @Ma_Dang_Nhap
    ORDER BY k.Ten_Kho ASC;
END;
GO


-- 3. List theo Kho ID
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_sel_List_By_Kho_ID
    @Kho_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ku.Auto_ID,
        ku.Ma_Dang_Nhap,
        tv.Ho_Ten,
        ku.Kho_ID,
        k.Ten_Kho,
        ku.deleted,
        ku.Created,
        ku.Created_By,
        ku.Created_By_Function,
        ku.Last_Updated,
        ku.Last_Updated_By,
        ku.Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho_User ku WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON ku.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_Sys_Thanh_Vien tv WITH (NOLOCK)
        ON ku.Ma_Dang_Nhap = tv.Ma_Dang_Nhap AND tv.deleted = 0
    WHERE ku.deleted = 0
      AND ku.Kho_ID = @Kho_ID
    ORDER BY tv.Ho_Ten ASC;
END;
GO


-- 4. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ku.Auto_ID,
        ku.Ma_Dang_Nhap,
        tv.Ho_Ten,
        ku.Kho_ID,
        k.Ten_Kho,
        ku.deleted,
        ku.Created,
        ku.Created_By,
        ku.Created_By_Function,
        ku.Last_Updated,
        ku.Last_Updated_By,
        ku.Last_Updated_By_Function
    FROM dbo.tbl_DM_Kho_User ku WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON ku.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_Sys_Thanh_Vien tv WITH (NOLOCK)
        ON ku.Ma_Dang_Nhap = tv.Ma_Dang_Nhap AND tv.deleted = 0
    WHERE ku.Auto_ID = @Auto_ID
      AND ku.deleted = 0;
END;
GO


-- 5. Insert
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_ins_Insert
    @Ma_Dang_Nhap             nvarchar(100),
    @Kho_ID                   bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_Dang_Nhap)), N'') IS NULL
        THROW 50001, N'Mã đăng nhập không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    SET @Ma_Dang_Nhap = LTRIM(RTRIM(@Ma_Dang_Nhap));

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_Sys_Thanh_Vien
        WHERE Ma_Dang_Nhap = @Ma_Dang_Nhap
          AND deleted = 0
    )
        THROW 50003, N'Mã đăng nhập không tồn tại trong hệ thống.', 1;

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
        FROM dbo.tbl_DM_Kho_User
        WHERE deleted = 0
          AND Ma_Dang_Nhap = @Ma_Dang_Nhap
          AND Kho_ID = @Kho_ID
    )
        THROW 50005, N'Người dùng này đã được gán quyền cho kho này.', 1;

    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Kho_User
        (
            Ma_Dang_Nhap,
            Kho_ID,
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
            @Ma_Dang_Nhap,
            @Kho_ID,
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
            THROW 50005, N'Người dùng này đã được gán quyền cho kho này.', 1;

        THROW;
    END CATCH;

    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- 6. Update
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_upd_Update
    @Auto_ID                  bigint,
    @Ma_Dang_Nhap             nvarchar(100),
    @Kho_ID                   bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Ma_Dang_Nhap)), N'') IS NULL
        THROW 50001, N'Mã đăng nhập không được để trống.', 1;

    IF ISNULL(@Kho_ID, 0) <= 0
        THROW 50002, N'Kho không được để trống.', 1;

    SET @Ma_Dang_Nhap = LTRIM(RTRIM(@Ma_Dang_Nhap));

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Kho_User
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50006, N'Không tìm thấy bản ghi phân quyền đang hoạt động.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_Sys_Thanh_Vien
        WHERE Ma_Dang_Nhap = @Ma_Dang_Nhap
          AND deleted = 0
    )
        THROW 50003, N'Mã đăng nhập không tồn tại trong hệ thống.', 1;

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
        FROM dbo.tbl_DM_Kho_User
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ma_Dang_Nhap = @Ma_Dang_Nhap
          AND Kho_ID = @Kho_ID
    )
        THROW 50005, N'Người dùng này đã được gán quyền cho kho này.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Kho_User
        SET
            Ma_Dang_Nhap = @Ma_Dang_Nhap,
            Kho_ID = @Kho_ID,
            Last_Updated = GETDATE(),
            Last_Updated_By = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50006, N'Không tìm thấy bản ghi phân quyền đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50005, N'Người dùng này đã được gán quyền cho kho này.', 1;

        THROW;
    END CATCH;
END;
GO


-- 7. Delete mềm theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_116_KU_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tbl_DM_Kho_User
    SET
        deleted = 1,
        Last_Updated = GETDATE(),
        Last_Updated_By = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    IF @@ROWCOUNT = 0
        THROW 50007, N'Không tìm thấy bản ghi phân quyền đang hoạt động để xóa.', 1;
END;
GO

-- =========================================================
-- Test CRUD an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;
DECLARE @Kho_ID_1 bigint, @Kho_ID_2 bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Lấy hoặc tạo 2 kho tạm để test gán và đổi kho
    SELECT TOP 1 @Kho_ID_1 = Auto_ID FROM dbo.tbl_DM_Kho WHERE deleted = 0;
    IF @Kho_ID_1 IS NULL
    BEGIN
        INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho 1__', 0, GETDATE());
        SET @Kho_ID_1 = SCOPE_IDENTITY();
    END;

    INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho 2__', 0, GETDATE());
    SET @Kho_ID_2 = SCOPE_IDENTITY();

    -- Insert phân quyền admin vào Kho 1
    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_116_KU_sp_ins_Insert
        @Ma_Dang_Nhap = N'admin',
        @Kho_ID = @Kho_ID_1,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2116';

    SELECT @Auto_ID = Auto_ID FROM @New_ID;
    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get theo ID
    EXEC dbo.FQ_116_KU_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- List theo User
    EXEC dbo.FQ_116_KU_sp_sel_List_By_Ma_Dang_Nhap
        @Ma_Dang_Nhap = N'admin';

    -- List theo Kho
    EXEC dbo.FQ_116_KU_sp_sel_List_By_Kho_ID
        @Kho_ID = @Kho_ID_1;

    -- Update sang Kho 2
    EXEC dbo.FQ_116_KU_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @Ma_Dang_Nhap = N'admin',
        @Kho_ID = @Kho_ID_2,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2116';

    -- Delete mềm
    EXEC dbo.FQ_116_KU_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2116';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD FQ_116_KU thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]116[_]KU[_]%'
ORDER BY name;


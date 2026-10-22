SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 1 - Đơn vị tính (DVT)
   Table: dbo.tbl_DM_Don_Vi_Tinh
   ========================================================= */


-- =========================================================================================
-- 1. SP: Lấy danh sách Đơn vị tính theo khoảng thời gian tạo
-- =========================================================================================
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_sel_List_By_Created
    @FromDate datetime = NULL,
    @ToDate   datetime = NULL
AS
BEGIN
    -- SET NOCOUNT ON: Ngăn SQL Server trả về thông báo "x rows affected" sau mỗi câu lệnh.
    -- Giúp giảm tải băng thông mạng và tránh lỗi xung đột với DataReader ở tầng ứng dụng C#/.NET.
    SET NOCOUNT ON;

    -- Nếu người dùng không truyền Từ ngày, mặc định lùi lại 30 ngày trước
    IF @FromDate IS NULL
        SET @FromDate = DATEADD(day, -30, GETDATE());

    -- Nếu không truyền Đến ngày, mặc định lấy ngày hiện tại
    IF @ToDate IS NULL
        SET @ToDate = GETDATE();

    -- KỸ THUẬT LỌC NGÀY TOÀN VẸN:
    -- Sử dụng: Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    -- Mục đích: Lấy toàn bộ các bản ghi trong ngày @ToDate (đến tận 23:59:59.999) mà không bị sót dữ liệu giờ/phút/giây.
    SELECT
        Auto_ID,
        Ten_Don_Vi_Tinh,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Don_Vi_Tinh WITH (NOLOCK)
    WHERE deleted = 0  -- Chỉ lấy các bản ghi đang còn hoạt động (chưa bị xóa mềm)
      AND Created >= @FromDate
      AND Created < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY Created DESC;
END;
GO



-- 2. List cho cache
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_sel_List_For_Cache
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ten_Don_Vi_Tinh,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Don_Vi_Tinh
    WHERE deleted = 0
    ORDER BY Ten_Don_Vi_Tinh;
END;
GO


-- 3. Get theo ID
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_sel_Get_By_ID
    @Auto_ID bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ten_Don_Vi_Tinh,
        Ghi_Chu,
        deleted,
        Created,
        Created_By,
        Created_By_Function,
        Last_Updated,
        Last_Updated_By,
        Last_Updated_By_Function
    FROM dbo.tbl_DM_Don_Vi_Tinh
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;
END;
GO


-- =========================================================================================
-- 4. SP: Thêm mới Đơn vị tính (Insert)
-- =========================================================================================
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_ins_Insert
    @Ten_Don_Vi_Tinh          nvarchar(200),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- BƯỚC 1: KIỂM TRA RỖNG VÀ CẮT KHOẢNG TRẮNG THỪA
    -- NULLIF(LTRIM(RTRIM(...)), N''): Loại bỏ space 2 đầu, nếu chỉ toàn dấu cách thì quy về NULL để chặn.
    IF NULLIF(LTRIM(RTRIM(@Ten_Don_Vi_Tinh)), N'') IS NULL
        THROW 50001, N'Tên đơn vị tính không được để trống.', 1;

    SET @Ten_Don_Vi_Tinh = LTRIM(RTRIM(@Ten_Don_Vi_Tinh));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    -- BƯỚC 2: KIỂM TRA TRÙNG TÊN TRƯỚC TRÊN DỮ LIỆU ĐANG HOẠT ĐỘNG (deleted = 0)
    -- Giúp trả về thông báo lỗi thân thiện ngay cho người dùng trước khi thực hiện INSERT.
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Don_Vi_Tinh WITH (NOLOCK)
        WHERE deleted = 0
          AND Ten_Don_Vi_Tinh = @Ten_Don_Vi_Tinh
    )
        THROW 50002, N'Tên đơn vị tính đã tồn tại.', 1;

    -- BƯỚC 3: THỰC HIỆN THÊM MỚI TRONG KHỐI TRY...CATCH
    BEGIN TRY
        INSERT INTO dbo.tbl_DM_Don_Vi_Tinh
        (
            Ten_Don_Vi_Tinh,
            Ghi_Chu,
            deleted,                  -- Mặc định = 0 (bản ghi đang hoạt động)
            Created,                  -- Thời gian tạo = GETDATE()
            Created_By,               -- Người tạo
            Created_By_Function,      -- Chức năng tạo
            Last_Updated,             -- Thời gian sửa gần nhất
            Last_Updated_By,          -- Người sửa gần nhất
            Last_Updated_By_Function  -- Chức năng sửa gần nhất
        )
        VALUES
        (
            @Ten_Don_Vi_Tinh,
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
        -- BẮT LỖI XUNG ĐỘT TRUY CẬP ĐỒNG THỜI (RACE CONDITION):
        -- Mã 2601 và 2627 là mã lỗi của SQL Server khi vi phạm ràng buộc Unique Index.
        -- Nếu 2 người dùng bấm Lưu cùng 1 tích tắc, Filtered Unique Index sẽ kích hoạt lỗi này.
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50002, N'Tên đơn vị tính đã tồn tại.', 1;

        THROW; -- Ném tiếp lỗi ra ngoài nếu là lỗi khác
    END CATCH;

    -- BƯỚC 4: TRẢ VỀ ID VỪA SINH RA
    -- Dùng SCOPE_IDENTITY() để lấy Auto_ID vừa sinh ra của chính câu lệnh INSERT trong phiên này.
    -- (An toàn hơn @@IDENTITY vì @@IDENTITY có thể bị ảnh hưởng bởi Trigger).
    SELECT CONVERT(bigint, SCOPE_IDENTITY()) AS Auto_ID;
END;
GO


-- =========================================================================================
-- 5. SP: Cập nhật Đơn vị tính (Update)
-- =========================================================================================
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_upd_Update
    @Auto_ID                  bigint,
    @Ten_Don_Vi_Tinh          nvarchar(200),
    @Ghi_Chu                  nvarchar(500) = NULL,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tên không được rỗng
    IF NULLIF(LTRIM(RTRIM(@Ten_Don_Vi_Tinh)), N'') IS NULL
        THROW 50004, N'Tên đơn vị tính không được để trống.', 1;

    SET @Ten_Don_Vi_Tinh = LTRIM(RTRIM(@Ten_Don_Vi_Tinh));
    SET @Ghi_Chu = NULLIF(LTRIM(RTRIM(@Ghi_Chu)), N'');

    -- Kiểm tra bản ghi cần sửa có tồn tại và chưa bị xóa mềm không
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Don_Vi_Tinh WITH (NOLOCK)
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0
    )
        THROW 50003, N'Không tìm thấy đơn vị tính đang hoạt động.', 1;

    -- Kiểm tra tên mới có bị trùng với đơn vị tính khác đang hoạt động hay không
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tbl_DM_Don_Vi_Tinh WITH (NOLOCK)
        WHERE deleted = 0
          AND Auto_ID <> @Auto_ID
          AND Ten_Don_Vi_Tinh = @Ten_Don_Vi_Tinh
    )
        THROW 50005, N'Tên đơn vị tính đã tồn tại.', 1;

    BEGIN TRY
        UPDATE dbo.tbl_DM_Don_Vi_Tinh
        SET
            Ten_Don_Vi_Tinh          = @Ten_Don_Vi_Tinh,
            Ghi_Chu                  = @Ghi_Chu,
            Last_Updated             = GETDATE(),
            Last_Updated_By          = @Last_Updated_By,
            Last_Updated_By_Function = @Last_Updated_By_Function
        WHERE Auto_ID = @Auto_ID
          AND deleted = 0;

        IF @@ROWCOUNT = 0
            THROW 50003, N'Không tìm thấy đơn vị tính đang hoạt động.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50005, N'Tên đơn vị tính đã tồn tại.', 1;

        THROW;
    END CATCH;
END;
GO


-- =========================================================================================
-- 6. SP: Xóa mềm Đơn vị tính (Soft Delete)
-- =========================================================================================
CREATE OR ALTER PROCEDURE dbo.FQ_111_DVT_sp_del_Delete_By_ID
    @Auto_ID                  bigint,
    @Last_Updated_By          nvarchar(100),
    @Last_Updated_By_Function nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- NGUYÊN TẮC XÓA MỀM (SOFT DELETE):
    -- Không dùng lệnh [DELETE FROM] vì sẽ xóa vĩnh viễn dữ liệu và gây lỗi khóa ngoại ở các bảng liên quan.
    -- Thay vào đó, gán deleted = 1 và ghi nhận thời gian, người thực hiện hành động xóa.
    UPDATE dbo.tbl_DM_Don_Vi_Tinh
    SET
        deleted                  = 1,
        Last_Updated             = GETDATE(),
        Last_Updated_By          = @Last_Updated_By,
        Last_Updated_By_Function = @Last_Updated_By_Function
    WHERE Auto_ID = @Auto_ID
      AND deleted = 0;

    -- @@ROWCOUNT = 0 nghĩa là không có dòng nào được cập nhật (do Auto_ID không tồn tại hoặc đã bị xóa trước đó).
    IF @@ROWCOUNT = 0
        THROW 50006, N'Không tìm thấy đơn vị tính đang hoạt động để xóa.', 1;
END;
GO


-- Test CRUD an toàn, không giữ lại dữ liệu thử
DECLARE @New_ID table (Auto_ID bigint);
DECLARE @Auto_ID bigint;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO @New_ID (Auto_ID)
    EXEC dbo.FQ_111_DVT_sp_ins_Insert
        @Ten_Don_Vi_Tinh = N'__TEST_DVT_CRUD__',
        @Ghi_Chu = N'Test CRUD',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2111';

    SELECT @Auto_ID = Auto_ID
    FROM @New_ID;

    PRINT N'ID vừa insert: ' + CONVERT(nvarchar(30), @Auto_ID);

    -- Get: phải trả về dòng đang hoạt động.
    EXEC dbo.FQ_111_DVT_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    -- Update: tên phải đổi thành __TEST_DVT_UPDATED__.
    EXEC dbo.FQ_111_DVT_sp_upd_Update
        @Auto_ID = @Auto_ID,
        @Ten_Don_Vi_Tinh = N'__TEST_DVT_UPDATED__',
        @Ghi_Chu = N'Test update',
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2111';

    SELECT Auto_ID, Ten_Don_Vi_Tinh, Ghi_Chu, deleted
    FROM dbo.tbl_DM_Don_Vi_Tinh
    WHERE Auto_ID = @Auto_ID;

    -- Delete mềm: sau lệnh này deleted phải bằng 1.
    EXEC dbo.FQ_111_DVT_sp_del_Delete_By_ID
        @Auto_ID = @Auto_ID,
        @Last_Updated_By = N'admin',
        @Last_Updated_By_Function = N'2111';

    SELECT Auto_ID, Ten_Don_Vi_Tinh, deleted
    FROM dbo.tbl_DM_Don_Vi_Tinh
    WHERE Auto_ID = @Auto_ID;

    -- Get_By_ID phải trả 0 dòng vì bản ghi đã xóa mềm.
    EXEC dbo.FQ_111_DVT_sp_sel_Get_By_ID
        @Auto_ID = @Auto_ID;

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test CRUD đã rollback, không lưu dữ liệu thử.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- Sau khi tạo proc, kiểm tra tên đã tồn tại
SELECT name
FROM sys.procedures
WHERE name LIKE N'FQ[_]111[_]DVT[_]%'
ORDER BY name;
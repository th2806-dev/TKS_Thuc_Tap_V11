/* =========================================================================================
   BÀI 1: DANH MỤC ĐƠN VỊ TÍNH (tbl_DM_Don_Vi_Tinh)
   Mã Bảng: 111 | Viết tắt: DVT | Mã Chức Năng: 2111
   Ví dụ: Hộp, Cái, Chai, Gói, Thùng, Kg...
   ========================================================================================= */

-- Bắt buộc bật 2 lệnh này trước khi tạo Filtered Index (WHERE deleted = 0),
-- nếu thiếu SQL Server sẽ báo lỗi Msg 1934.
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Kiểm tra bảng chưa tồn tại mới tạo (Idempotent - chạy lại nhiều lần không lỗi)
IF OBJECT_ID('dbo.tbl_DM_Don_Vi_Tinh', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Don_Vi_Tinh
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ten_Don_Vi_Tinh          nvarchar(200) NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn hệ thống: deleted dùng cho Xóa mềm (0 = hoạt động, 1 = đã xóa),
        -- các cột Created/Last_Updated truy vết ai tạo, ai sửa, lúc nào, ở màn hình nào.
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Don_Vi_Tinh_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Don_Vi_Tinh
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: chỉ ép duy nhất tên trên bản ghi chưa xóa (deleted = 0).
-- Nhờ vậy khi xóa mềm "Hộp" rồi tạo lại "Hộp" mới sẽ không bị lỗi trùng.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Don_Vi_Tinh_Ten_Don_Vi_Tinh' AND object_id = OBJECT_ID('dbo.tbl_DM_Don_Vi_Tinh'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Don_Vi_Tinh_Ten_Don_Vi_Tinh
        ON dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh)
        WHERE deleted = 0;
END;
GO
/* =========================================================================================
   BÀI 3: DANH MỤC SẢN PHẨM (tbl_DM_San_Pham)
   Mã Bảng: 113 | Viết tắt: SP | Mã Chức Năng: 2113
   Lưu trữ thông tin hàng hóa, liên kết với Loại SP và Đơn vị tính
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_San_Pham', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_San_Pham
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ma_San_Pham              nvarchar(100) NOT NULL,
        Ten_San_Pham             nvarchar(400) NOT NULL,

        -- Khóa ngoại tham chiếu đến bảng Loại Sản Phẩm
        Loai_San_Pham_ID         bigint NOT NULL
            CONSTRAINT FK_tbl_DM_San_Pham_tbl_DM_Loai_San_Pham_Loai_San_Pham_ID
                REFERENCES dbo.tbl_DM_Loai_San_Pham (Auto_ID),

        -- Khóa ngoại tham chiếu đến bảng Đơn Vị Tính
        Don_Vi_Tinh_ID           bigint NOT NULL
            CONSTRAINT FK_tbl_DM_San_Pham_tbl_DM_Don_Vi_Tinh_Don_Vi_Tinh_ID
                REFERENCES dbo.tbl_DM_Don_Vi_Tinh (Auto_ID),

        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_San_Pham_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_San_Pham
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: Mã SP không trùng trên bản ghi chưa xóa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_San_Pham_Ma_San_Pham' AND object_id = OBJECT_ID('dbo.tbl_DM_San_Pham'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_San_Pham_Ma_San_Pham
        ON dbo.tbl_DM_San_Pham (Ma_San_Pham)
        WHERE deleted = 0;
END;
GO

-- Index trên khóa ngoại: tăng tốc JOIN khi truy vấn danh sách SP theo Loại hoặc ĐVT
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_San_Pham_Loai_San_Pham_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_San_Pham'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_San_Pham_Loai_San_Pham_ID
        ON dbo.tbl_DM_San_Pham (Loai_San_Pham_ID)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_San_Pham_Don_Vi_Tinh_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_San_Pham'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_San_Pham_Don_Vi_Tinh_ID
        ON dbo.tbl_DM_San_Pham (Don_Vi_Tinh_ID)
        WHERE deleted = 0;
END;
GO
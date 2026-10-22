/* =========================================================================================
   BÀI 4: DANH MỤC NHÀ CUNG CẤP (tbl_DM_NCC)
   Mã Bảng: 114 | Viết tắt: NCC | Mã Chức Năng: 2114
   Quản lý danh sách các đối tác, nhà cung cấp hàng hóa cho doanh nghiệp
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_NCC', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_NCC
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ma_NCC                   nvarchar(100) NOT NULL,
        Ten_NCC                  nvarchar(400) NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_NCC_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_NCC
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: không trùng Mã và Tên trên dữ liệu đang hoạt động
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_NCC_Ma_NCC' AND object_id = OBJECT_ID('dbo.tbl_DM_NCC'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_NCC_Ma_NCC
        ON dbo.tbl_DM_NCC (Ma_NCC)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_NCC_Ten_NCC' AND object_id = OBJECT_ID('dbo.tbl_DM_NCC'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_NCC_Ten_NCC
        ON dbo.tbl_DM_NCC (Ten_NCC)
        WHERE deleted = 0;
END;
GO
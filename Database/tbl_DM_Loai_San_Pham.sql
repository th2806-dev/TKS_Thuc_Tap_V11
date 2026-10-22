/* =========================================================================================
   BÀI 2: DANH MỤC LOẠI SẢN PHẨM (tbl_DM_Loai_San_Pham)
   Mã Bảng: 112 | Viết tắt: LSP | Mã Chức Năng: 2112
   Ví dụ: Điện tử, Gia dụng, Thực phẩm, Hóa mỹ phẩm...
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Loai_San_Pham', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Loai_San_Pham
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ma_LSP                   nvarchar(100) NOT NULL,
        Ten_LSP                  nvarchar(400) NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn: deleted (xóa mềm), Created/Last_Updated (truy vết)
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Loai_San_Pham_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Loai_San_Pham
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: không trùng Mã và Tên trên dữ liệu đang hoạt động (deleted = 0)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Loai_San_Pham_Ma_LSP' AND object_id = OBJECT_ID('dbo.tbl_DM_Loai_San_Pham'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Loai_San_Pham_Ma_LSP
        ON dbo.tbl_DM_Loai_San_Pham (Ma_LSP)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Loai_San_Pham_Ten_LSP' AND object_id = OBJECT_ID('dbo.tbl_DM_Loai_San_Pham'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Loai_San_Pham_Ten_LSP
        ON dbo.tbl_DM_Loai_San_Pham (Ten_LSP)
        WHERE deleted = 0;
END;
GO
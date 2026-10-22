/* =========================================================================================
   BÀI 5: DANH MỤC KHO (tbl_DM_Kho)
   Mã Bảng: 115 | Viết tắt: Kho | Mã Chức Năng: 2115
   Quản lý danh sách các địa điểm kho chứa hàng hóa
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Kho', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Kho
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ten_Kho                  nvarchar(400) NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Kho_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Kho
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: không trùng tên Kho trên dữ liệu đang hoạt động
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Kho_Ten_Kho' AND object_id = OBJECT_ID('dbo.tbl_DM_Kho'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Kho_Ten_Kho
        ON dbo.tbl_DM_Kho (Ten_Kho)
        WHERE deleted = 0;
END;
GO
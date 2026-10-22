/* =========================================================================================
   BÀI 6: PHÂN QUYỀN KHO - NGƯỜI DÙNG (tbl_DM_Kho_User)
   Mã Bảng: 116 | Viết tắt: KU | Mã Chức Năng: 2116
   Phân quyền xem, quản lý kho cho từng tài khoản đăng nhập hệ thống
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Kho_User', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Kho_User
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        Ma_Dang_Nhap             nvarchar(100) NOT NULL,

        -- Khóa ngoại tham chiếu đến bảng Kho
        Kho_ID                   bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Kho_User_tbl_DM_Kho_Kho_ID
                REFERENCES dbo.tbl_DM_Kho (Auto_ID),

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Kho_User_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Kho_User
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Composite Unique Index: một người dùng không được gán trùng 2 lần vào cùng một Kho
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Kho_User_Ma_Dang_Nhap_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Kho_User'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Kho_User_Ma_Dang_Nhap_Kho_ID
        ON dbo.tbl_DM_Kho_User (Ma_Dang_Nhap, Kho_ID)
        WHERE deleted = 0;
END;
GO

-- Index trên Kho_ID: tối ưu truy vấn danh sách người dùng theo kho
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Kho_User_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Kho_User'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Kho_User_Kho_ID
        ON dbo.tbl_DM_Kho_User (Kho_ID)
        WHERE deleted = 0;
END;
GO
/* =========================================================================================
   BÀI 8 & 9: CHI TIẾT HÀNG NHẬP KHO (tbl_DM_Nhap_Kho_Raw_Data)
   Mã Bảng: 122 | Viết tắt: NKR | Mã Chức Năng: 2213
   Lưu từng dòng mặt hàng trong phiếu nhập: Sản phẩm, SL nhập, Đơn giá nhập
   Lưu ý Đề bài 9: CẤM sửa San_Pham_ID khi Update
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Nhap_Kho_Raw_Data', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Nhap_Kho_Raw_Data
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,

        -- Khóa ngoại: thuộc phiếu nhập nào, mặt hàng nào
        Nhap_Kho_ID              bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Nhap_Kho_Raw_Data_tbl_DM_Nhap_Kho_Nhap_Kho_ID
                REFERENCES dbo.tbl_DM_Nhap_Kho (Auto_ID),
        San_Pham_ID              bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Nhap_Kho_Raw_Data_tbl_DM_San_Pham_San_Pham_ID
                REFERENCES dbo.tbl_DM_San_Pham (Auto_ID),

        SL_Nhap                  float NOT NULL,
        Don_Gia_Nhap             float NOT NULL,

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Nhap_Kho_Raw_Data_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Nhap_Kho_Raw_Data
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Index trên khóa ngoại: tối ưu lấy danh sách hàng theo phiếu và theo sản phẩm (cho BCT)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Nhap_Kho_Raw_Data_Nhap_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho_Raw_Data'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Nhap_Kho_Raw_Data_Nhap_Kho_ID
        ON dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Nhap_Kho_Raw_Data_San_Pham_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho_Raw_Data'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Nhap_Kho_Raw_Data_San_Pham_ID
        ON dbo.tbl_DM_Nhap_Kho_Raw_Data (San_Pham_ID)
        WHERE deleted = 0;
END;
GO
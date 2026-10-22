/* =========================================================================================
   BÀI 7 & 10: PHIẾU NHẬP KHO - THÔNG TIN CHUNG (tbl_DM_Nhap_Kho)
   Mã Bảng: 121 | Viết tắt: NK | Mã Chức Năng: 2211
   Lưu phần Header của phiếu nhập: Số phiếu, Ngày nhập, Kho, Nhà cung cấp
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Nhap_Kho', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Nhap_Kho
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        So_Phieu_Nhap_Kho        nvarchar(100) NOT NULL,

        -- Khóa ngoại: nhập vào kho nào, từ nhà cung cấp nào
        Kho_ID                   bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Nhap_Kho_tbl_DM_Kho_Kho_ID
                REFERENCES dbo.tbl_DM_Kho (Auto_ID),
        NCC_ID                   bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Nhap_Kho_tbl_DM_NCC_NCC_ID
                REFERENCES dbo.tbl_DM_NCC (Auto_ID),

        Ngay_Nhap_Kho            datetime NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn.
        -- Khi xóa mềm Header, SP sẽ đồng thời xóa mềm các dòng Raw Data chi tiết.
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Nhap_Kho_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Nhap_Kho
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: Số phiếu nhập không trùng trên phiếu chưa xóa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Nhap_Kho_So_Phieu_Nhap_Kho' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Nhap_Kho_So_Phieu_Nhap_Kho
        ON dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho)
        WHERE deleted = 0;
END;
GO

-- Index trên khóa ngoại: tối ưu lọc phiếu theo kho, NCC
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Nhap_Kho_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Nhap_Kho_Kho_ID
        ON dbo.tbl_DM_Nhap_Kho (Kho_ID)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Nhap_Kho_NCC_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Nhap_Kho_NCC_ID
        ON dbo.tbl_DM_Nhap_Kho (NCC_ID)
        WHERE deleted = 0;
END;
GO

-- Index trên ngày nhập: tối ưu cho Báo cáo Chi tiết Nhập (BCN) và Báo cáo Xuất Nhập Tồn (BCT)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Nhap_Kho_Ngay_Nhap_Kho' AND object_id = OBJECT_ID('dbo.tbl_DM_Nhap_Kho'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Nhap_Kho_Ngay_Nhap_Kho
        ON dbo.tbl_DM_Nhap_Kho (Ngay_Nhap_Kho)
        WHERE deleted = 0;
END;
GO
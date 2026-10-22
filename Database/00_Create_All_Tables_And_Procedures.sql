/* =========================================================================================
   TKS THá»°C Táº¬P V11 - SCRIPT Tá»”NG Há»¢P TOĂ€N Bá»˜ 10 Báº¢NG Dá»® LIá»†U Cá»T LĂ•I (BĂ€I 1 Äáº¾N 17)
   CÆ¡ sá»Ÿ dá»¯ liá»‡u: TKS_Thuc_Tap_V11
   TuĂ¢n thá»§ nghiĂªm ngáº·t:
     1. QUY_CHUAN_MAP_SO_VA_LO_TRINH.md
     2. Äá» bĂ i Bai Tap Thuc Tap.docx
     3. Chuáº©n há»‡ sá»‘:
        - Danh má»¥c: Bang 111-116 <-> CN 2111-2116
        - Nháº­p / Xuáº¥t: Bang 121-124 <-> CN 2211-2224
        - BĂ¡o cĂ¡o: Bang 125-127 <-> CN 2311-2313
     4. Chuáº©n 8 cá»™t Audit trĂªn má»i báº£ng:
        deleted, Created, Created_By, Created_By_Function,
        Last_Updated, Last_Updated_By, Last_Updated_By_Function
     5. Filtered Unique Index trĂªn báº£n ghi chÆ°a xĂ³a (WHERE deleted = 0)
   ========================================================================================= */

USE TKS_Thuc_Tap_V11;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

PRINT N'=================================================================';
PRINT N'Báº®T Äáº¦U Táº O 10 Báº¢NG Cá»T LĂ•I THEO ÄĂNG THá»¨ Tá»° RĂ€NG BUá»˜C KHĂ“A NGOáº I';
PRINT N'=================================================================';
GO

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Don_Vi_Tinh.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Loai_San_Pham.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_San_Pham.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_NCC.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Kho.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Kho_User.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Nhap_Kho.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Nhap_Kho_Raw_Data.sql
-- =========================================================
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

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Xuat_Kho.sql
-- =========================================================
/* =========================================================================================
   BÀI 11 & 14: PHIẾU XUẤT KHO - THÔNG TIN CHUNG (tbl_DM_Xuat_Kho)
   Mã Bảng: 123 | Viết tắt: XK | Mã Chức Năng: 2221
   Lưu phần Header của phiếu xuất: Số phiếu, Ngày xuất, Kho xuất hàng
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Xuat_Kho', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Xuat_Kho
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,
        So_Phieu_Xuat_Kho        nvarchar(100) NOT NULL,

        -- Khóa ngoại: xuất từ kho nào
        Kho_ID                   bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Xuat_Kho_tbl_DM_Kho_Kho_ID
                REFERENCES dbo.tbl_DM_Kho (Auto_ID),

        Ngay_Xuat_Kho            datetime NOT NULL,
        Ghi_Chu                  nvarchar(500) NULL,

        -- 8 cột Audit chuẩn.
        -- Khi xóa mềm Header, SP sẽ đồng thời xóa mềm các dòng Raw Data chi tiết.
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Xuat_Kho_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Xuat_Kho
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Filtered Unique Index: Số phiếu xuất không trùng trên phiếu chưa xóa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_tbl_DM_Xuat_Kho_So_Phieu_Xuat_Kho' AND object_id = OBJECT_ID('dbo.tbl_DM_Xuat_Kho'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_tbl_DM_Xuat_Kho_So_Phieu_Xuat_Kho
        ON dbo.tbl_DM_Xuat_Kho (So_Phieu_Xuat_Kho)
        WHERE deleted = 0;
END;
GO

-- Index trên khóa ngoại: tối ưu lọc phiếu theo kho
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Xuat_Kho_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Xuat_Kho'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Xuat_Kho_Kho_ID
        ON dbo.tbl_DM_Xuat_Kho (Kho_ID)
        WHERE deleted = 0;
END;
GO

-- Index trên ngày xuất: tối ưu cho Báo cáo Chi tiết Xuất (BCX) và Báo cáo Xuất Nhập Tồn (BCT)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Xuat_Kho_Ngay_Xuat_Kho' AND object_id = OBJECT_ID('dbo.tbl_DM_Xuat_Kho'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Xuat_Kho_Ngay_Xuat_Kho
        ON dbo.tbl_DM_Xuat_Kho (Ngay_Xuat_Kho)
        WHERE deleted = 0;
END;
GO

-- =========================================================
-- Ná»˜I DUNG Tá»ª FILE: tbl_DM_Xuat_Kho_Raw_Data.sql
-- =========================================================
/* =========================================================================================
   BÀI 12 & 13: CHI TIẾT HÀNG XUẤT KHO (tbl_DM_Xuat_Kho_Raw_Data)
   Mã Bảng: 124 | Viết tắt: XKR | Mã Chức Năng: 2223
   Lưu từng dòng mặt hàng trong phiếu xuất: Sản phẩm, SL xuất, Đơn giá xuất
   Lưu ý Đề bài 13: CẤM sửa San_Pham_ID khi Update
   ========================================================================================= */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.tbl_DM_Xuat_Kho_Raw_Data', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_DM_Xuat_Kho_Raw_Data
    (
        Auto_ID                  bigint IDENTITY(1,1) NOT NULL,

        -- Khóa ngoại: thuộc phiếu xuất nào, mặt hàng nào
        Xuat_Kho_ID              bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Xuat_Kho_Raw_Data_tbl_DM_Xuat_Kho_Xuat_Kho_ID
                REFERENCES dbo.tbl_DM_Xuat_Kho (Auto_ID),
        San_Pham_ID              bigint NOT NULL
            CONSTRAINT FK_tbl_DM_Xuat_Kho_Raw_Data_tbl_DM_San_Pham_San_Pham_ID
                REFERENCES dbo.tbl_DM_San_Pham (Auto_ID),

        SL_Xuat                  float NOT NULL,
        Don_Gia_Xuat             float NOT NULL,

        -- 8 cột Audit chuẩn
        deleted                  int NOT NULL
            CONSTRAINT DF_tbl_DM_Xuat_Kho_Raw_Data_deleted DEFAULT (0),
        Created                  datetime NULL,
        Created_By               nvarchar(100) NULL,
        Created_By_Function      nvarchar(100) NULL,
        Last_Updated             datetime NULL,
        Last_Updated_By          nvarchar(100) NULL,
        Last_Updated_By_Function nvarchar(100) NULL,

        CONSTRAINT PK_tbl_DM_Xuat_Kho_Raw_Data
            PRIMARY KEY CLUSTERED (Auto_ID)
    );
END;
GO

-- Index trên khóa ngoại: tối ưu lấy danh sách hàng theo phiếu và theo sản phẩm (cho BCT)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Xuat_Kho_Raw_Data_Xuat_Kho_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Xuat_Kho_Raw_Data'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Xuat_Kho_Raw_Data_Xuat_Kho_ID
        ON dbo.tbl_DM_Xuat_Kho_Raw_Data (Xuat_Kho_ID)
        WHERE deleted = 0;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbl_DM_Xuat_Kho_Raw_Data_San_Pham_ID' AND object_id = OBJECT_ID('dbo.tbl_DM_Xuat_Kho_Raw_Data'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_tbl_DM_Xuat_Kho_Raw_Data_San_Pham_ID
        ON dbo.tbl_DM_Xuat_Kho_Raw_Data (San_Pham_ID)
        WHERE deleted = 0;
END;
GO
PRINT N'=================================================================';
PRINT N'HOĂ€N Táº¤T Táº O TOĂ€N Bá»˜ 10 Báº¢NG Cá»T LĂ•I!';
PRINT N'CĂC STORED PROCEDURES ÄÆ¯á»¢C LÆ¯U VĂ€ TEST RIĂNG TRONG THÆ¯ Má»¤C:';
PRINT N'  Database/StoredProcedures/FQ_*.sql';
PRINT N'=================================================================';
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 15 - Báo cáo Chi tiết Hàng Nhập (BCN)
   Ma_Bang: 125, VT: BCN, Ma_Chuc_Nang: 2311
   Route: /Bao_Cao/Chi_Tiet_Nhap
   ========================================================= */


CREATE OR ALTER PROCEDURE dbo.FQ_125_BCN_sp_sel_List_By_Date
    @FromDate datetime = NULL,
    @ToDate   datetime = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FromDate IS NULL
        SET @FromDate = DATEADD(day, -30, GETDATE());

    IF @ToDate IS NULL
        SET @ToDate = GETDATE();

    SELECT
        nk.Auto_ID AS Nhap_Kho_ID,
        raw.Auto_ID AS Raw_ID,
        nk.Ngay_Nhap_Kho,
        nk.So_Phieu_Nhap_Kho,
        nk.Kho_ID,
        k.Ten_Kho,
        nk.NCC_ID,
        ncc.Ten_NCC,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Nhap,
        raw.Don_Gia_Nhap,
        (raw.SL_Nhap * raw.Don_Gia_Nhap) AS Tri_Gia,
        nk.Ghi_Chu AS Ghi_Chu_Header
    FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
    INNER JOIN dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
        ON nk.Auto_ID = raw.Nhap_Kho_ID AND raw.deleted = 0
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON nk.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_DM_NCC ncc WITH (NOLOCK)
        ON nk.NCC_ID = ncc.Auto_ID AND ncc.deleted = 0
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE nk.deleted = 0
      AND nk.Ngay_Nhap_Kho >= @FromDate
      AND nk.Ngay_Nhap_Kho < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY nk.Ngay_Nhap_Kho DESC, nk.So_Phieu_Nhap_Kho DESC, raw.Auto_ID ASC;
END;
GO

-- =========================================================
-- Test Báo cáo an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Kho_ID bigint, @NCC_ID bigint, @LSP_ID bigint, @DVT_ID bigint, @SP_ID bigint, @NK_ID bigint;

    INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho BCN__', 0, GETDATE());
    SET @Kho_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_NCC (Ma_NCC, Ten_NCC, deleted, Created) VALUES (N'__TNCC_BCN__', N'__Test NCC BCN__', 0, GETDATE());
    SET @NCC_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created) VALUES (N'__TLSP_BCN__', N'__TLSP BCN__', 0, GETDATE());
    SET @LSP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created) VALUES (N'__TDVT_BCN__', 0, GETDATE());
    SET @DVT_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_San_Pham (Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, deleted, Created)
    VALUES (N'__TSP_BCN__', N'__Test SP BCN__', @LSP_ID, @DVT_ID, 0, GETDATE());
    SET @SP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, deleted, Created)
    VALUES (N'__TPNK_BCN__', @Kho_ID, @NCC_ID, GETDATE(), 0, GETDATE());
    SET @NK_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID, San_Pham_ID, SL_Nhap, Don_Gia_Nhap, deleted, Created)
    VALUES (@NK_ID, @SP_ID, 20, 45000, 0, GETDATE());

    -- Chạy báo cáo
    EXEC dbo.FQ_125_BCN_sp_sel_List_By_Date
        @FromDate = '2026-01-01',
        @ToDate = '2026-12-31';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test báo cáo FQ_125_BCN thành công (đã rollback, sạch dữ liệu).';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Kiểm tra danh sách SP đã tạo
SELECT name
FROM sys.procedures
WHERE name LIKE N'FQ[_]125[_]BCN[_]%'
ORDER BY name;


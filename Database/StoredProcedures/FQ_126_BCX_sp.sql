SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 16 - Báo cáo Chi tiết Hàng Xuất (BCX)
   Ma_Bang: 126, VT: BCX, Ma_Chuc_Nang: 2312
   Route: /Bao_Cao/Chi_Tiet_Xuat
   ========================================================= */


CREATE OR ALTER PROCEDURE dbo.FQ_126_BCX_sp_sel_List_By_Date
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
        xk.Auto_ID AS Xuat_Kho_ID,
        raw.Auto_ID AS Raw_ID,
        xk.Ngay_Xuat_Kho,
        xk.So_Phieu_Xuat_Kho,
        xk.Kho_ID,
        k.Ten_Kho,
        raw.San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        dvt.Ten_Don_Vi_Tinh,
        raw.SL_Xuat,
        raw.Don_Gia_Xuat,
        (raw.SL_Xuat * raw.Don_Gia_Xuat) AS Tri_Gia,
        xk.Ghi_Chu AS Ghi_Chu_Header
    FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
    INNER JOIN dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
        ON xk.Auto_ID = raw.Xuat_Kho_ID AND raw.deleted = 0
    LEFT JOIN dbo.tbl_DM_Kho k WITH (NOLOCK)
        ON xk.Kho_ID = k.Auto_ID AND k.deleted = 0
    LEFT JOIN dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
        ON raw.San_Pham_ID = sp.Auto_ID AND sp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    WHERE xk.deleted = 0
      AND xk.Ngay_Xuat_Kho >= @FromDate
      AND xk.Ngay_Xuat_Kho < DATEADD(day, 1, CONVERT(date, @ToDate))
    ORDER BY xk.Ngay_Xuat_Kho DESC, xk.So_Phieu_Xuat_Kho DESC, raw.Auto_ID ASC;
END;
GO

-- =========================================================
-- Test Báo cáo an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Kho_ID bigint, @LSP_ID bigint, @DVT_ID bigint, @SP_ID bigint, @XK_ID bigint;

    INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho BCX__', 0, GETDATE());
    SET @Kho_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created) VALUES (N'__TLSP_BCX__', N'__TLSP BCX__', 0, GETDATE());
    SET @LSP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created) VALUES (N'__TDVT_BCX__', 0, GETDATE());
    SET @DVT_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_San_Pham (Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, deleted, Created)
    VALUES (N'__TSP_BCX__', N'__Test SP BCX__', @LSP_ID, @DVT_ID, 0, GETDATE());
    SET @SP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Xuat_Kho (So_Phieu_Xuat_Kho, Kho_ID, Ngay_Xuat_Kho, deleted, Created)
    VALUES (N'__TPXK_BCX__', @Kho_ID, GETDATE(), 0, GETDATE());
    SET @XK_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Xuat_Kho_Raw_Data (Xuat_Kho_ID, San_Pham_ID, SL_Xuat, Don_Gia_Xuat, deleted, Created)
    VALUES (@XK_ID, @SP_ID, 10, 65000, 0, GETDATE());

    -- Chạy báo cáo
    EXEC dbo.FQ_126_BCX_sp_sel_List_By_Date
        @FromDate = '2026-01-01',
        @ToDate = '2026-12-31';

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test báo cáo FQ_126_BCX thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]126[_]BCX[_]%'
ORDER BY name;
GO


SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   Bài 17 - Báo cáo Xuất Nhập Tồn (BCT)
   Ma_Bang: 127, VT: BCT, Ma_Chuc_Nang: 2313
   Route: /Bao_Cao/Xuat_Nhap_Ton
   ========================================================= */


-- =========================================================================================
-- STORED PROCEDURE: BÁO CÁO XUẤT NHẬP TỒN (BCT)
-- NGUYÊN LÝ TÍNH TOÁN KHO KẾ TOÁN:
--   1. Tồn đầu kỳ = (Tổng số lượng nhập trước kỳ) - (Tổng số lượng xuất trước kỳ)
--   2. Nhập trong kỳ = Tổng số lượng nhập phát sinh từ @FromDate đến @ToDate
--   3. Xuất trong kỳ = Tổng số lượng xuất phát sinh từ @FromDate đến @ToDate
--   4. Tồn cuối kỳ = Tồn đầu kỳ + Nhập trong kỳ - Xuất trong kỳ
-- =========================================================================================
CREATE OR ALTER PROCEDURE dbo.FQ_127_BCT_sp_sel_List_By_Date
    @FromDate datetime = NULL,
    @ToDate   datetime = NULL,
    @Kho_ID   bigint   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Xử lý tham số mặc định: nếu không chọn thì lấy 30 ngày gần nhất
    IF @FromDate IS NULL
        SET @FromDate = DATEADD(day, -30, GETDATE());

    IF @ToDate IS NULL
        SET @ToDate = GETDATE();

    -- Chuẩn hóa ngày về kiểu Date để lọc trọn vẹn từng ngày:
    -- @FromDateOnly: Bắt đầu từ 00:00:00 của ngày Từ
    -- @ToDateNextDay: Giới hạn dưới của ngày hôm sau (tương đương đến hết 23:59:59 của ngày Đến)
    DECLARE @FromDateOnly datetime = CONVERT(date, @FromDate);
    DECLARE @ToDateNextDay datetime = DATEADD(day, 1, CONVERT(date, @ToDate));

    -- BƯỚC 1: SỬ DỤNG CTE (COMMON TABLE EXPRESSION) ĐỂ TỔNG HỢP THEO 4 NHÓM:
    ;WITH NhapTruoc AS
    (
        -- 1.1 Tổng số lượng NHẬP TRƯỚC KỲ (Ngay_Nhap_Kho < @FromDateOnly)
        SELECT
            raw.San_Pham_ID,
            SUM(raw.SL_Nhap) AS SL_Nhap_Truoc
        FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
        INNER JOIN dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
            ON nk.Auto_ID = raw.Nhap_Kho_ID AND raw.deleted = 0
        WHERE nk.deleted = 0
          AND nk.Ngay_Nhap_Kho < @FromDateOnly
          AND (@Kho_ID IS NULL OR @Kho_ID <= 0 OR nk.Kho_ID = @Kho_ID)
        GROUP BY raw.San_Pham_ID
    ),
    XuatTruoc AS
    (
        -- 1.2 Tổng số lượng XUẤT TRƯỚC KỲ (Ngay_Xuat_Kho < @FromDateOnly)
        SELECT
            raw.San_Pham_ID,
            SUM(raw.SL_Xuat) AS SL_Xuat_Truoc
        FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
        INNER JOIN dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
            ON xk.Auto_ID = raw.Xuat_Kho_ID AND raw.deleted = 0
        WHERE xk.deleted = 0
          AND xk.Ngay_Xuat_Kho < @FromDateOnly
          AND (@Kho_ID IS NULL OR @Kho_ID <= 0 OR xk.Kho_ID = @Kho_ID)
        GROUP BY raw.San_Pham_ID
    ),
    NhapTrongKy AS
    (
        -- 1.3 Tổng số lượng NHẬP TRONG KỲ (@FromDateOnly <= Ngay_Nhap_Kho < @ToDateNextDay)
        SELECT
            raw.San_Pham_ID,
            SUM(raw.SL_Nhap) AS SL_Nhap
        FROM dbo.tbl_DM_Nhap_Kho nk WITH (NOLOCK)
        INNER JOIN dbo.tbl_DM_Nhap_Kho_Raw_Data raw WITH (NOLOCK)
            ON nk.Auto_ID = raw.Nhap_Kho_ID AND raw.deleted = 0
        WHERE nk.deleted = 0
          AND nk.Ngay_Nhap_Kho >= @FromDateOnly
          AND nk.Ngay_Nhap_Kho < @ToDateNextDay
          AND (@Kho_ID IS NULL OR @Kho_ID <= 0 OR nk.Kho_ID = @Kho_ID)
        GROUP BY raw.San_Pham_ID
    ),
    XuatTrongKy AS
    (
        -- 1.4 Tổng số lượng XUẤT TRONG KỲ (@FromDateOnly <= Ngay_Xuat_Kho < @ToDateNextDay)
        SELECT
            raw.San_Pham_ID,
            SUM(raw.SL_Xuat) AS SL_Xuat
        FROM dbo.tbl_DM_Xuat_Kho xk WITH (NOLOCK)
        INNER JOIN dbo.tbl_DM_Xuat_Kho_Raw_Data raw WITH (NOLOCK)
            ON xk.Auto_ID = raw.Xuat_Kho_ID AND raw.deleted = 0
        WHERE xk.deleted = 0
          AND xk.Ngay_Xuat_Kho >= @FromDateOnly
          AND xk.Ngay_Xuat_Kho < @ToDateNextDay
          AND (@Kho_ID IS NULL OR @Kho_ID <= 0 OR xk.Kho_ID = @Kho_ID)
        GROUP BY raw.San_Pham_ID
    )
    -- BƯỚC 2: KẾT NỐI VỚI BẢNG SẢN PHẨM ĐỂ XUẤT RA BÁO CÁO HOÀN CHỈNH
    SELECT
        sp.Auto_ID AS San_Pham_ID,
        sp.Ma_San_Pham,
        sp.Ten_San_Pham,
        sp.Loai_San_Pham_ID,
        lsp.Ten_LSP AS Ten_Loai_San_Pham,
        sp.Don_Vi_Tinh_ID,
        dvt.Ten_Don_Vi_Tinh,

        -- Cột 1: TỒN ĐẦU KỲ = Nhập trước - Xuất trước
        (ISNULL(nt.SL_Nhap_Truoc, 0) - ISNULL(xt.SL_Xuat_Truoc, 0)) AS SL_Dau_Ky,

        -- Cột 2: NHẬP TRONG KỲ
        ISNULL(nk.SL_Nhap, 0) AS SL_Nhap,

        -- Cột 3: XUẤT TRONG KỲ
        ISNULL(xk.SL_Xuat, 0) AS SL_Xuat,

        -- Cột 4: TỒN CUỐI KỲ = Tồn đầu kỳ + Nhập trong kỳ - Xuất trong kỳ
        ((ISNULL(nt.SL_Nhap_Truoc, 0) - ISNULL(xt.SL_Xuat_Truoc, 0)) + ISNULL(nk.SL_Nhap, 0) - ISNULL(xk.SL_Xuat, 0)) AS SL_Cuoi_Ky
    FROM dbo.tbl_DM_San_Pham sp WITH (NOLOCK)
    LEFT JOIN dbo.tbl_DM_Loai_San_Pham lsp WITH (NOLOCK)
        ON sp.Loai_San_Pham_ID = lsp.Auto_ID AND lsp.deleted = 0
    LEFT JOIN dbo.tbl_DM_Don_Vi_Tinh dvt WITH (NOLOCK)
        ON sp.Don_Vi_Tinh_ID = dvt.Auto_ID AND dvt.deleted = 0
    LEFT JOIN NhapTruoc nt ON sp.Auto_ID = nt.San_Pham_ID
    LEFT JOIN XuatTruoc xt ON sp.Auto_ID = xt.San_Pham_ID
    LEFT JOIN NhapTrongKy nk ON sp.Auto_ID = nk.San_Pham_ID
    LEFT JOIN XuatTrongKy xk ON sp.Auto_ID = xk.San_Pham_ID
    -- ĐIỀU KIỆN HIỂN THỊ:
    -- Lấy tất cả sản phẩm đang hoạt động (sp.deleted = 0), HOẶC những sản phẩm tuy đã xóa mềm nhưng vẫn còn phát sinh số liệu trong kỳ
    WHERE sp.deleted = 0
       OR ISNULL(nt.SL_Nhap_Truoc, 0) <> 0
       OR ISNULL(xt.SL_Xuat_Truoc, 0) <> 0
       OR ISNULL(nk.SL_Nhap, 0) <> 0
       OR ISNULL(xk.SL_Xuat, 0) <> 0
    ORDER BY sp.Ma_San_Pham ASC;
END;
GO


-- =========================================================
-- Test Báo cáo an toàn, tự động rollback không lưu rác dữ liệu
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Kho_ID bigint, @NCC_ID bigint, @LSP_ID bigint, @DVT_ID bigint, @SP_ID bigint;
    DECLARE @NK_Truoc_ID bigint, @XK_Truoc_ID bigint, @NK_Trong_ID bigint, @XK_Trong_ID bigint;

    INSERT INTO dbo.tbl_DM_Kho (Ten_Kho, deleted, Created) VALUES (N'__Test Kho BCT__', 0, GETDATE());
    SET @Kho_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_NCC (Ma_NCC, Ten_NCC, deleted, Created) VALUES (N'__TNCC_BCT__', N'__Test NCC BCT__', 0, GETDATE());
    SET @NCC_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Loai_San_Pham (Ma_LSP, Ten_LSP, deleted, Created) VALUES (N'__TLSP_BCT__', N'__TLSP BCT__', 0, GETDATE());
    SET @LSP_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Don_Vi_Tinh (Ten_Don_Vi_Tinh, deleted, Created) VALUES (N'__TDVT_BCT__', 0, GETDATE());
    SET @DVT_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_San_Pham (Ma_San_Pham, Ten_San_Pham, Loai_San_Pham_ID, Don_Vi_Tinh_ID, deleted, Created)
    VALUES (N'__TSP_BCT__', N'__Test SP BCT__', @LSP_ID, @DVT_ID, 0, GETDATE());
    SET @SP_ID = SCOPE_IDENTITY();

    -- 1. Nhập trước kỳ (Ngày 2026-01-05, SL = 100)
    INSERT INTO dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, deleted, Created)
    VALUES (N'__TPNK_TRUOC__', @Kho_ID, @NCC_ID, '2026-01-05', 0, GETDATE());
    SET @NK_Truoc_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID, San_Pham_ID, SL_Nhap, Don_Gia_Nhap, deleted, Created)
    VALUES (@NK_Truoc_ID, @SP_ID, 100, 50000, 0, GETDATE());

    -- 2. Xuất trước kỳ (Ngày 2026-01-10, SL = 20) => Tồn đầu kỳ = 100 - 20 = 80
    INSERT INTO dbo.tbl_DM_Xuat_Kho (So_Phieu_Xuat_Kho, Kho_ID, Ngay_Xuat_Kho, deleted, Created)
    VALUES (N'__TPXK_TRUOC__', @Kho_ID, '2026-01-10', 0, GETDATE());
    SET @XK_Truoc_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Xuat_Kho_Raw_Data (Xuat_Kho_ID, San_Pham_ID, SL_Xuat, Don_Gia_Xuat, deleted, Created)
    VALUES (@XK_Truoc_ID, @SP_ID, 20, 70000, 0, GETDATE());

    -- 3. Nhập trong kỳ (Ngày 2026-02-10, SL = 50)
    INSERT INTO dbo.tbl_DM_Nhap_Kho (So_Phieu_Nhap_Kho, Kho_ID, NCC_ID, Ngay_Nhap_Kho, deleted, Created)
    VALUES (N'__TPNK_TRONG__', @Kho_ID, @NCC_ID, '2026-02-10', 0, GETDATE());
    SET @NK_Trong_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Nhap_Kho_Raw_Data (Nhap_Kho_ID, San_Pham_ID, SL_Nhap, Don_Gia_Nhap, deleted, Created)
    VALUES (@NK_Trong_ID, @SP_ID, 50, 52000, 0, GETDATE());

    -- 4. Xuất trong kỳ (Ngày 2026-02-15, SL = 30) => Tồn cuối kỳ = 80 + 50 - 30 = 100
    INSERT INTO dbo.tbl_DM_Xuat_Kho (So_Phieu_Xuat_Kho, Kho_ID, Ngay_Xuat_Kho, deleted, Created)
    VALUES (N'__TPXK_TRONG__', @Kho_ID, '2026-02-15', 0, GETDATE());
    SET @XK_Trong_ID = SCOPE_IDENTITY();

    INSERT INTO dbo.tbl_DM_Xuat_Kho_Raw_Data (Xuat_Kho_ID, San_Pham_ID, SL_Xuat, Don_Gia_Xuat, deleted, Created)
    VALUES (@XK_Trong_ID, @SP_ID, 30, 75000, 0, GETDATE());

    -- Chạy báo cáo kiểm tra: Kỳ từ 2026-02-01 đến 2026-02-28
    EXEC dbo.FQ_127_BCT_sp_sel_List_By_Date
        @FromDate = '2026-02-01',
        @ToDate   = '2026-02-28',
        @Kho_ID   = @Kho_ID;

    ROLLBACK TRANSACTION;
    PRINT N'PASS: test báo cáo FQ_127_BCT thành công (đã rollback, sạch dữ liệu).';
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
WHERE name LIKE N'FQ[_]127[_]BCT[_]%'
ORDER BY name;
GO


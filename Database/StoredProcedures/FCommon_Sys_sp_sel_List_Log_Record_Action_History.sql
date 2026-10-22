SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.FCommon_Sys_sp_sel_List_Log_Record_Action_History

    @Ref_ID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Auto_ID,
        Ref_ID,
        Ten_Hanh_Dong,
        Ten_Moi_Truong,
        Ma_Chuc_Nang,
        Ten_Chuc_Nang,
        Noi_Dung_Action,
        deleted,
        Created,
        Created_By
    FROM dbo.view_Log_Record_Action_History WITH (NOLOCK)
    WHERE Ref_ID = @Ref_ID
      AND deleted = 0
    ORDER BY Auto_ID DESC;
END;
GO

-- =========================================================
-- Test an toàn Stored Procedure Common Log Action History
-- =========================================================
BEGIN TRY
    EXEC dbo.FCommon_Sys_sp_sel_List_Log_Record_Action_History @Ref_ID = 1;
    PRINT N'PASS: test FCommon_Sys_sp_sel_List_Log_Record_Action_History thành công.';
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

-- Kiểm tra Stored Procedure đã tạo
SELECT name
FROM sys.procedures
WHERE name = N'FCommon_Sys_sp_sel_List_Log_Record_Action_History';
GO


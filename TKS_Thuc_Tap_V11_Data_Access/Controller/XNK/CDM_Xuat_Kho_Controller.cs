using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.Report;
using TKS_Thuc_Tap_V11_Data_Access.Entity.XNK;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.XNK
{
    public class CDM_Xuat_Kho_Controller
    {
        public List<CDM_Xuat_Kho> FQ_123_XK_sp_sel_List_By_Created(DateTime? p_dtmFrom, DateTime? p_dtmTo)
        {
            var v_arrRes = new List<CDM_Xuat_Kho>();
            using var v_dt = new DataTable();
            p_dtmFrom = CUtility_Date.Convert_To_Dau_Ngay(p_dtmFrom);
            p_dtmTo = CUtility_Date.Convert_To_Cuoi_Ngay(p_dtmTo);
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_123_XK_sp_sel_List_By_Created", p_dtmFrom, p_dtmTo);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CDM_Xuat_Kho>(v_row));
            return v_arrRes;
        }

        public CDM_Xuat_Kho FQ_123_XK_sp_sel_Get_By_ID(long p_lngAuto_ID)
        {
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_123_XK_sp_sel_Get_By_ID", p_lngAuto_ID);
            return v_dt.Rows.Count == 0 ? null : CUtility.Map_Row_To_Entity<CDM_Xuat_Kho>(v_dt.Rows[0]);
        }

        public long FQ_123_XK_sp_ins_Insert(CDM_Xuat_Kho p_objData)
        {
            return Convert.ToInt64(CSqlHelper.ExecuteScalar(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_123_XK_sp_ins_Insert",
                p_objData.So_Phieu_Xuat_Kho, p_objData.Kho_ID, p_objData.Ngay_Xuat_Kho,
                p_objData.Ghi_Chu, p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function));
        }

        public void FQ_123_XK_sp_upd_Update(CDM_Xuat_Kho p_objData)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_123_XK_sp_upd_Update",
                p_objData.Auto_ID, p_objData.So_Phieu_Xuat_Kho, p_objData.Kho_ID, p_objData.Ngay_Xuat_Kho,
                p_objData.Ghi_Chu, p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function);
        }

        public void FQ_123_XK_sp_del_Delete_By_ID(long p_lngAuto_ID, string p_strUser, string p_strFunction)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_123_XK_sp_del_Delete_By_ID",
                p_lngAuto_ID, p_strUser, p_strFunction);
        }

        public List<CBao_Cao_Chi_Tiet_Xuat> FQ_123_XK_sp_sel_Report_By_ID(long p_lngAuto_ID)
        {
            var v_arrRes = new List<CBao_Cao_Chi_Tiet_Xuat>();
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_123_XK_sp_sel_Report_By_ID", p_lngAuto_ID);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CBao_Cao_Chi_Tiet_Xuat>(v_row));
            return v_arrRes;
        }
    }
}
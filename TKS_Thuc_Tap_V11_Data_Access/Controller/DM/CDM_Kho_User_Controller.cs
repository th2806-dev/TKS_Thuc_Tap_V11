using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.DM
{
    public class CDM_Kho_User_Controller
    {
        public List<CDM_Kho_User> FQ_116_KU_sp_sel_List_By_Created(DateTime? p_dtmFrom, DateTime? p_dtmTo)
        {
            var v_arrRes = new List<CDM_Kho_User>();
            using var v_dt = new DataTable();
            p_dtmFrom = CUtility_Date.Convert_To_Dau_Ngay(p_dtmFrom);
            p_dtmTo = CUtility_Date.Convert_To_Cuoi_Ngay(p_dtmTo);
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_116_KU_sp_sel_List_By_Created", p_dtmFrom, p_dtmTo);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CDM_Kho_User>(v_row));
            return v_arrRes;
        }

        public List<CDM_Kho_User> FQ_116_KU_sp_sel_List_By_Ma_Dang_Nhap(string p_strMa_Dang_Nhap)
        {
            return Load_List("FQ_116_KU_sp_sel_List_By_Ma_Dang_Nhap", p_strMa_Dang_Nhap);
        }

        public List<CDM_Kho_User> FQ_116_KU_sp_sel_List_By_Kho_ID(long p_lngKho_ID)
        {
            return Load_List("FQ_116_KU_sp_sel_List_By_Kho_ID", p_lngKho_ID);
        }

        public CDM_Kho_User FQ_116_KU_sp_sel_Get_By_ID(long p_lngAuto_ID)
        {
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_116_KU_sp_sel_Get_By_ID", p_lngAuto_ID);
            return v_dt.Rows.Count == 0 ? null : CUtility.Map_Row_To_Entity<CDM_Kho_User>(v_dt.Rows[0]);
        }

        public long FQ_116_KU_sp_ins_Insert(CDM_Kho_User p_objData)
        {
            return Convert.ToInt64(CSqlHelper.ExecuteScalar(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_116_KU_sp_ins_Insert",
                p_objData.Ma_Dang_Nhap, p_objData.Kho_ID, p_objData.Last_Updated_By,
                p_objData.Last_Updated_By_Function));
        }

        public void FQ_116_KU_sp_upd_Update(CDM_Kho_User p_objData)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_116_KU_sp_upd_Update",
                p_objData.Auto_ID, p_objData.Ma_Dang_Nhap, p_objData.Kho_ID,
                p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function);
        }

        public void FQ_116_KU_sp_del_Delete_By_ID(long p_lngAuto_ID, string p_strUser, string p_strFunction)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_116_KU_sp_del_Delete_By_ID",
                p_lngAuto_ID, p_strUser, p_strFunction);
        }

        private static List<CDM_Kho_User> Load_List(string p_strProcedure, params object[] p_arrValues)
        {
            var v_arrRes = new List<CDM_Kho_User>();
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, p_strProcedure, p_arrValues);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CDM_Kho_User>(v_row));
            return v_arrRes;
        }
    }
}

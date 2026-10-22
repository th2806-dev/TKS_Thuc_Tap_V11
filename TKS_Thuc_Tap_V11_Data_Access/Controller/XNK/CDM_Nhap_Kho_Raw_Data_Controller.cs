using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.XNK;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.XNK
{
    public class CDM_Nhap_Kho_Raw_Data_Controller
    {
        public List<CDM_Nhap_Kho_Raw_Data> FQ_122_NKR_sp_sel_List_By_Nhap_Kho_ID(long p_lngNhap_Kho_ID)
        {
            var v_arrRes = new List<CDM_Nhap_Kho_Raw_Data>();
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_122_NKR_sp_sel_List_By_Nhap_Kho_ID", p_lngNhap_Kho_ID);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CDM_Nhap_Kho_Raw_Data>(v_row));
            return v_arrRes;
        }

        public CDM_Nhap_Kho_Raw_Data FQ_122_NKR_sp_sel_Get_By_ID(long p_lngAuto_ID)
        {
            using var v_dt = new DataTable();
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_122_NKR_sp_sel_Get_By_ID", p_lngAuto_ID);
            return v_dt.Rows.Count == 0 ? null : CUtility.Map_Row_To_Entity<CDM_Nhap_Kho_Raw_Data>(v_dt.Rows[0]);
        }

        public long FQ_122_NKR_sp_ins_Insert(CDM_Nhap_Kho_Raw_Data p_objData)
        {
            return Convert.ToInt64(CSqlHelper.ExecuteScalar(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_122_NKR_sp_ins_Insert",
                p_objData.Nhap_Kho_ID, p_objData.San_Pham_ID, p_objData.SL_Nhap, p_objData.Don_Gia_Nhap,
                p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function));
        }

        public void FQ_122_NKR_sp_upd_Update(CDM_Nhap_Kho_Raw_Data p_objData)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_122_NKR_sp_upd_Update",
                p_objData.Auto_ID, p_objData.SL_Nhap, p_objData.Don_Gia_Nhap,
                p_objData.Last_Updated_By, p_objData.Last_Updated_By_Function);
        }

        public void FQ_122_NKR_sp_del_Delete_By_ID(long p_lngAuto_ID, string p_strUser, string p_strFunction)
        {
            CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_122_NKR_sp_del_Delete_By_ID",
                p_lngAuto_ID, p_strUser, p_strFunction);
        }
    }
}
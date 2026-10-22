using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.Report;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Report
{
    public class CBao_Cao_Chi_Tiet_Xuat_Controller
    {
        public List<CBao_Cao_Chi_Tiet_Xuat> FQ_126_BCX_sp_sel_List_By_Date(DateTime? p_dtmFrom, DateTime? p_dtmTo)
        {
            var v_arrRes = new List<CBao_Cao_Chi_Tiet_Xuat>();
            using var v_dt = new DataTable();
            p_dtmFrom = CUtility_Date.Convert_To_Dau_Ngay(p_dtmFrom);
            p_dtmTo = CUtility_Date.Convert_To_Cuoi_Ngay(p_dtmTo);
            CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_126_BCX_sp_sel_List_By_Date", p_dtmFrom, p_dtmTo);
            foreach (DataRow v_row in v_dt.Rows)
                v_arrRes.Add(CUtility.Map_Row_To_Entity<CBao_Cao_Chi_Tiet_Xuat>(v_row));
            return v_arrRes;
        }
    }
}
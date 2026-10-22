using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using TKS_Thuc_Tap_V11_Data_Access.DataLayer;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;
using TKS_Thuc_Tap_V11_Data_Access.Utility;
using Microsoft.Data.SqlClient;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.DM
{
    public class CDM_San_Pham_Controller
    {
        // 1. Lấy danh sách sản phẩm theo ngày tạo (hiển thị Grid)
        public List<CDM_San_Pham> FQ_113_SP_sp_sel_List_By_Created(DateTime? p_dtmFrom, DateTime? p_dtmTo)
        {
            List<CDM_San_Pham> v_arrRes = new List<CDM_San_Pham>();
            DataTable v_dt = new DataTable();
            try
            {
                p_dtmFrom = CUtility_Date.Convert_To_Dau_Ngay(p_dtmFrom);
                p_dtmTo = CUtility_Date.Convert_To_Cuoi_Ngay(p_dtmTo);
                CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_113_SP_sp_sel_List_By_Created", p_dtmFrom, p_dtmTo);
                foreach (DataRow v_row in v_dt.Rows)
                {
                    CDM_San_Pham v_objRes = CUtility.Map_Row_To_Entity<CDM_San_Pham>(v_row);
                    v_arrRes.Add(v_objRes);
                }
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                v_dt.Dispose();
            }
            return v_arrRes;
        }

        // 2. Lấy toàn bộ danh sách nạp Cache (CCache_San_Pham)
        public List<CDM_San_Pham> FQ_113_SP_sp_sel_List_For_Cache()
        {
            List<CDM_San_Pham> v_arrRes = new List<CDM_San_Pham>();
            DataTable v_dt = new DataTable();
            try
            {
                CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_113_SP_sp_sel_List_For_Cache");
                foreach (DataRow v_row in v_dt.Rows)
                {
                    CDM_San_Pham v_objRes = CUtility.Map_Row_To_Entity<CDM_San_Pham>(v_row);
                    v_arrRes.Add(v_objRes);
                }
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                v_dt.Dispose();
            }
            return v_arrRes;
        }

        // 3. Lấy chi tiết 1 sản phẩm theo ID (Xem / Sửa)
        public CDM_San_Pham FQ_113_SP_sp_sel_Get_By_ID(long p_lngAuto_ID)
        {
            CDM_San_Pham v_objRes = null;
            DataTable v_dt = new DataTable();
            try
            {
                CSqlHelper.FillDataTable(CConfig.TKS_Thuc_Tap_V11_Conn_String, v_dt, "FQ_113_SP_sp_sel_Get_By_ID", p_lngAuto_ID);
                if (v_dt.Rows.Count > 0)
                {
                    v_objRes = CUtility.Map_Row_To_Entity<CDM_San_Pham>(v_dt.Rows[0]);
                }
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                v_dt.Dispose();
            }
            return v_objRes;
        }

        // 4. Thêm mới sản phẩm (trả về Auto_ID)
        public long FQ_113_SP_sp_ins_Insert(CDM_San_Pham p_objData)
        {
            long v_lngRes = CConst.INT_VALUE_NULL;
            try
            {
                v_lngRes = Convert.ToInt64(CSqlHelper.ExecuteScalar(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_113_SP_sp_ins_Insert",
                    p_objData.Ma_San_Pham,
                    p_objData.Ten_San_Pham,
                    p_objData.Loai_San_Pham_ID,
                    p_objData.Don_Vi_Tinh_ID,
                    p_objData.Ghi_Chu,
                    p_objData.Last_Updated_By,
                    p_objData.Last_Updated_By_Function));
            }
            catch (Exception)
            {
                throw;
            }
            return v_lngRes;
        }

        // 5. Thêm mới sản phẩm có Transaction (dùng khi Import Excel)
        public long FQ_113_SP_sp_ins_Insert(SqlConnection p_objConn, SqlTransaction p_objTrans, CDM_San_Pham p_objData)
        {
            long v_lngRes = CConst.INT_VALUE_NULL;
            try
            {
                v_lngRes = Convert.ToInt64(CSqlHelper.ExecuteScalar(p_objConn, p_objTrans, CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_113_SP_sp_ins_Insert",
                    p_objData.Ma_San_Pham,
                    p_objData.Ten_San_Pham,
                    p_objData.Loai_San_Pham_ID,
                    p_objData.Don_Vi_Tinh_ID,
                    p_objData.Ghi_Chu,
                    p_objData.Last_Updated_By,
                    p_objData.Last_Updated_By_Function));
            }
            catch (Exception)
            {
                throw;
            }
            return v_lngRes;
        }

        // 6. Cập nhật sản phẩm
        public void FQ_113_SP_sp_upd_Update(CDM_San_Pham p_objData)
        {
            try
            {
                CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_113_SP_sp_upd_Update",
                    p_objData.Auto_ID,
                    p_objData.Ma_San_Pham,
                    p_objData.Ten_San_Pham,
                    p_objData.Loai_San_Pham_ID,
                    p_objData.Don_Vi_Tinh_ID,
                    p_objData.Ghi_Chu,
                    p_objData.Last_Updated_By,
                    p_objData.Last_Updated_By_Function);
            }
            catch (Exception)
            {
                throw;
            }
        }

        // 7. Cập nhật sản phẩm có Transaction
        public void FQ_113_SP_sp_upd_Update(SqlConnection p_objConn, SqlTransaction p_objTrans, CDM_San_Pham p_objData)
        {
            try
            {
                CSqlHelper.ExecuteNonquery(p_objConn, p_objTrans, CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_113_SP_sp_upd_Update",
                    p_objData.Auto_ID,
                    p_objData.Ma_San_Pham,
                    p_objData.Ten_San_Pham,
                    p_objData.Loai_San_Pham_ID,
                    p_objData.Don_Vi_Tinh_ID,
                    p_objData.Ghi_Chu,
                    p_objData.Last_Updated_By,
                    p_objData.Last_Updated_By_Function);
            }
            catch (Exception)
            {
                throw;
            }
        }

        // 8. Xóa mềm sản phẩm theo ID (deleted = 1)
        public void FQ_113_SP_sp_del_Delete_By_ID(long p_iAuto_ID, string p_strLast_Updated_By, string p_strLast_Updated_By_Function)
        {
            try
            {
                CSqlHelper.ExecuteNonquery(CConfig.TKS_Thuc_Tap_V11_Conn_String, "FQ_113_SP_sp_del_Delete_By_ID",
                    p_iAuto_ID,
                    p_strLast_Updated_By,
                    p_strLast_Updated_By_Function);
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}

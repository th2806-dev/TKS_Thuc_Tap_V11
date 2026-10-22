using System;
using System.Collections.Generic;
using System.Linq;
using TKS_Thuc_Tap_V11_Data_Access.Controller.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Cache
{
    public class CCache_San_Pham
    {
        // Danh sách và các Dictionary lưu trữ trong bộ nhớ RAM
        private static List<CDM_San_Pham> Arr_Data = new();
        private static Dictionary<long, CDM_San_Pham> Dic_Data_ID = new();
        private static Dictionary<string, CDM_San_Pham> Dic_Data_Code = new(StringComparer.OrdinalIgnoreCase);
        private static Dictionary<string, List<CDM_San_Pham>> Dic_Data_Ten_San_Pham = new(StringComparer.OrdinalIgnoreCase);

        // 1. Nạp toàn bộ dữ liệu sản phẩm từ DB vào Cache khi khởi động ứng dụng
        public static void Load_Cache_San_Pham()
        {
            // Lấy dữ liệu trước; nếu truy vấn DB lỗi thì cache hiện tại vẫn được giữ nguyên.
            CDM_San_Pham_Controller v_objCtrl = new();
            List<CDM_San_Pham> v_arrTemp_Data = v_objCtrl.FQ_113_SP_sp_sel_List_For_Cache();

            Arr_Data.Clear();
            Dic_Data_ID.Clear();
            Dic_Data_Code.Clear();
            Dic_Data_Ten_San_Pham.Clear();
            foreach (CDM_San_Pham v_objData in v_arrTemp_Data)
                Add_Data(v_objData);
        }

        public static void Add_Data(CDM_San_Pham p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Dic_Data_ID.Add(p_objData.Auto_ID, p_objData);
            Arr_Data.Add(p_objData);

            string v_strCodeKey = Normalize_Key(p_objData.Ma_San_Pham);
            if (v_strCodeKey != null)
                Dic_Data_Code.TryAdd(v_strCodeKey, p_objData);

            // Tên sản phẩm không bị ràng buộc duy nhất; giữ tất cả sản phẩm cùng tên.
            string v_strNameKey = Normalize_Key(p_objData.Ten_San_Pham);
            if (v_strNameKey != null)
            {
                if (!Dic_Data_Ten_San_Pham.TryGetValue(v_strNameKey, out List<CDM_San_Pham> v_arrSameName))
                {
                    v_arrSameName = new List<CDM_San_Pham>();
                    Dic_Data_Ten_San_Pham.Add(v_strNameKey, v_arrSameName);
                }

                v_arrSameName.Add(p_objData);
            }
        }

        public static void Update_Data(CDM_San_Pham p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || !Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Delete_Data(p_objData.Auto_ID);
            Add_Data(p_objData);
        }

        public static void Delete_Data(long p_iAuto_ID)
        {
            if (!Dic_Data_ID.TryGetValue(p_iAuto_ID, out CDM_San_Pham v_objData))
                return;

            Dic_Data_ID.Remove(p_iAuto_ID);
            Arr_Data.Remove(v_objData);

            string v_strCodeKey = Normalize_Key(v_objData.Ma_San_Pham);
            if (v_strCodeKey != null
                && Dic_Data_Code.TryGetValue(v_strCodeKey, out CDM_San_Pham v_objCode)
                && v_objCode.Auto_ID == p_iAuto_ID)
            {
                Dic_Data_Code.Remove(v_strCodeKey);
            }

            string v_strNameKey = Normalize_Key(v_objData.Ten_San_Pham);
            if (v_strNameKey != null && Dic_Data_Ten_San_Pham.TryGetValue(v_strNameKey, out List<CDM_San_Pham> v_arrSameName))
            {
                v_arrSameName.RemoveAll(it => it.Auto_ID == p_iAuto_ID);
                if (v_arrSameName.Count == 0)
                    Dic_Data_Ten_San_Pham.Remove(v_strNameKey);
            }
        }

        public static CDM_San_Pham Get_Data_By_ID(long p_iAuto_ID)
        {
            return Dic_Data_ID.TryGetValue(p_iAuto_ID, out CDM_San_Pham v_objData) ? v_objData : null;
        }

        public static CDM_San_Pham Get_Data_By_Code(string p_strCode)
        {
            string v_strKey = Normalize_Key(p_strCode);
            return v_strKey != null && Dic_Data_Code.TryGetValue(v_strKey, out CDM_San_Pham v_objData)
                ? v_objData
                : null;
        }

        public static CDM_San_Pham Get_Data_By_Ten_San_Pham(string p_strTen_San_Pham)
        {
            // Giữ hàm cũ để tương thích; nếu tên trùng, dùng hàm trả danh sách bên dưới.
            List<CDM_San_Pham> v_arrData = Get_Data_List_By_Ten_San_Pham(p_strTen_San_Pham);
            return v_arrData.Count > 0 ? v_arrData[0] : null;
        }

        public static List<CDM_San_Pham> Get_Data_List_By_Ten_San_Pham(string p_strTen_San_Pham)
        {
            string v_strKey = Normalize_Key(p_strTen_San_Pham);
            return v_strKey != null && Dic_Data_Ten_San_Pham.TryGetValue(v_strKey, out List<CDM_San_Pham> v_arrData)
                ? v_arrData.ToList()
                : new List<CDM_San_Pham>();
        }

        public static List<CDM_San_Pham> List_Data()
        {
            return Arr_Data.OrderBy(it => it.Ten_San_Pham).ToList();
        }

        private static string Normalize_Key(string p_strValue)
        {
            return string.IsNullOrWhiteSpace(p_strValue) ? null : p_strValue.Trim();
        }
    }
}

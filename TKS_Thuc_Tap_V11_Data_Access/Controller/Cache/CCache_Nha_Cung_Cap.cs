using System.Collections.Generic;
using System.Linq;
using System;
using TKS_Thuc_Tap_V11_Data_Access.Controller.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Cache
{
    public class CCache_Nha_Cung_Cap
    {
        // Danh sách và các Dictionary lưu trữ trong bộ nhớ RAM
        private static List<CDM_Nha_Cung_Cap> Arr_Data = new();
        private static Dictionary<long, CDM_Nha_Cung_Cap> Dic_Data_ID = new();
        private static Dictionary<string, CDM_Nha_Cung_Cap> Dic_Data_Ma_NCC = new(StringComparer.OrdinalIgnoreCase);
        private static Dictionary<string, CDM_Nha_Cung_Cap> Dic_Data_Ten_NCC = new(StringComparer.OrdinalIgnoreCase);

        // 1. Nạp toàn bộ dữ liệu nhà cung cấp từ DB vào Cache khi khởi động ứng dụng
        public static void Load_Cache_Nha_Cung_Cap()
        {
            // Lấy dữ liệu trước; nếu truy vấn DB lỗi thì cache hiện tại vẫn được giữ nguyên.
            CDM_Nha_Cung_Cap_Controller v_objCtrl = new();
            List<CDM_Nha_Cung_Cap> v_arrTemp_Data = v_objCtrl.FQ_114_NCC_sp_sel_List_For_Cache();

            Arr_Data.Clear();
            Dic_Data_ID.Clear();
            Dic_Data_Ma_NCC.Clear();
            Dic_Data_Ten_NCC.Clear();
            foreach (CDM_Nha_Cung_Cap v_objData in v_arrTemp_Data)
                Add_Data(v_objData);
        }

        public static void Add_Data(CDM_Nha_Cung_Cap p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Dic_Data_ID.Add(p_objData.Auto_ID, p_objData);
            Arr_Data.Add(p_objData);

            string v_strMaKey = Normalize_Key(p_objData.Ma_NCC);
            if (v_strMaKey != null)
                Dic_Data_Ma_NCC.TryAdd(v_strMaKey, p_objData);

            string v_strTenKey = Normalize_Key(p_objData.Ten_NCC);
            if (v_strTenKey != null)
                Dic_Data_Ten_NCC.TryAdd(v_strTenKey, p_objData);
        }

        public static void Update_Data(CDM_Nha_Cung_Cap p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || !Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Delete_Data(p_objData.Auto_ID);
            Add_Data(p_objData);
        }

        public static void Delete_Data(long p_iAuto_ID)
        {
            if (!Dic_Data_ID.TryGetValue(p_iAuto_ID, out CDM_Nha_Cung_Cap v_objData))
                return;

            Dic_Data_ID.Remove(p_iAuto_ID);
            Arr_Data.Remove(v_objData);

            Remove_Key_If_Mapped_To_ID(Dic_Data_Ma_NCC, v_objData.Ma_NCC, p_iAuto_ID);
            Remove_Key_If_Mapped_To_ID(Dic_Data_Ten_NCC, v_objData.Ten_NCC, p_iAuto_ID);
        }

        public static CDM_Nha_Cung_Cap Get_Data_By_ID(long p_iAuto_ID)
        {
            return Dic_Data_ID.TryGetValue(p_iAuto_ID, out CDM_Nha_Cung_Cap v_objData) ? v_objData : null;
        }

        public static CDM_Nha_Cung_Cap Get_Data_By_Ma_NCC(string p_strMa_NCC)
        {
            string v_strKey = Normalize_Key(p_strMa_NCC);
            return v_strKey != null && Dic_Data_Ma_NCC.TryGetValue(v_strKey, out CDM_Nha_Cung_Cap v_objData)
                ? v_objData
                : null;
        }

        public static CDM_Nha_Cung_Cap Get_Data_By_Ten_NCC(string p_strTen_NCC)
        {
            string v_strKey = Normalize_Key(p_strTen_NCC);
            return v_strKey != null && Dic_Data_Ten_NCC.TryGetValue(v_strKey, out CDM_Nha_Cung_Cap v_objData)
                ? v_objData
                : null;
        }

        public static List<CDM_Nha_Cung_Cap> Get_All_Data()
        {
            return List_Data();
        }

        public static List<CDM_Nha_Cung_Cap> List_Data()
        {
            return Arr_Data.OrderBy(it => it.Ten_NCC).ToList();
        }

        private static string Normalize_Key(string p_strValue)
        {
            return string.IsNullOrWhiteSpace(p_strValue) ? null : p_strValue.Trim();
        }

        private static void Remove_Key_If_Mapped_To_ID(
            Dictionary<string, CDM_Nha_Cung_Cap> p_dicIndex, string p_strValue, long p_lngID)
        {
            string v_strKey = Normalize_Key(p_strValue);
            if (v_strKey != null
                && p_dicIndex.TryGetValue(v_strKey, out CDM_Nha_Cung_Cap v_objIndexed)
                && v_objIndexed.Auto_ID == p_lngID)
            {
                p_dicIndex.Remove(v_strKey);
            }
        }
    }
}

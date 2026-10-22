using System;
using System.Collections.Generic;
using System.Linq;
using TKS_Thuc_Tap_V11_Data_Access.Controller.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Cache
{
    public class CCache_Don_Vi_Tinh
    {
        private static List<CDM_Don_Vi_Tinh> Arr_Data = new();

        private static Dictionary<long, CDM_Don_Vi_Tinh> Dic_Data_ID = new();
        private static Dictionary<string, CDM_Don_Vi_Tinh> Dic_Data_Ten_Don_Vi_Tinh = new(StringComparer.OrdinalIgnoreCase);

        public static void Load_Cache_Don_Vi_Tinh()
        {
            // Lấy dữ liệu trước; nếu truy vấn DB lỗi thì cache hiện tại vẫn được giữ nguyên.
            CDM_Don_Vi_Tinh_Controller v_objCtrl = new();
            List<CDM_Don_Vi_Tinh> v_arrTemp_Data = v_objCtrl.FQ_111_DVT_sp_sel_List_For_Cache();

            Arr_Data.Clear();
            Dic_Data_ID.Clear();
            Dic_Data_Ten_Don_Vi_Tinh.Clear();
            foreach (CDM_Don_Vi_Tinh v_objData in v_arrTemp_Data)
                Add_Data(v_objData);
        }

        public static void Add_Data(CDM_Don_Vi_Tinh p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Dic_Data_ID.Add(p_objData.Auto_ID, p_objData);
            Arr_Data.Add(p_objData);

            string v_strKey = Normalize_Key(p_objData.Ten_Don_Vi_Tinh);
            if (v_strKey != null)
                Dic_Data_Ten_Don_Vi_Tinh.TryAdd(v_strKey, p_objData);
        }

        public static void Update_Data(CDM_Don_Vi_Tinh p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || !Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;
            Delete_Data(p_objData.Auto_ID);
            Add_Data(p_objData);
        }

        public static void Delete_Data(long p_lngID)
        {
            if (Dic_Data_ID.ContainsKey(p_lngID) == false)
                return;
            CDM_Don_Vi_Tinh v_objData = Dic_Data_ID[p_lngID];
            Dic_Data_ID.Remove(p_lngID);
            Arr_Data.Remove(v_objData);

            string v_strKey = Normalize_Key(v_objData.Ten_Don_Vi_Tinh);
            if (v_strKey != null
                && Dic_Data_Ten_Don_Vi_Tinh.TryGetValue(v_strKey, out CDM_Don_Vi_Tinh v_objIndexed)
                && v_objIndexed.Auto_ID == p_lngID)
            {
                Dic_Data_Ten_Don_Vi_Tinh.Remove(v_strKey);
            }
        }

        public static CDM_Don_Vi_Tinh Get_Data_By_ID(long p_lngID)
        {
            return Dic_Data_ID.TryGetValue(p_lngID, out CDM_Don_Vi_Tinh v_objData) ? v_objData : null;
        }

        public static CDM_Don_Vi_Tinh Get_Data_By_Ten_Don_Vi_Tinh(string p_strTen_Don_Vi_Tinh)
        {
            string v_strKey = Normalize_Key(p_strTen_Don_Vi_Tinh);
            return v_strKey != null
                && Dic_Data_Ten_Don_Vi_Tinh.TryGetValue(v_strKey, out CDM_Don_Vi_Tinh v_objData)
                ? v_objData
                : null;
        }

        public static List<CDM_Don_Vi_Tinh> List_Data()
        {
            return Arr_Data.OrderBy(it => it.Ten_Don_Vi_Tinh).ToList();
        }

        private static string Normalize_Key(string p_strValue)
        {
            return string.IsNullOrWhiteSpace(p_strValue) ? null : p_strValue.Trim();
        }
    }
}

using System.Collections.Generic;
using System.Linq;
using System;
using TKS_Thuc_Tap_V11_Data_Access.Controller.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Cache
{
    public class CCache_Kho
    {
        private static List<CDM_Kho> Arr_Data = new();

        private static Dictionary<long, CDM_Kho> Dic_Data_ID = new();
        private static Dictionary<string, CDM_Kho> Dic_Data_Ten_Kho = new(StringComparer.OrdinalIgnoreCase);

        public static void Load_Cache_Kho()
        {
            // Lấy dữ liệu trước; nếu truy vấn DB lỗi thì cache hiện tại vẫn được giữ nguyên.
            CDM_Kho_Controller v_objCtrl = new();
            List<CDM_Kho> v_arrTemp_Data = v_objCtrl.FQ_115_Kho_sp_sel_List_For_Cache();

            Arr_Data.Clear();
            Dic_Data_ID.Clear();
            Dic_Data_Ten_Kho.Clear();
            foreach (CDM_Kho v_objData in v_arrTemp_Data)
                Add_Data(v_objData);
        }

        public static void Add_Data(CDM_Kho p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Dic_Data_ID.Add(p_objData.Auto_ID, p_objData);
            Arr_Data.Add(p_objData);

            string v_strKey = Normalize_Key(p_objData.Ten_Kho);
            if (v_strKey != null)
                Dic_Data_Ten_Kho.TryAdd(v_strKey, p_objData);
        }

        public static void Update_Data(CDM_Kho p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || !Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;

            Delete_Data(p_objData.Auto_ID);
            Add_Data(p_objData);
        }

        public static void Delete_Data(CDM_Kho p_objData)
        {
            if (p_objData != null)
                Delete_Data(p_objData.Auto_ID);
        }

        public static void Delete_Data(long p_lngID)
        {
            if (!Dic_Data_ID.TryGetValue(p_lngID, out CDM_Kho v_objData))
                return;

            Dic_Data_ID.Remove(p_lngID);
            Arr_Data.Remove(v_objData);

            string v_strKey = Normalize_Key(v_objData.Ten_Kho);
            if (v_strKey != null
                && Dic_Data_Ten_Kho.TryGetValue(v_strKey, out CDM_Kho v_objIndexed)
                && v_objIndexed.Auto_ID == p_lngID)
            {
                Dic_Data_Ten_Kho.Remove(v_strKey);
            }
        }

        public static CDM_Kho Get_Data_By_ID(long p_lngID)
        {
            return Dic_Data_ID.TryGetValue(p_lngID, out CDM_Kho v_objData) ? v_objData : null;
        }

        public static CDM_Kho Get_Data_By_Ten_Kho(string p_strTen_Kho)
        {
            string v_strKey = Normalize_Key(p_strTen_Kho);
            return v_strKey != null && Dic_Data_Ten_Kho.TryGetValue(v_strKey, out CDM_Kho v_objData)
                ? v_objData
                : null;
        }

        public static List<CDM_Kho> Get_All_Data()
        {
            return List_Data();
        }

        public static List<CDM_Kho> List_Data()
        {
            return Arr_Data.OrderBy(it => it.Ten_Kho).ToList();
        }

        private static string Normalize_Key(string p_strValue)
        {
            return string.IsNullOrWhiteSpace(p_strValue) ? null : p_strValue.Trim();
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using TKS_Thuc_Tap_V11_Data_Access.Controller.DM;
using TKS_Thuc_Tap_V11_Data_Access.Entity.DM;

namespace TKS_Thuc_Tap_V11_Data_Access.Controller.Cache
{
    public class CCache_Loai_San_Pham
    {
        private static List<CDM_Loai_San_Pham> Arr_Data = new();

        private static Dictionary<string, CDM_Loai_San_Pham> Dic_Data_Code = new(StringComparer.OrdinalIgnoreCase);
        private static Dictionary<long, CDM_Loai_San_Pham> Dic_Data_ID = new();
        private static Dictionary<string, CDM_Loai_San_Pham> Dic_Data_Ten_LSP = new(StringComparer.OrdinalIgnoreCase);

        public static void Load_Cache_Loai_San_Pham()
        {
            // Lấy dữ liệu trước; nếu truy vấn DB lỗi thì cache hiện tại vẫn được giữ nguyên.
            CDM_Loai_San_Pham_Controller v_objCtrl = new();
            List<CDM_Loai_San_Pham> v_arrTemp_Data = v_objCtrl.FQ_112_LSP_sp_sel_List_For_Cache();

            Arr_Data.Clear();
            Dic_Data_ID.Clear();
            Dic_Data_Code.Clear();
            Dic_Data_Ten_LSP.Clear();
            foreach (CDM_Loai_San_Pham v_objData in v_arrTemp_Data)
                Add_Data(v_objData);
        }

        public static void Add_Data(CDM_Loai_San_Pham p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;
            Dic_Data_ID.Add(p_objData.Auto_ID, p_objData);
            Arr_Data.Add(p_objData);

            string v_strMaKey = Normalize_Key(p_objData.Ma_LSP);
            if (v_strMaKey != null)
                Dic_Data_Code.TryAdd(v_strMaKey, p_objData);

            string v_strTenKey = Normalize_Key(p_objData.Ten_LSP);
            if (v_strTenKey != null)
                Dic_Data_Ten_LSP.TryAdd(v_strTenKey, p_objData);
        }

        public static void Update_Data(CDM_Loai_San_Pham p_objData)
        {
            if (p_objData == null || p_objData.Auto_ID <= 0 || !Dic_Data_ID.ContainsKey(p_objData.Auto_ID))
                return;
            Delete_Data(p_objData.Auto_ID);
            Add_Data(p_objData);
        }

        public static void Delete_Data(long p_iAuto_ID)
        {
            if (Dic_Data_ID.ContainsKey(p_iAuto_ID) == false || p_iAuto_ID == 0)
                return;
            CDM_Loai_San_Pham v_objData = Dic_Data_ID[p_iAuto_ID];
            Dic_Data_ID.Remove(p_iAuto_ID);
            Arr_Data.Remove(v_objData);

            Remove_Key_If_Mapped_To_ID(Dic_Data_Code, v_objData.Ma_LSP, p_iAuto_ID);
            Remove_Key_If_Mapped_To_ID(Dic_Data_Ten_LSP, v_objData.Ten_LSP, p_iAuto_ID);
        }

        public static CDM_Loai_San_Pham Get_Data_By_ID(long p_iAuto_ID)
        {
            return Dic_Data_ID.TryGetValue(p_iAuto_ID, out CDM_Loai_San_Pham v_objData) ? v_objData : null;
        }

        public static CDM_Loai_San_Pham Get_Data_By_Code(string p_strCode)
        {
            string v_strKey = Normalize_Key(p_strCode);
            return v_strKey != null && Dic_Data_Code.TryGetValue(v_strKey, out CDM_Loai_San_Pham v_objData)
                ? v_objData
                : null;
        }

        public static CDM_Loai_San_Pham Get_Data_By_Ten_LSP(string p_strTen_LSP)
        {
            string v_strKey = Normalize_Key(p_strTen_LSP);
            return v_strKey != null && Dic_Data_Ten_LSP.TryGetValue(v_strKey, out CDM_Loai_San_Pham v_objData)
                ? v_objData
                : null;
        }

        public static List<CDM_Loai_San_Pham> List_Data()
        {
            return Arr_Data.OrderBy(it => it.Ten_LSP).ToList();
        }

        private static string Normalize_Key(string p_strValue)
        {
            return string.IsNullOrWhiteSpace(p_strValue) ? null : p_strValue.Trim();
        }

        private static void Remove_Key_If_Mapped_To_ID(
            Dictionary<string, CDM_Loai_San_Pham> p_dicIndex, string p_strValue, long p_lngID)
        {
            string v_strKey = Normalize_Key(p_strValue);
            if (v_strKey != null
                && p_dicIndex.TryGetValue(v_strKey, out CDM_Loai_San_Pham v_objIndexed)
                && v_objIndexed.Auto_ID == p_lngID)
            {
                p_dicIndex.Remove(v_strKey);
            }
        }
    }
}

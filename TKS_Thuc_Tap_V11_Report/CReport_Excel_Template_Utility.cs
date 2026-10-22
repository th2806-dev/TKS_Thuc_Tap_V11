using System.Globalization;

namespace TKS_Thuc_Tap_V11_Report
{
    internal static class CReport_Excel_Template_Utility
    {
        private static readonly string[] m_arrDigit_Words =
        {
            "không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"
        };

        private static readonly string[] m_arrGroup_Words =
        {
            "", "nghìn", "triệu", "tỷ", "nghìn tỷ", "triệu tỷ"
        };

        public static string Number_To_Vietnamese_Words(decimal p_dcmValue, bool p_bInclude_Decimals = false)
        {
            if (p_dcmValue < 0)
                return "âm " + Number_To_Vietnamese_Words(Math.Abs(p_dcmValue), p_bInclude_Decimals);

            decimal v_dcmRounded = decimal.Truncate(p_dcmValue);
            if (v_dcmRounded > long.MaxValue)
                throw new ArgumentOutOfRangeException(nameof(p_dcmValue), "Giá trị vượt quá phạm vi chuyển đổi sang chữ.");

            long v_lngInteger = (long)v_dcmRounded;
            string v_strResult = Integer_To_Vietnamese_Words(v_lngInteger);

            if (!p_bInclude_Decimals)
                return v_strResult;

            string v_strNumber = p_dcmValue.ToString("0.############################", CultureInfo.InvariantCulture);
            int v_iDecimalIndex = v_strNumber.IndexOf('.');
            if (v_iDecimalIndex < 0)
                return v_strResult;

            string v_strDecimalDigits = v_strNumber[(v_iDecimalIndex + 1)..];
            string v_strDecimalWords = string.Join(" ", v_strDecimalDigits.Select(
                v_chrDigit => m_arrDigit_Words[v_chrDigit - '0']));
            return $"{v_strResult} phẩy {v_strDecimalWords}";
        }

        private static string Integer_To_Vietnamese_Words(long p_lngValue)
        {
            if (p_lngValue == 0)
                return m_arrDigit_Words[0];

            var v_arrGroups = new List<int>();
            long v_lngRemaining = p_lngValue;
            while (v_lngRemaining > 0)
            {
                v_arrGroups.Add((int)(v_lngRemaining % 1000));
                v_lngRemaining /= 1000;
            }

            int v_iHighest_Group = v_arrGroups.Count - 1;
            var v_arrWords = new List<string>();
            for (int i = v_iHighest_Group; i >= 0; i--)
            {
                int v_iGroup = v_arrGroups[i];
                if (v_iGroup == 0)
                    continue;

                bool v_bInclude_Hundreds = i < v_iHighest_Group;
                string v_strGroup = Three_Digits_To_Words(v_iGroup, v_bInclude_Hundreds);
                if (i < m_arrGroup_Words.Length && m_arrGroup_Words[i].Length > 0)
                    v_strGroup += " " + m_arrGroup_Words[i];

                v_arrWords.Add(v_strGroup);
            }

            return string.Join(" ", v_arrWords);
        }

        private static string Three_Digits_To_Words(int p_iValue, bool p_bInclude_Hundreds)
        {
            int v_iHundreds = p_iValue / 100;
            int v_iTens = (p_iValue % 100) / 10;
            int v_iOnes = p_iValue % 10;
            var v_arrWords = new List<string>();

            if (v_iHundreds > 0 || p_bInclude_Hundreds)
                v_arrWords.Add(m_arrDigit_Words[v_iHundreds] + " trăm");

            if (v_iTens == 0)
            {
                if (v_iOnes > 0)
                {
                    if (v_iHundreds > 0 || p_bInclude_Hundreds)
                        v_arrWords.Add("lẻ");
                    v_arrWords.Add(m_arrDigit_Words[v_iOnes]);
                }
            }
            else if (v_iTens == 1)
            {
                v_arrWords.Add("mười");
                if (v_iOnes > 0)
                    v_arrWords.Add(v_iOnes == 5 ? "lăm" : m_arrDigit_Words[v_iOnes]);
            }
            else
            {
                v_arrWords.Add(m_arrDigit_Words[v_iTens] + " mươi");
                if (v_iOnes == 1)
                    v_arrWords.Add("mốt");
                else if (v_iOnes == 5)
                    v_arrWords.Add("lăm");
                else if (v_iOnes > 0)
                    v_arrWords.Add(m_arrDigit_Words[v_iOnes]);
            }

            return string.Join(" ", v_arrWords);
        }
    }
}

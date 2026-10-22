using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Entity.Report
{
    public class CBao_Cao_Chi_Tiet_Nhap
    {
        // Khai báo các field
        private long m_lngNhap_Kho_ID;
        private long m_lngRaw_ID;
        private DateTime? m_dtmNgay_Nhap_Kho;
        private string m_strSo_Phieu_Nhap_Kho;
        private long m_lngKho_ID;
        private string m_strTen_Kho;
        private long m_lngNCC_ID;
        private string m_strTen_NCC;
        private long m_lngSan_Pham_ID;
        private string m_strMa_San_Pham;
        private string m_strTen_San_Pham;
        private string m_strTen_Don_Vi_Tinh;
        private double m_dblSL_Nhap;
        private double m_dblDon_Gia_Nhap;
        private double m_dblTri_Gia;
        private string m_strGhi_Chu_Header;

        public CBao_Cao_Chi_Tiet_Nhap()
        {
            ResetData();
        }

        public void ResetData()
        {
            m_lngNhap_Kho_ID = CConst.INT_VALUE_NULL;
            m_lngRaw_ID = CConst.INT_VALUE_NULL;
            m_dtmNgay_Nhap_Kho = CConst.DTM_VALUE_NULL;
            m_strSo_Phieu_Nhap_Kho = CConst.STR_VALUE_NULL;
            m_lngKho_ID = CConst.INT_VALUE_NULL;
            m_strTen_Kho = CConst.STR_VALUE_NULL;
            m_lngNCC_ID = CConst.INT_VALUE_NULL;
            m_strTen_NCC = CConst.STR_VALUE_NULL;
            m_lngSan_Pham_ID = CConst.INT_VALUE_NULL;
            m_strMa_San_Pham = CConst.STR_VALUE_NULL;
            m_strTen_San_Pham = CConst.STR_VALUE_NULL;
            m_strTen_Don_Vi_Tinh = CConst.STR_VALUE_NULL;
            m_dblSL_Nhap = CConst.DB_VALUE_NULL;
            m_dblDon_Gia_Nhap = CConst.DB_VALUE_NULL;
            m_dblTri_Gia = CConst.DB_VALUE_NULL;
            m_strGhi_Chu_Header = CConst.STR_VALUE_NULL;
        }

        // Các property
        public long Nhap_Kho_ID
        {
            get { return m_lngNhap_Kho_ID; }
            set { m_lngNhap_Kho_ID = value; }
        }

        public long Raw_ID
        {
            get { return m_lngRaw_ID; }
            set { m_lngRaw_ID = value; }
        }

        public DateTime? Ngay_Nhap_Kho
        {
            get { return m_dtmNgay_Nhap_Kho; }
            set { m_dtmNgay_Nhap_Kho = value; }
        }

        public string So_Phieu_Nhap_Kho
        {
            get { return m_strSo_Phieu_Nhap_Kho; }
            set { m_strSo_Phieu_Nhap_Kho = value == null ? "" : value.Trim(); }
        }

        public long Kho_ID
        {
            get { return m_lngKho_ID; }
            set { m_lngKho_ID = value; }
        }

        public string Ten_Kho
        {
            get { return m_strTen_Kho; }
            set { m_strTen_Kho = value == null ? "" : value.Trim(); }
        }

        public long NCC_ID
        {
            get { return m_lngNCC_ID; }
            set { m_lngNCC_ID = value; }
        }

        public string Ten_NCC
        {
            get { return m_strTen_NCC; }
            set { m_strTen_NCC = value == null ? "" : value.Trim(); }
        }

        public long San_Pham_ID
        {
            get { return m_lngSan_Pham_ID; }
            set { m_lngSan_Pham_ID = value; }
        }

        public string Ma_San_Pham
        {
            get { return m_strMa_San_Pham; }
            set { m_strMa_San_Pham = value == null ? "" : value.Trim(); }
        }

        public string Ten_San_Pham
        {
            get { return m_strTen_San_Pham; }
            set { m_strTen_San_Pham = value == null ? "" : value.Trim(); }
        }

        public string Ten_Don_Vi_Tinh
        {
            get { return m_strTen_Don_Vi_Tinh; }
            set { m_strTen_Don_Vi_Tinh = value == null ? "" : value.Trim(); }
        }

        public double SL_Nhap
        {
            get { return m_dblSL_Nhap; }
            set { m_dblSL_Nhap = value; }
        }

        public double Don_Gia_Nhap
        {
            get { return m_dblDon_Gia_Nhap; }
            set { m_dblDon_Gia_Nhap = value; }
        }

        public double Tri_Gia
        {
            get { return m_dblTri_Gia; }
            set { m_dblTri_Gia = value; }
        }

        public string Ghi_Chu_Header
        {
            get { return m_strGhi_Chu_Header; }
            set { m_strGhi_Chu_Header = value == null ? "" : value.Trim(); }
        }
    }
}

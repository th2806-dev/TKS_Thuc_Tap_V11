using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Data_Access.Entity.Report
{
    public class CBao_Cao_Xuat_Nhap_Ton
    {
        // Khai báo các field
        private long m_lngSan_Pham_ID;
        private string m_strMa_San_Pham;
        private string m_strTen_San_Pham;
        private long m_lngLoai_San_Pham_ID;
        private string m_strTen_Loai_San_Pham;
        private long m_lngDon_Vi_Tinh_ID;
        private string m_strTen_Don_Vi_Tinh;
        private double m_dblSL_Dau_Ky;
        private double m_dblSL_Nhap;
        private double m_dblSL_Xuat;
        private double m_dblSL_Cuoi_Ky;

        public CBao_Cao_Xuat_Nhap_Ton()
        {
            ResetData();
        }

        public void ResetData()
        {
            m_lngSan_Pham_ID = CConst.INT_VALUE_NULL;
            m_strMa_San_Pham = CConst.STR_VALUE_NULL;
            m_strTen_San_Pham = CConst.STR_VALUE_NULL;
            m_lngLoai_San_Pham_ID = CConst.INT_VALUE_NULL;
            m_strTen_Loai_San_Pham = CConst.STR_VALUE_NULL;
            m_lngDon_Vi_Tinh_ID = CConst.INT_VALUE_NULL;
            m_strTen_Don_Vi_Tinh = CConst.STR_VALUE_NULL;
            m_dblSL_Dau_Ky = CConst.DB_VALUE_NULL;
            m_dblSL_Nhap = CConst.DB_VALUE_NULL;
            m_dblSL_Xuat = CConst.DB_VALUE_NULL;
            m_dblSL_Cuoi_Ky = CConst.DB_VALUE_NULL;
        }

        // Các property
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

        public long Loai_San_Pham_ID
        {
            get { return m_lngLoai_San_Pham_ID; }
            set { m_lngLoai_San_Pham_ID = value; }
        }

        public string Ten_Loai_San_Pham
        {
            get { return m_strTen_Loai_San_Pham; }
            set { m_strTen_Loai_San_Pham = value == null ? "" : value.Trim(); }
        }

        public long Don_Vi_Tinh_ID
        {
            get { return m_lngDon_Vi_Tinh_ID; }
            set { m_lngDon_Vi_Tinh_ID = value; }
        }

        public string Ten_Don_Vi_Tinh
        {
            get { return m_strTen_Don_Vi_Tinh; }
            set { m_strTen_Don_Vi_Tinh = value == null ? "" : value.Trim(); }
        }

        public double SL_Dau_Ky
        {
            get { return m_dblSL_Dau_Ky; }
            set { m_dblSL_Dau_Ky = value; }
        }

        public double SL_Nhap
        {
            get { return m_dblSL_Nhap; }
            set { m_dblSL_Nhap = value; }
        }

        public double SL_Xuat
        {
            get { return m_dblSL_Xuat; }
            set { m_dblSL_Xuat = value; }
        }

        public double SL_Cuoi_Ky
        {
            get { return m_dblSL_Cuoi_Ky; }
            set { m_dblSL_Cuoi_Ky = value; }
        }
    }
}

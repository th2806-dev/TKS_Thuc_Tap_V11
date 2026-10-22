using System.ComponentModel;
using OfficeOpenXml;
using TKS_Thuc_Tap_V11_Data_Access.Entity.XNK;
using TKS_Thuc_Tap_V11_Data_Access.Controller.XNK;
using TKS_Thuc_Tap_V11_Data_Access.Entity.Report;
using TKS_Thuc_Tap_V11_Data_Access.Utility;

namespace TKS_Thuc_Tap_V11_Report
{
    [DataObject]
    public class CReport_Nhap_Kho
    {
        [DataObjectMethod(DataObjectMethodType.Select)]
        public List<CBao_Cao_Chi_Tiet_Nhap> rptReport_Nhap_Kho(long p_lngNhap_Kho_ID)
        {
            var v_objController = new CDM_Nhap_Kho_Controller();
            return v_objController.FQ_121_NK_sp_sel_Report_By_ID(p_lngNhap_Kho_ID);
        }

        public byte[] Export_Excel_Template(
            string p_strTemplate_Path,
            CDM_Nhap_Kho p_objHeader,
            IReadOnlyList<CBao_Cao_Chi_Tiet_Nhap> p_arrDetails)
        {
            if (p_objHeader == null)
                throw new ArgumentNullException(nameof(p_objHeader));
            if (p_arrDetails == null)
                throw new ArgumentNullException(nameof(p_arrDetails));

            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using var v_objPackage = new ExcelPackage(new FileInfo(p_strTemplate_Path));
            var v_objSheet = v_objPackage.Workbook.Worksheets["TemplatePhieuNhapKho"]
                ?? throw new InvalidOperationException("Không tìm thấy sheet TemplatePhieuNhapKho.");

            const int v_iFirst_Detail_Row = 12;
            const int v_iTemplate_Detail_Count = 10;
            if (p_arrDetails.Count < v_iTemplate_Detail_Count)
            {
                v_objSheet.DeleteRow(
                    v_iFirst_Detail_Row + p_arrDetails.Count,
                    v_iTemplate_Detail_Count - p_arrDetails.Count);
            }
            else if (p_arrDetails.Count > v_iTemplate_Detail_Count)
            {
                int v_iExtra_Rows = p_arrDetails.Count - v_iTemplate_Detail_Count;
                v_objSheet.InsertRow(22, v_iExtra_Rows, 21);
            }

            DateTime? v_dtmDate = p_objHeader.Ngay_Nhap_Kho;
            v_objSheet.Cells["A1"].Value = "Đơn Vị: " + CConfig.Company_Name;
            v_objSheet.Cells["A3"].Value = v_dtmDate.HasValue
                ? $"Ngày {v_dtmDate.Value:dd} tháng {v_dtmDate.Value:MM} năm {v_dtmDate.Value:yyyy}"
                : "";
            v_objSheet.Cells["A4"].Value = "Số Phiếu Nhập: " + p_objHeader.So_Phieu_Nhap_Kho;
            v_objSheet.Cells["A5"].Value = "Họ Tên Người Giao Hàng: " + p_objHeader.Ten_NCC;
            v_objSheet.Cells["C6"].Value = v_dtmDate.HasValue
                ? $"Ngày {v_dtmDate.Value:dd} tháng {v_dtmDate.Value:MM} năm {v_dtmDate.Value:yyyy} của:"
                : "Ngày ..... tháng ..... năm ....... của:";
            v_objSheet.Cells["A7"].Value = "Nhập Tại Kho: " + p_objHeader.Ten_Kho;
            v_objSheet.Cells["A8"].Value = string.IsNullOrWhiteSpace(p_objHeader.Ghi_Chu)
                ? ""
                : "Ghi chú: " + p_objHeader.Ghi_Chu;
            v_objSheet.Cells["A8:H8"].Style.HorizontalAlignment =
                OfficeOpenXml.Style.ExcelHorizontalAlignment.Left;

            for (int i = 0; i < p_arrDetails.Count; i++)
            {
                CBao_Cao_Chi_Tiet_Nhap v_objDetail = p_arrDetails[i];
                int v_iRow = v_iFirst_Detail_Row + i;
                v_objSheet.Cells[v_iRow, 1].Value = i + 1;
                v_objSheet.Cells[v_iRow, 2].Value = v_objDetail.Ten_San_Pham;
                v_objSheet.Cells[v_iRow, 3].Value = v_objDetail.Ma_San_Pham;
                v_objSheet.Cells[v_iRow, 4].Value = v_objDetail.Ten_Don_Vi_Tinh;
                v_objSheet.Cells[v_iRow, 5].Value = v_objDetail.SL_Nhap;
                v_objSheet.Cells[v_iRow, 6].Value = v_objDetail.SL_Nhap;
                v_objSheet.Cells[v_iRow, 7].Value = v_objDetail.Don_Gia_Nhap;
                v_objSheet.Cells[v_iRow, 8].Value = v_objDetail.Tri_Gia;
            }

            int v_iTotal_Row = v_iFirst_Detail_Row + p_arrDetails.Count;
            double v_dblTotal_Quantity = p_arrDetails.Sum(v_objDetail => v_objDetail.SL_Nhap);
            double v_dblTotal_Amount = p_arrDetails.Sum(v_objDetail => v_objDetail.Tri_Gia);
            v_objSheet.Cells[v_iTotal_Row, 5].Value = v_dblTotal_Quantity;
            v_objSheet.Cells[v_iTotal_Row, 6].Value = v_dblTotal_Quantity;
            v_objSheet.Cells[v_iTotal_Row, 8].Value = v_dblTotal_Amount;
            int v_iAmount_Words_Row = 14 + p_arrDetails.Count;
            v_objSheet.Cells[v_iAmount_Words_Row, 1].Value =
                "Tổng Số Tiền (Viết bằng chữ): " +
                CReport_Excel_Template_Utility.Number_To_Vietnamese_Words((decimal)v_dblTotal_Amount);

            return v_objPackage.GetAsByteArray();
        }
    }
}
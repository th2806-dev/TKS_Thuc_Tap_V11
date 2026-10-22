using System.ComponentModel;
using OfficeOpenXml;
using TKS_Thuc_Tap_V11_Data_Access.Controller.XNK;
using TKS_Thuc_Tap_V11_Data_Access.Entity.Report;
using TKS_Thuc_Tap_V11_Data_Access.Entity.XNK;

namespace TKS_Thuc_Tap_V11_Report
{
    [DataObject]
    public class CReport_Xuat_Kho
    {
        [DataObjectMethod(DataObjectMethodType.Select)]
        public List<CBao_Cao_Chi_Tiet_Xuat> rptReport_Xuat_Kho(long p_lngXuat_Kho_ID)
        {
            var v_objController = new CDM_Xuat_Kho_Controller();
            return v_objController.FQ_123_XK_sp_sel_Report_By_ID(p_lngXuat_Kho_ID);
        }

        public byte[] Export_Excel_Template(
            string p_strTemplate_Path,
            CDM_Xuat_Kho p_objHeader,
            IReadOnlyList<CBao_Cao_Chi_Tiet_Xuat> p_arrDetails)
        {
            if (p_objHeader == null)
                throw new ArgumentNullException(nameof(p_objHeader));
            if (p_arrDetails == null)
                throw new ArgumentNullException(nameof(p_arrDetails));

            ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using var v_objPackage = new ExcelPackage(new FileInfo(p_strTemplate_Path));
            var v_objSheet = v_objPackage.Workbook.Worksheets["TemplatePhieuXuatKho"]
                ?? throw new InvalidOperationException("Không tìm thấy sheet TemplatePhieuXuatKho.");

            const int v_iFirst_Detail_Row = 13;
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
                v_objSheet.InsertRow(23, v_iExtra_Rows, 22);
            }

            DateTime? v_dtmDate = p_objHeader.Ngay_Xuat_Kho;
            v_objSheet.Cells["A2"].Value = v_dtmDate.HasValue
                ? $"Ngày {v_dtmDate.Value:dd} tháng {v_dtmDate.Value:MM} năm {v_dtmDate.Value:yyyy}"
                : "";
            v_objSheet.Cells["A3"].Value = $"Số: {p_objHeader.So_Phieu_Xuat_Kho}";
            v_objSheet.Cells["C8"].Value = p_objHeader.Ten_Kho;
            v_objSheet.Cells["C9"].Value = p_objHeader.Ghi_Chu;

            for (int i = 0; i < p_arrDetails.Count; i++)
            {
                CBao_Cao_Chi_Tiet_Xuat v_objDetail = p_arrDetails[i];
                int v_iRow = v_iFirst_Detail_Row + i;
                v_objSheet.Cells[v_iRow, 1].Value = i + 1;
                v_objSheet.Cells[v_iRow, 2].Value = v_objDetail.Ma_San_Pham;
                v_objSheet.Cells[v_iRow, 3].Value = v_objDetail.Ten_San_Pham;
                v_objSheet.Cells[v_iRow, 6].Value = v_objDetail.SL_Xuat;
                v_objSheet.Cells[v_iRow, 7].Value = v_objDetail.Ten_Don_Vi_Tinh;
            }

            double v_dblTotal_Quantity = p_arrDetails.Sum(v_objDetail => v_objDetail.SL_Xuat);
            int v_iConclusion_Row = 14 + p_arrDetails.Count;
            v_objSheet.Cells[v_iConclusion_Row + 1, 3].Value = v_dblTotal_Quantity;
            v_objSheet.Cells[v_iConclusion_Row + 2, 3].Value =
                CReport_Excel_Template_Utility.Number_To_Vietnamese_Words((decimal)v_dblTotal_Quantity, true);

            return v_objPackage.GetAsByteArray();
        }
    }
}
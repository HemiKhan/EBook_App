using Microsoft.VisualBasic;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using static EBook_Models.App_Models.AppEnum;

namespace EBook_Models.App_Models
{
    public partial class TUser
    {
        public string? Username { get; set; } = null!;
        public string? Token { get; set; }
        public DateTime? TokenCreatedOn { get; set; }
        public DateTime? TokenExpiry { get; set; }
        public DateTime? TokenRevokedOn { get; set; }
        public string? Otp { get; set; }
        public DateTime? OtpExpiry { get; set; }
        public int? OtpStatus { get; set; }
    }

   

    public class CaptchaResponse
    {
        public bool success = false;
        public string challenge_ts = "";
        public string hostname = "";
        public double score = 0.00;
        public string action = "";
        public List<string> error_codes = new List<string>();
    }

    public class ListofErrors
    {
        public string errorcode { get; set; } = "";
        public string errormessage { get; set; } = "";
        public string detailmessage { get; set; } = "";
    }

    #region echarts
    public class ECharts_Result
    {
        public string charttitle { get; set; } = "";
        public string chartid { get; set; } = "";
        public List<ECharts_ResultData> ResultData { get; set; } = new List<ECharts_ResultData>();
    }
    public class ECharts_ResultData
    {
        public bool is_xaxis { get; set; } = true;
        public List<ECharts_ResultList> data { get; set; } = new List<ECharts_ResultList>();
    }
    public class ECharts_ResultList
    {
        public string value { get; set; } = "";
        public string name { get; set; } = "";
        public ECharts_ExtraValues extra { get; set; } = new ECharts_ExtraValues();
    }
    public class ECharts_ExtraValues
    {
        public string hiddenValue { get; set; } = "";
    }
    #endregion echarts

    #region ReportReqResJson
    public class ReportGridColumns
    {
        public int position { get; set; } = 0;
        public string field { get; set; } = "";
        public bool showinexcel { get; set; } = true;
        public string title { get; set; } = "";
        public string excelcolumntype { get; set; } = "";
    }
    public class RequestDataForDetailsTemplate
    {
        public int Id { get; set; } = 0;
        public ReportParams ReportParams { get; set; }
    }
    public class ReportParams
    {
        public int PageIndex { get; set; } = 0;
        public int PageSize { get; set; } = 0;
        private string _SortExpression = "";
        public string SortExpression
        {
            get
            {
                return this._SortExpression;
            }
            set
            {
                this._SortExpression = (value == null ? "" : value);
            }
        }
        private string _FilterClause = "";
        public string FilterClause
        {
            get
            {
                return this._FilterClause;
            }
            set
            {
                this._FilterClause = (value == null ? "" : value);
            }
        }
        public List<ReportFilterObject> ReportFilterObjectList { get; set; } = new List<ReportFilterObject>();
        public List<ReportColumnObject> ReportColumnObjectList { get; set; } = new List<ReportColumnObject>();

    }
    public class kendo_option_data_filter
    {
        public string logic { get; set; } = "and";
        public List<kendo_option_data_filter2> filters { get; set; } = new List<kendo_option_data_filter2>();
    }
    public class kendo_option_data_filter2
    {
        public string logic { get; set; } = "and";
        public List<kendo_option_data_filter_filters> filters { get; set; } = new List<kendo_option_data_filter_filters>();
    }
    public class kendo_option_data_filter_filters
    {
        public string field { get; set; } = "";
        public string operator_ { get; set; } = "";
        public string value { get; set; } = "";
    }
    public class ReportFilterDropDownList
    {
        public string text { get; set; }
        public object value { get; set; }
    }
    public class ReportFilterObject
    {
        private string _Code = "";
        public string Code
        {
            get
            {
                return this._Code;
            }
            set
            {
                this._Code = (value == null ? "" : value);
            }
        }
        private string _Name = "";
        public string Name
        {
            get
            {
                return this._Name;
            }
            set
            {
                this._Name = (value == null ? "" : value);
            }
        }
        public bool IsFilterApplied { get; set; } = false;
        private string _FieldType = "";
        public string FieldType
        {
            get
            {
                return this._FieldType;
            }
            set
            {
                this._FieldType = (value == null ? "" : value.ToLower());
            }
        }
        private string _SRFieldType = "";
        public string SRFieldType
        {
            get
            {
                return this._SRFieldType;
            }
            set
            {
                this._SRFieldType = (value == null ? "" : value.ToLower());
            }
        }
        public List<ReportFilterObjectArry> reportFilterObjectArry { get; set; } = new List<ReportFilterObjectArry>();
        public List<SQLReportFilterObjectArry> sQLReportFilterObjectArry { get; set; } = new List<SQLReportFilterObjectArry>();
    }
    public class ReportFilterObjectArry
    {
        private string _Logic = "";
        public string Logic
        {
            get
            {
                return this._Logic;
            }
            set
            {
                string Ret = "";
                if (value != null)
                {
                    Ret = (value.ToUpper() == "OR" || value.ToUpper() == "AND" ? value.ToUpper() : "");
                }
                this._Logic = Ret;
            }
        }
        private object _Value = "";
        public object Value
        {
            get
            {
                return this._Value;
            }
            set
            {
                this._Value = (value == null ? "" : value);
            }
        }
        private string _Type = "";
        public string Type
        {
            get
            {
                return this._Type;
            }
            set
            {
                this._Type = (value == null ? "" : value.ToLower());
            }
        }
        private string _FieldType = "";
        public string FieldType
        {
            get
            {
                return this._FieldType;
            }
            set
            {
                this._FieldType = (value == null ? "" : value.ToLower());
            }
        }
        private string _SRFieldType = "";
        public string SRFieldType
        {
            get
            {
                return this._SRFieldType;
            }
            set
            {
                this._SRFieldType = (value == null ? "" : value.ToLower());
            }
        }
        public bool IsList { get; set; } = false;
        public int ListType { get; set; } = 0;
        public string Code { get; set; } = "";

    }
    public class SQLReportFilterObjectArry
    {
        private object _Value = "";
        public object Value
        {
            get
            {
                return this._Value;
            }
            set
            {
                this._Value = (value == null ? "" : value);
            }
        }
        private string _Type = "";
        public string Type
        {
            get
            {
                return this._Type;
            }
            set
            {
                this._Type = (value == null ? "" : value.ToLower());
            }
        }

    }
    public class ShowHideReportColumnObject
    {
        public string kendoid { get; set; } = "";
        public string kendofunctionname { get; set; } = "";
        public bool iscollapse { get; set; } = false;
        public List<ReportColumnObject> reportColumnObjectList { get; set; } = new List<ReportColumnObject>();
        public bool IsColumnsIsExists
        {
            get
            {
                bool Ret = false;
                if (reportColumnObjectList?.Find(component => component.IsHidden == false) != null)
                    Ret = true;
                return Ret;
            }
        }
        public bool SetValue
        {
            get
            {
                bool Ret = false;
                if (reportColumnObjectList?.Find(component => component.IsHidden == false && component.IsChecked == true) == null
                    && reportColumnObjectList?.Find(component => component.IsHidden == false && component.IsChecked == false) != null)
                    Ret = true;

                return Ret;
            }
        }
        public string SetValueName
        {
            get
            {
                string Ret = "Uncheck All";
                if (SetValue)
                    Ret = "Check All";

                return Ret;
            }
        }
    }
    public class ReportColumnObject
    {
        private string _Code = "";
        public string Code
        {
            get
            {
                return this._Code;
            }
            set
            {
                this._Code = (value == null ? "" : value);
            }
        }
        private string _Name = "";
        public string Name
        {
            get
            {
                return this._Name;
            }
            set
            {
                this._Name = (value == null ? "" : value);
            }
        }
        public bool IsColumnRequired { get; set; } = true;
        public bool IsHidden { get; set; } = false;
        public bool IsChecked { get; set; } = false;
        public int SortPosition { get; set; } = 0;
        public string uiid { get; set; } = Guid.NewGuid().ToString().ToLower();

    }
    public class ReportResponsePageSetup : ReportResponse
    {
    }
    public class ReportResponseSellerAllocation : ReportResponse
    {
        public bool sellerallocationtlistview { get; set; } = false;
        public bool sellerallocationtlisttabview { get; set; } = false;
        public bool sellerallocationtlisttabedit { get; set; } = false;
        public bool sellerallocationtlisttabadd { get; set; } = false;
        public bool sellerallocationtlisttabdelete { get; set; } = false;
        public bool sellerallocationtmappingtabview { get; set; } = false;
        public bool sellerallocationtmappingtabedit { get; set; } = false;
        public bool sellerallocationtmappingtabadd { get; set; } = false;
        public bool sellerallocationtmappingtabdelete { get; set; } = false;
        public bool usersellerallocationtmappingtabview { get; set; } = false;
        public bool usersellerallocationtmappingtabedit { get; set; } = false;
        public bool usersellerallocationtmappingtabadd { get; set; } = false;
        public bool usersellerallocationtmappingtabdelete { get; set; } = false;
    }

    public class ReportResponse
    {
        public bool response_code { get; set; } = false;
        public string errormsg { get; set; } = "";
        public string errorcode { get; set; } = "";
        public string warningtext { get; set; } = "";
        public Int64 _TotalRowCount = 0;
        public Int64 TotalRowCount
        {
            get
            {
                return this._TotalRowCount;
            }
            set
            {
                this._TotalRowCount = (value == null ? 0 : value);
            }
        }
        public object? ResultData { get; set; } = null;

    }
    #endregion ReportReqResJson

    #region Export To Excel

    public class DownloadLastFile
    {
        public bool isfileavailable { get; set; }
        public string filename { get; set; }
        public string fileext { get; set; }
        public string filedatetime { get; set; }
    }
    public class SetColumnType
    {
        public int columnindex { get; set; } = 0;
        public string columnname { get; set; } = "";
        public string columntype { get; set; } = ExcelColumnType.General;
    }

    #endregion Export To Excel

    public class UpdateAttachmentPath
    {
        public int TA_ID { get; set; }
        public string Path { get; set; }
        public int TD_ID { get; set; }

    }
}

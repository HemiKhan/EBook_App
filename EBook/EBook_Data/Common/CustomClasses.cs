using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Swashbuckle.AspNetCore.Annotations;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.Serialization;
using static EBook_Data.Dtos.AppEnum;

namespace EBook_Data.Common
{   
    #region App Setup
    
    public class Dynamic_SP_Params
    {
        public string ParameterName { get; set; } = "";
        public object? Val { get; set; } = null;
        public bool IsInputType { get; set; } = true;
        public bool IsCustomSetValueType { get; set; } = true;
        private Type _SetValueType = typeof(object);
        public Type SetValueType
        {
            get
            {
                return this._SetValueType;
            }
            set
            {
                this._SetValueType = value;
            }
        }
        public Type GetValueType
        {
            get
            {
                if (this.IsCustomSetValueType)
                    return this._SetValueType;
                else
                    return this.Val.GetType();
            }
        }
        public int Size { get; set; } = -1;
    }
    public class P_ReturnMessage_Result
    {
        public bool ReturnCode { get; set; } = false;
        public string? ReturnText { get; set; } = "";
    }
    public class P_ReturnMessageForJson_Result
    {
        public bool ReturnCode { get; set; } = false;
        public string? ReturnText { get; set; } = "";
        public string? Execution_Error { get; set; } = "";
        public string? Error_Text { get; set; } = "";

    }
    public class SelectDropDownList
    {
        public object code { get; set; }
        public string name { get; set; }
    }
    public class SelectDropDownListWithEncryption
    {
        public int ID { get; set; }
        public string code
        {
            get
            {
                return Crypto.EncryptNumericToStringWithOutNull(this.ID);
            }
        }
        public string name { get; set; }
    }
    public class SelectDropDownListWithEncryptionString
    {
        private string _code = "";
        [SwaggerSchema(ReadOnly = true)]
        public string code
        {
            get
            {
                return this._code;
            }
            set
            {
                this._code = Globals.ConvertDBNulltoNullIfExistsString(value) ?? "";
            }
        }
        public string encryptedcode
        {
            get
            {
                return Crypto.EncryptString(code);
            }
        }
        public string name { get; set; }
    }
    public class Sorting_Result
    {
        public int New_Sort_Value { get; set; }
        public object Sort_ID { get; set; }
        public string Sort_Text { get; set; }
        public int Old_Sort_Value { get; set; }
    }
    public class LoginSaveCookie
    {
        public string UserName { get; set; } = "";
        public string Password { get; set; } = "";
        public bool RememberMe { get; set; } = false;
        public int LocalTimeZone { get; set; } = 0;
        public string LocalTimeZoneName { get; set; } = "";
    }
    public class GetModalDetail
    {
        /// <summary>
        /// Set Value from GetModalSize Struct
        /// </summary>
        public string getmodelsize { get; set; } = AppEnum.GetModalSize.modal_md;
        public string modalheaderclass { get; set; } = "Theme-Header";
        public string modaltitle { get; set; } = "";
        public string onclickmodalclose { get; set; } = "resetmodal('dynamic-modal1')";
        public string modalbodytabletbody { get; set; } = "";
        public string modalfooterclass { get; set; } = "";
        public string modalfootercancelbuttonname { get; set; } = "Cancel";
        public string modalfootersuccessbuttonname { get; set; } = "Change";
        public string modalfootersuccessbuttonclass { get; set; } = "Theme-button";
        public string onclickmodalsuccess { get; set; } = "";
        public List<ModalBodyTypeInfo> modalBodyTypeInfos { get; set; } = null;
    }
    public class ModalBodyTypeInfo
    {
        /// <summary>
        /// Set Value from GetModelBodyType Struct
        /// </summary>
        public string ModelBodyType { get; set; } = null;
        public string LabelColumnClass { get; set; } = "col-4";
        public string FieldColumnClass { get; set; } = "col-8";
        public string LabelName { get; set; } = "";
        public string LabelClass { get; set; } = "fw-light mb-2";
        public bool IsRequired { get; set; } = false;
        public bool IsHidden { get; set; } = false;
        /// <summary>
        /// Set Value from GetInputStringType Struct. Required if ModelBodyType is TRInput
        /// </summary>
        public string GetInputTypeString { get; set; } = null;
        public string PlaceHolder { get; set; } = "";
        public string id { get; set; } = "";
        public string ClassName { get; set; } = "";
        /// <summary>
        /// Required if ModelBodyType is TRInput
        /// </summary>
        public bool issmallformcontrol { get; set; } = true;
        public object value { get; set; } = null;
        public bool isdisabled { get; set; } = false;
        /// <summary>
        /// Set Value from JavascriptValidationType Struct
        /// </summary>
        public string datavalidationtypes { get; set; } = "";
        public List<AttributeList> AttributeList = new List<AttributeList>();
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool issmallformselect { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool isselect { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool ismultiselect { get; set; } = false;
        /// <summary>
        /// Optional when ismultiselect is true
        /// </summary>
        public List<object> listofobj { get; set; } = new List<object>();
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public List<SelectDropDownList> selectLists { get; set; } = null;
        /// <summary>
        /// Required if ModelBodyType is TRSelect
        /// </summary>
        public bool IsSelectOption { get; set; } = true;
        /// <summary>
        /// Required if ModelBodyType is TRTextArea
        /// </summary>
        public int rows { get; set; } = 5;
        /// <summary>
        /// Required if ModelBodyType is TRCheckBox
        /// </summary>
        public bool isratio { get; set; } = false;
        /// <summary>
        /// Required if ModelBodyType is TRCheckBox
        /// </summary>
        public bool ischecked { get; set; } = false;
        /// <summary>
        /// required for mobile and phone and phoneExt
        /// </summary>
        public int noOfInput { get; set; } = 0;
        public bool isMultiInput { get; set; } = false;
        public int inputSize { get; set; } = int.MaxValue;
        public int inputMaxlength { get; set; } = int.MaxValue;
        public string inputTypeForNumber { get; set; } = "";
        public string GetClassName
        {
            get
            {
                string Ret = "";
                if (this.ClassName != "")
                    Ret = this.ClassName;
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRInput)
                    Ret = "w-100 border-1";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRselect)
                    Ret = "w-100 border-1 custom-select";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRTextArea)
                    Ret = "w-100 border-1";
                else if (this.ModelBodyType == AppEnum.GetModelBodyType.TRCheckBox)
                    Ret = "fw-light mb-2 me-2";
                return Ret;
            }
        }

    }
    public class AttributeList
    {
        public string Name { get; set; } = "";
        public object Value { get; set; } = null;
    }

    [AttributeUsage(AttributeTargets.Property)]
    public class ExcludeFromDynamicSPParamsAttribute : Attribute
    {

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
    public class RequestDocs
    {
        [SwaggerSchema(Nullable = false, ReadOnly = true)]
        [JsonIgnore]
        [IgnoreDataMemberAttribute]
        [HideProperty(IsHideSerialize = true)]
        public string path { get; set; } = "";
        [SwaggerSchema(Nullable = false)]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *filename* is Required")]
        [CustomValidationAttribute2(maxlength: 100, minlength: 1, maxlenerrormessage: "*{BaseTypeName}filename* invalid value"
            , minlenerrormessage: "*{BaseTypeName}filename* invalid value"
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}filename* is Required", isshowbasetype: true)]
        public string filename { get; set; } = "";
        private string _fileext = "";
        [SwaggerSchema(Description = "Required", Nullable = false)]
        //[Required(AllowEmptyStrings = false, ErrorMessage = "*{BaseTypeName}fileext* is required")]
        [CustomValidationAttribute2(maxlength: 10, minlength: 1, maxlenerrormessage: "*{BaseTypeName}fileext* invalid value"
            , minlenerrormessage: "*{BaseTypeName}fileext* invalid value"
            , allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}fileext* is Required", isshowbasetype: true)]
        public string fileext
        {
            get
            {
                return this._fileext;
            }
            set
            {
                this._fileext = (value == null ? "" : value.Replace(".", "").ToLower());
            }
        }
        [SwaggerSchema(Description = "Required. On Item Level Only Image Document Type is Acceptable.", Nullable = false, Required = new string[] { "111100 = Document", "111101 = Pickup BOL", "111102 = Client BOL", "111103 = Image", "111106 = Other" })]
        [Range(111100, 111999, ErrorMessage = "Ignore Error: *documenttype* invalid value")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *documenttype* is required")]
        [CustomValidationAttribute2(rangestart: 111100, rangeend: 111999, rangeerrormessage: "*{BaseTypeName}documenttype* invalid value"
            , rangeapplicable: true, isshowbasetype: true
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}documenttype* is Required")]
        public int documenttype { get; set; } = 0;
        private string _description = "";
        [SwaggerSchema(Description = "Optional", Nullable = true)]
        public string description
        {
            get
            {
                return this._description;
            }
            set
            {
                this._description = (value == null ? "" : value);
            }
        }
        [SwaggerSchema(Description = "Default is 128100 = Order Level Attachment", Nullable = false, Required = new string[] { "128100 = Order Level Attachment", "128101 = Item Level Attachment", "128102 = Item Scan Level Attachment" })]
        [Range(128100, 128102, ErrorMessage = "Ignore Error: *attachmenttype* invalid value")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *attachmenttype* is required")]
        [CustomValidationAttribute2(rangestart: 128100, rangeend: 128102, rangeerrormessage: "*{BaseTypeName}attachmenttype* invalid value"
            , rangeapplicable: true, isshowbasetype: true
            , ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}attachmenttype* is Required")]
        public int attachmenttype { get; set; } = 128100;
        [SwaggerSchema(Description = "Optional. Default value is true", Nullable = false)]
        public bool ispublic { get; set; } = true;
        private string _filebase64 = "";
        [SwaggerSchema(Description = "Required. File Base64 is required", Nullable = false)]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ignore Error: *filebase64* is required")]
        [CustomValidationAttribute2(ignorenull: false, allowemptystring: false, allowemptystringerrormessage: "*{BaseTypeName}filebase64* invalid value", isshowbasetype: true)]
        public string filebase64
        {
            get
            {
                return this._filebase64;
            }
            set
            {
                this._filebase64 = Globals.ExtractBase64String(value) ?? "";
            }
        }
        private string _filepath = "";
        [SwaggerSchema(Nullable = true, ReadOnly = true)]
        public string filepath
        {
            get
            {
                return this._filepath;
            }
            set
            {
                this._filepath = (value == null ? "" : value);
            }
        }
        [SwaggerSchema(Nullable = false, ReadOnly = true)]
        [JsonIgnore]
        [IgnoreDataMemberAttribute]
        [HideProperty(IsHideSerialize = true)]
        public int filesize { get; set; } = 0;
    }
    #endregion App Setup

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
}

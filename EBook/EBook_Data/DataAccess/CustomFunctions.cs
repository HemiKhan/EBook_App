using EBook_Data.Common;
using EBook_Models.App_Models;
using EBook_Models.Data_Model;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EBook_Data.DataAccess
{
    public class CustomFunctions
    {
        /// <summary>
        /// Get Modal Input Field For Table Row
        /// </summary>
        /// <param name="GetInputTypeString">Set from GetInputStringType Struct</param>
        public static string GetStandardTRInputString(string LabelName = "", bool IsRequired = false, bool IsHidden = false, string GetInputTypeString = AppEnum.GetInputStringType.text, string PlaceHolder = "", string id = "", object value = null, bool isdisabled = false, List<AttributeList> AttributeList = null)
        {
            return GetTRInputString(LabelColumnClass: "col-4", FieldColumnClass: "col-8", LabelName: LabelName, LabelClass: "fw-light mb-2", IsRequired: IsRequired, IsHidden: IsHidden, GetInputTypeString: GetInputTypeString, PlaceHolder: PlaceHolder, id: id, ClassName: "w-100 border-1", issmallformcontrol: true, value: value, isdisabled: isdisabled, datavalidationtypes: "", AttributeList: AttributeList);
        }
        /// <summary>
        /// Get Modal Input Field For Table Row
        /// </summary>
        /// <param name="GetInputTypeString">Set from GetInputStringType Struct</param>
        /// <param name="datavalidationtypes">Set from JavascriptValidationType Struct</param>
        public static string GetTRInputString(string LabelColumnClass = "col-4", string FieldColumnClass = "col-8", string LabelName = "", string LabelClass = "fw-light mb-2", bool IsRequired = false, bool IsHidden = false, string GetInputTypeString = AppEnum.GetInputStringType.text, string PlaceHolder = "", string id = "", string ClassName = "w-100 border-1", bool issmallformcontrol = true, object value = null, bool isdisabled = false, string datavalidationtypes = "", List<AttributeList> AttributeList = null, int noOfInput = 0, bool isMultiInput = false, int inputSize = int.MaxValue, int inputMaxlength = int.MaxValue, string inputTypeForNumber = "")
        {
            string InputTypeString = (GetInputTypeString == null ? AppEnum.GetInputStringType.text : GetInputTypeString);
            if (Information.IsDBNull(value))
                value = null;
            value = (value == null ? "" : value);
            string RequiredText = "";
            if (IsRequired == true)
                RequiredText = "<span class=\"text-red\"> *</span>";
            string FormControl = "form-control";
            if (issmallformcontrol)
                FormControl = "form-control-sm";

            string datavalidationtypesattribute = "";
            datavalidationtypesattribute = (datavalidationtypes == "" ? "" : "data-validation-types=" + "\"" + datavalidationtypes + "\"");

            string AttributeString = "";
            if (AttributeList != null)
            {
                if (AttributeList.Count > 0)
                {
                    for (int i = 0; i <= AttributeList.Count - 1; i++)
                    {
                        AttributeString += " " + AttributeList[i].Name + "=" + AttributeList[i].Value + " ";
                    }
                }
            }

            var IsHiddenText = "";
            if (IsHidden)
            {
                IsHiddenText = "d-none";
            }

            string HtmlString = "";
            HtmlString = string.Format("{0} <tr class=\"{1}\">", HtmlString, IsHiddenText);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, LabelColumnClass);
            HtmlString = string.Format("{0} <h6 class=\"{1}\">{2}:{3}</h6>", HtmlString, LabelClass, LabelName, RequiredText);
            HtmlString = string.Format("{0} </td>", HtmlString);
            if (isMultiInput == true)
            {
                string display = "display:flex";

                HtmlString = string.Format("{0} <td  class=\"{1}\" style=\"{2}\">", HtmlString, FieldColumnClass, display);
            }
            else
            {
                HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, FieldColumnClass);
            }

            if (isMultiInput == true)
            {
                string? idforExt = "";
                string margin = "margin-right:20px;";
                int countListIndex = 0;
                string newValue = value.ToString().Trim();

                List<string> ListValues = new List<string>();

                if (newValue.Length == 10)
                {
                    ListValues.Add(newValue.Substring(0, 3));
                    ListValues.Add(newValue.Substring(3, 3));
                    ListValues.Add(newValue.Substring(6, 4));
                }
                else if (newValue.Length >= 14)
                {
                    ListValues.Add(newValue.Substring(0, 3));
                    ListValues.Add(newValue.Substring(3, 3));
                    ListValues.Add(newValue.Substring(6, 4));
                    ListValues.Add(newValue.Substring(10, 4));
                }


                if (inputTypeForNumber.ToLower().Trim() == "phone" && newValue.Length == 10)
                {
                    ListValues.Add("");
                }
                if (inputTypeForNumber.ToLower().Trim() == "phone")
                {
                    noOfInput += 4;
                }
                else
                {
                    noOfInput += 2;
                }

                for (int i = 0; i < noOfInput; i++)
                {
                    if (i == noOfInput - 1 && inputTypeForNumber.ToLower().Trim() != "phone")
                    {
                        inputSize += 1;
                        inputMaxlength += 1;
                        PlaceHolder = "XXXX";
                    }
                    else if (i == noOfInput - 3 && inputTypeForNumber.ToLower().Trim() == "phone")
                    {
                        inputSize += 1;
                        inputMaxlength += 1;
                        PlaceHolder = "XXXX";
                    }

                    if (i % 2 != 0)
                    {

                        string ClassNameforDisable = "form-control  widthfordisabple";


                        if (i == noOfInput - 2 && inputTypeForNumber.ToLower().Trim() == "phone")
                        {
                            newValue = "EXT";
                            PlaceHolder = "Ext";
                            idforExt = "idExt";
                            isdisabled = true;

                        }
                        else
                        {
                            newValue = "-";
                            isdisabled = true;
                        }

                        HtmlString = string.Format("{0} <input   type=\"{1}\" placeholder=\"{2}\" class=\"{3} {4} {10} \" id=\"{5}\" value=\"{6}\" {7} {8} {9} size=\"{11}\" style=\"{12}\" maxlength=\"{13}\"  />",
                       HtmlString, InputTypeString, PlaceHolder, FormControl, ClassNameforDisable, "_", newValue, (isdisabled == true ? "disabled" : ""), AttributeString
                    , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : ""), inputSize, margin, inputMaxlength);
                    }
                    else
                    {

                        isdisabled = false;
                        string? newid = string.IsNullOrEmpty(id) ? id : id + "_" + i.ToString();
                        HtmlString = string.Format("{0} <input   type=\"{1}\" placeholder=\"{2}\" class=\"{3} {4} {10} \" id=\"{5}\" value=\"{6}\" {7} {8} {9} size=\"{11}\" style=\"{12}\" maxlength=\"{13}\"  />",
                    HtmlString, InputTypeString, PlaceHolder, FormControl, ClassName, (idforExt != "" ? idforExt : newid), (ListValues.Count > 0 ? ListValues[countListIndex] : ""), (isdisabled == true ? "disabled" : ""), AttributeString
                    , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : ""), inputSize, margin, inputMaxlength);
                        countListIndex++;
                    }

                }

            }
            else
            {
                HtmlString = string.Format("{0} <input type=\"{1}\" placeholder=\"{2}\" class=\"{3} {4} {10} \" id=\"{5}\" value=\"{6}\" {7} {8} {9}/>",
                HtmlString, InputTypeString, PlaceHolder, FormControl, ClassName, id, value, (isdisabled == true ? "disabled" : ""), AttributeString
                , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : ""));
            }

            if (datavalidationtypesattribute != "")
                HtmlString = string.Format("{0} <span class=\"validationError error\"></span>", HtmlString);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} </tr>", HtmlString);

            return HtmlString;
        }
        public static string GetStandardTRselectString(string LabelName = "", bool IsRequired = false, bool IsHidden = false, string PlaceHolder = "", string id = "", List<SelectDropDownList> selectLists = null, object value = null, bool isdisabled = false, List<AttributeList> AttributeList = null)
        {
            return GetTRselectString(LabelColumnClass: "col-4", FieldColumnClass: "col-8", LabelName: LabelName, LabelClass: "fw-light mb-2", IsRequired: IsRequired, IsHidden: IsHidden, PlaceHolder: PlaceHolder, id: id, ClassName: "w-100 border-1 custom-select", issmallformselect: true, isselect: true, selectLists: selectLists, IsSelectOption: true, value: value, isdisabled: isdisabled, datavalidationtypes: "", AttributeList: AttributeList);
        }
        /// <summary>
        /// Get Modal Select/DropDown Field For Table Row
        /// </summary>
        /// <param name="datavalidationtypes">Set from JavascriptValidationType Struct</param>
        public static string GetTRselectString(string LabelColumnClass = "col-4", string FieldColumnClass = "col-8", string LabelName = "", string LabelClass = "fw-light mb-2", bool IsRequired = false, bool IsHidden = false, string PlaceHolder = "", string id = "", string ClassName = "w-100 border-1 custom-select", bool issmallformselect = true, bool isselect = true, List<SelectDropDownList> selectLists = null, bool IsSelectOption = true, object value = null, bool isdisabled = false, string datavalidationtypes = "", List<AttributeList> AttributeList = null, bool ismultiselect = false, List<object>? listofobj = null)
        {
            if (listofobj == null)
                listofobj = new List<object>();

            if (Information.IsDBNull(value))
                value = null;
            value = (value == null ? "" : value);
            string RequiredText = "";
            if (IsRequired == true)
                RequiredText = "<span class=\"text-red\"> *</span>";
            string FormSelect = "form-select";
            if (issmallformselect)
                FormSelect = "form-select-sm";

            string datavalidationtypesattribute = "";
            datavalidationtypesattribute = (datavalidationtypes == "" ? "" : "data-validation-types=" + "\"" + datavalidationtypes + "\"");

            string AttributeString = "";
            if (AttributeList != null)
            {
                if (AttributeList.Count > 0)
                {
                    for (int i = 0; i <= AttributeList.Count - 1; i++)
                    {
                        AttributeString += " " + AttributeList[i].Name + "=" + AttributeList[i].Value + " ";
                    }
                }
            }

            var IsHiddenText = "";
            if (IsHidden)
            {
                IsHiddenText = "d-none";
            }


            string HtmlString = "";
            HtmlString = string.Format("{0} <tr class=\"{1}\">", HtmlString, IsHiddenText);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, LabelColumnClass);
            HtmlString = string.Format("{0} <h6 class=\"{1}\">{2}:{3}</h6>", HtmlString, LabelClass, LabelName, RequiredText);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, FieldColumnClass);
            HtmlString = string.Format("{0} <select placeholder=\"{1}\" class=\"{2} {3} {4} {9}\" id=\"{5}\" {6} {7} {8}>",
                HtmlString, PlaceHolder, (isselect == true ? "select2" : ""), FormSelect, ClassName, id, (isdisabled == true ? "disabled" : ""), AttributeString
                , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : ""));

            string selectoptions = "";
            bool isvalueselected = false;
            if (selectLists != null)
            {
                for (var i = 0; i <= selectLists.Count - 1; i++)
                {
                    if ((selectLists[i].code.ToString() == value.ToString() && ismultiselect == false) || (listofobj.Any(a => a.ToString().ToLower().Trim() == selectLists[i].code.ToString().ToLower().Trim()) && ismultiselect))
                        selectoptions = string.Format("{0} <option selected value=\"{1}\">{2}</option>", selectoptions, selectLists[i].code, selectLists[i].name);
                    else
                        selectoptions = string.Format("{0} <option value=\"{1}\">{2}</option>", selectoptions, selectLists[i].code, selectLists[i].name);
                }
            }
            if (IsSelectOption == true)
                HtmlString = string.Format("{0} <option {3} value=\"{1}\">{2}</option> {4}", HtmlString, "", "[Select Option]", (isvalueselected == false ? "selected" : ""), selectoptions);

            HtmlString = string.Format("{0} </select>", HtmlString);

            if (datavalidationtypesattribute != "")
                HtmlString = string.Format("{0} <span class=\"validationError error\"></span>", HtmlString);

            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} </tr>", HtmlString);

            return HtmlString;
        }
        public static string GetStandardTRTextAreaString(string LabelName = "", bool IsRequired = false, string PlaceHolder = "", string id = "", object value = null, bool isdisabled = false, List<AttributeList> AttributeList = null)
        {
            return GetTRTextAreaString(LabelColumnClass: "col-4", FieldColumnClass: "col-8", LabelName: LabelName, LabelClass: "fw-light mb-2", IsRequired: IsRequired, rows: 5, PlaceHolder: PlaceHolder, id: id, ClassName: "w-100 border-1", value: value, isdisabled: isdisabled, datavalidationtypes: "", AttributeList: AttributeList);
        }
        /// <summary>
        /// Get Modal TextArea Field For Table Row
        /// </summary>
        /// <param name="datavalidationtypes">Set from JavascriptValidationType Struct</param>
        public static string GetTRTextAreaString(string LabelColumnClass = "col-4", string FieldColumnClass = "col-8", string LabelName = "", string LabelClass = "fw-light mb-2", bool IsRequired = false, int rows = 5, string PlaceHolder = "", string id = "", string ClassName = "w-100 border-1", object value = null, bool isdisabled = false, string datavalidationtypes = "", List<AttributeList> AttributeList = null)
        {
            if (Information.IsDBNull(value))
                value = null;
            value = (value == null ? "" : value);
            string RequiredText = "";
            if (IsRequired == true)
                RequiredText = "<span class=\"text-red\"> *</span>";
            string FormControl = ""; // "form-control";
            //if (issmallformcontrol)
            //    FormControl = "form-control-sm";

            string datavalidationtypesattribute = "";
            datavalidationtypesattribute = (datavalidationtypes == "" ? "" : "data-validation-types=" + "\"" + datavalidationtypes + "\"");

            string AttributeString = "";
            if (AttributeList != null)
            {
                if (AttributeList.Count > 0)
                {
                    for (int i = 0; i <= AttributeList.Count - 1; i++)
                    {
                        AttributeString += " " + AttributeList[i].Name + "=" + AttributeList[i].Value + " ";
                    }
                }
            }

            string HtmlString = "";
            HtmlString = string.Format("{0} <tr>", HtmlString);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, LabelColumnClass);
            HtmlString = string.Format("{0} <h6 class=\"{1}\">{2}:{3}</h6>", HtmlString, LabelClass, LabelName, RequiredText);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, FieldColumnClass);
            HtmlString = string.Format("{0} <textarea rows=\"{1}\" placeholder=\"{2}\" class=\"{3} {4} {10}\" id=\"{5}\" {7} {8} {9}>{6}</textarea>",
                HtmlString, rows, PlaceHolder, FormControl, ClassName, id, value, (isdisabled == true ? "disabled" : ""), AttributeString
                , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : ""));
            if (datavalidationtypesattribute != "")
                HtmlString = string.Format("{0} <span class=\"validationError error\"></span>", HtmlString);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} </tr>", HtmlString);

            return HtmlString;
        }
        public static string GetStandardTRCheckBoxString(string LabelName = "", bool IsRequired = false, bool isratio = false, bool ischecked = false, string id = "", bool isdisabled = false, List<AttributeList> AttributeList = null)
        {
            return GetTRCheckBoxString(LabelColumnClass: "col-4", FieldColumnClass: "col-8", LabelName: LabelName, LabelClass: "fw-light mb-2", IsRequired: IsRequired, isratio: isratio, ischecked: ischecked, id: id, ClassName: "fw-light mb-2 me-2", isdisabled: isdisabled, datavalidationtypes: "", AttributeList: AttributeList);
        }
        /// <summary>
        /// Get Modal CheckBox/ Ratio Button Field For Table Row
        /// </summary>
        /// <param name="datavalidationtypes">Set from JavascriptValidationType Struct</param>
        public static string GetTRCheckBoxString(string LabelColumnClass = "col-4", string FieldColumnClass = "col-8", string LabelName = "", string LabelClass = "fw-light mb-2", bool IsRequired = false, bool isratio = false, bool ischecked = false, string id = "", string ClassName = "fw-light mb-2 me-2", bool isdisabled = false, string datavalidationtypes = "", List<AttributeList> AttributeList = null)
        {
            string InputTypeString = (isratio == true ? AppEnum.GetInputStringType.radio : AppEnum.GetInputStringType.checkbox);
            string RequiredText = "";
            if (IsRequired == true)
                RequiredText = "<span class=\"text-red\"> *</span>";

            string datavalidationtypesattribute = "";
            datavalidationtypesattribute = (datavalidationtypes == "" ? "" : "data-validation-types=" + "\"" + datavalidationtypes + "\"");

            string AttributeString = "";
            if (AttributeList != null)
            {
                if (AttributeList.Count > 0)
                {
                    for (int i = 0; i <= AttributeList.Count - 1; i++)
                    {
                        AttributeString += " " + AttributeList[i].Name + "=" + AttributeList[i].Value + " ";
                    }
                }
            }

            string HtmlString = "";
            HtmlString = string.Format("{0} <tr>", HtmlString);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, LabelColumnClass);
            HtmlString = string.Format("{0} <h6 class=\"{1}\">{2}:{3}</h6>", HtmlString, LabelClass, LabelName, RequiredText);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} <td class=\"{1}\">", HtmlString, FieldColumnClass);
            HtmlString = string.Format("{0} <input type=\"{1}\" class=\"{2} {8}\" id=\"{3}\" {4} {5} {6} {7}/>",
                HtmlString, InputTypeString, ClassName, id, (isdisabled == true ? "disabled" : ""), AttributeString, (ischecked == true ? "checked" : "")
                , datavalidationtypesattribute, (datavalidationtypesattribute == "" ? "custom-validation" : "")); ;
            if (datavalidationtypesattribute != "")
                HtmlString = string.Format("{0} <span class=\"validationError error\"></span>", HtmlString);
            HtmlString = string.Format("{0} </td>", HtmlString);
            HtmlString = string.Format("{0} </tr>", HtmlString);

            return HtmlString;
        }
        /// <summary>
        /// Get Modal
        /// </summary>
        /// <param name="getmodelsize">Set from GetModalSize Struct</param>
        public static string GetModal(string getmodelsize = null, string modalheaderclass = "Theme-Header", string modaltitle = "", string onclickmodalclose = "resetmodal('dynamic-modal1')", string modalbodytabletbody = "", string modalfooterclass = "", string modalfootercancelbuttonname = "Cancel", string modalfootersuccessbuttonname = "Change", string modalfootersuccessbuttonclass = "Theme-button", string onclickmodalsuccess = "")
        {
            string modelsize = (getmodelsize == null ? AppEnum.GetModalSize.modal_md : getmodelsize);
            string HtmlString = "";
            HtmlString = string.Format("{0} <div class=\"modal-dialog {1} modal-dialog-scrollable\">", HtmlString, modelsize);
            HtmlString = string.Format("{0} <div class=\"modal-content\">", HtmlString);
            HtmlString = string.Format("{0} <div class=\"modal-header modal-colored-header {1}\">", HtmlString, modalheaderclass);
            HtmlString = string.Format("{0} <h4 class=\"modal-title\" id=\"title_modal\">{1}</h4>", HtmlString, modaltitle);
            HtmlString = string.Format("{0} <button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"modal\" onclick=\"{1};\" aria-label=\"Close\"></button>", HtmlString, onclickmodalclose);
            HtmlString = string.Format("{0} </div>", HtmlString);
            HtmlString = string.Format("{0} <div class=\"modal-body\">", HtmlString);
            HtmlString = string.Format("{0} <table class=\"table-sm table-borderless mb-0 v-middle w-100\">", HtmlString);
            HtmlString = string.Format("{0} <tbody>", HtmlString);

            HtmlString = string.Format("{0} {1}", HtmlString, modalbodytabletbody);

            HtmlString = string.Format("{0} </tbody>", HtmlString);
            HtmlString = string.Format("{0} </table>", HtmlString);
            HtmlString = string.Format("{0} ", HtmlString);
            HtmlString = string.Format("{0} </div>", HtmlString);
            HtmlString = string.Format("{0} <div class=\"modal-footer {1}\">", HtmlString, modalfooterclass);
            HtmlString = string.Format("{0} <button type=\"button\" class=\"btn btn-light-danger text-danger font-weight-medium\" data-bs-dismiss=\"modal\" onclick=\"{1};\">{2}</button>", HtmlString, onclickmodalclose, modalfootercancelbuttonname);
            HtmlString = string.Format("{0} <button type=\"button\" class=\"btn {3} font-weight-medium\" onclick=\"{2};\">{1}</button>", HtmlString, modalfootersuccessbuttonname, onclickmodalsuccess, modalfootersuccessbuttonclass);
            HtmlString = string.Format("{0} </div>", HtmlString);
            HtmlString = string.Format("{0} </div>", HtmlString);
            HtmlString = string.Format("{0} </div>", HtmlString);
            return HtmlString;
        }
        public static string GetModalWithBody(GetModalDetail getModalDetail)
        {
            string HtmlString = "";
            string BodyHtmlString = getModalDetail.modalbodytabletbody;
            List<ModalBodyTypeInfo> modalBodyTypeInfos = getModalDetail.modalBodyTypeInfos;

            if (modalBodyTypeInfos != null)
            {
                BodyHtmlString = "";
                for (int i = 0; i < modalBodyTypeInfos.Count; i++)
                {
                    ModalBodyTypeInfo obj = modalBodyTypeInfos[i];
                    if (obj.ModelBodyType == AppEnum.GetModelBodyType.TRInput)
                    {
                        BodyHtmlString += GetTRInputString(LabelColumnClass: obj.LabelColumnClass, FieldColumnClass: obj.FieldColumnClass, LabelName: obj.LabelName, LabelClass: obj.LabelClass
                            , IsRequired: obj.IsRequired, IsHidden: obj.IsHidden, GetInputTypeString: obj.GetInputTypeString, PlaceHolder: obj.PlaceHolder, id: obj.id, ClassName: obj.GetClassName
                            , issmallformcontrol: obj.issmallformcontrol, value: obj.value, isdisabled: obj.isdisabled, datavalidationtypes: obj.datavalidationtypes, AttributeList: obj.AttributeList
                            , obj.noOfInput, obj.isMultiInput, obj.inputSize, obj.inputMaxlength, obj.inputTypeForNumber);
                    }
                    else if (modalBodyTypeInfos[i].ModelBodyType == AppEnum.GetModelBodyType.TRselect)
                    {
                        BodyHtmlString += GetTRselectString(LabelColumnClass: obj.LabelColumnClass, FieldColumnClass: obj.FieldColumnClass, LabelName: obj.LabelName, LabelClass: obj.LabelClass
                            , IsRequired: obj.IsRequired, IsHidden: obj.IsHidden, PlaceHolder: obj.PlaceHolder, id: obj.id, ClassName: obj.GetClassName, selectLists: obj.selectLists
                            , issmallformselect: obj.issmallformselect, value: obj.value, isdisabled: obj.isdisabled, datavalidationtypes: obj.datavalidationtypes, AttributeList: obj.AttributeList, ismultiselect: obj.ismultiselect, listofobj: obj.listofobj, isselect: obj.isselect);
                    }
                    else if (modalBodyTypeInfos[i].ModelBodyType == AppEnum.GetModelBodyType.TRTextArea)
                    {
                        BodyHtmlString += GetTRTextAreaString(LabelColumnClass: obj.LabelColumnClass, FieldColumnClass: obj.FieldColumnClass, LabelName: obj.LabelName, LabelClass: obj.LabelClass
                            , IsRequired: obj.IsRequired, rows: obj.rows, PlaceHolder: obj.PlaceHolder, id: obj.id, ClassName: obj.GetClassName
                            , value: obj.value, isdisabled: obj.isdisabled, datavalidationtypes: obj.datavalidationtypes, AttributeList: obj.AttributeList);
                    }
                    else if (modalBodyTypeInfos[i].ModelBodyType == AppEnum.GetModelBodyType.TRCheckBox)
                    {
                        BodyHtmlString += GetTRCheckBoxString(LabelColumnClass: obj.LabelColumnClass, FieldColumnClass: obj.FieldColumnClass, LabelName: obj.LabelName, LabelClass: obj.LabelClass
                            , IsRequired: obj.IsRequired, isratio: obj.isratio, ischecked: obj.ischecked, id: obj.id, ClassName: obj.GetClassName
                            , isdisabled: obj.isdisabled, datavalidationtypes: obj.datavalidationtypes, AttributeList: obj.AttributeList);
                    }
                }
            }

            HtmlString = GetModal(getmodelsize: getModalDetail.getmodelsize, modalheaderclass: getModalDetail.modalheaderclass, modaltitle: getModalDetail.modaltitle
                , onclickmodalclose: getModalDetail.onclickmodalclose, modalbodytabletbody: BodyHtmlString, modalfooterclass: getModalDetail.modalfooterclass
                , modalfootercancelbuttonname: getModalDetail.modalfootercancelbuttonname, modalfootersuccessbuttonname: getModalDetail.modalfootersuccessbuttonname
                , modalfootersuccessbuttonclass: getModalDetail.modalfootersuccessbuttonclass, onclickmodalsuccess: getModalDetail.onclickmodalsuccess);

            return HtmlString;
        }


        public static string SetOrders(string StrOrder, bool Seperation_Logic_Is_Text)
        {
            StrOrder = StrOrder.Replace("'", "");
            StrOrder = StrOrder.Replace(',', Strings.Chr(13));
            StrOrder = StrOrder.Replace(' ', Strings.Chr(13));
            StrOrder = StrOrder.Replace(Strings.Chr(10), Strings.Chr(13));
            string StrRet = "";
            string[] A;
            A = StrOrder.Split(Strings.Chr(13));
            foreach (var OrderNo in A)
            {
                if (OrderNo.Trim() != "")
                {
                    if (StrRet == "")
                    {
                        if (Seperation_Logic_Is_Text)
                            StrRet = string.Format("'{0}'", OrderNo.Trim());
                        else
                            StrRet = string.Format("{0}", OrderNo.Trim());
                    }
                    else if (Seperation_Logic_Is_Text)
                        StrRet = string.Format("{0},'{1}'", StrRet, OrderNo.Trim());
                    else
                        StrRet = string.Format("{0},{1}", StrRet, OrderNo.Trim());
                }
            }
            if (!Seperation_Logic_Is_Text)
            {
            }
            return StrRet;
        }
        public static void SetReportFilterClause(ref ReportParams reportParams)
        {
            string FilterClause = " ";
            for (int i = 0; i <= reportParams.ReportFilterObjectList.Count - 1; i++)
            {
                List<SQLReportFilterObjectArry> ListSQLReportFilterObjectArry = new List<SQLReportFilterObjectArry>();
                string TempFilterClause = " ";
                for (int z = 0; z <= reportParams.ReportFilterObjectList[i].reportFilterObjectArry.Count - 1; z++)
                {
                    SQLReportFilterObjectArry sQLReportFilterObjectArry = new SQLReportFilterObjectArry();
                    GetSQLReportFilterOperator(ref sQLReportFilterObjectArry, reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z]);
                    ListSQLReportFilterObjectArry.Add(sQLReportFilterObjectArry);
                    string code = reportParams.ReportFilterObjectList[i].Code;
                    if (reportParams.ReportFilterObjectList[i].SRFieldType == AppEnum.KendoGridFilterSRFieldType.LowerString && reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Value.ToString() != "")
                    {
                        code = $"lower({reportParams.ReportFilterObjectList[i].Code})";
                    }
                    else if (reportParams.ReportFilterObjectList[i].SRFieldType == AppEnum.KendoGridFilterSRFieldType.UpperString && reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Value.ToString() != "")
                    {
                        code = $"upper({reportParams.ReportFilterObjectList[i].Code})";
                    }
                    else if (reportParams.ReportFilterObjectList[i].SRFieldType == AppEnum.KendoGridFilterSRFieldType.Date)
                    {
                        code = $"cast({reportParams.ReportFilterObjectList[i].Code} as date)";
                    }
                    if (reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Type == AppEnum.KendoGridFilterType.isnullorempty || reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Type == AppEnum.KendoGridFilterType.isnotnullorempty)
                        code = $"isnull({code},'')";

                    if (z == 0)
                    {
                        TempFilterClause = $" {code} {sQLReportFilterObjectArry.Type} {sQLReportFilterObjectArry.Value} ";
                    }
                    else
                    {
                        TempFilterClause += $" {reportParams.ReportFilterObjectList[i].reportFilterObjectArry[z].Logic} {code} {sQLReportFilterObjectArry.Type} {sQLReportFilterObjectArry.Value} ";
                    }
                }
                if (TempFilterClause.Trim() != "")
                    FilterClause += $" AND ({TempFilterClause}) ";

                reportParams.ReportFilterObjectList[i].sQLReportFilterObjectArry = ListSQLReportFilterObjectArry;
            }
            reportParams.FilterClause = FilterClause;

        }
        public static void GetSQLReportFilterOperator(ref SQLReportFilterObjectArry sQLReportFilterObjectArry, ReportFilterObjectArry reportFilterObjectArry)
        {
            sQLReportFilterObjectArry = new SQLReportFilterObjectArry();
            object val = reportFilterObjectArry.Value;
            if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.Date)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "1900-01-01";
                else if (Information.IsDate(reportFilterObjectArry.Value))
                    val = Convert.ToDateTime(reportFilterObjectArry.Value.ToString()).ToString("yyyy-MM-dd");
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.Datetime)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "1900-01-01";
                else if (Information.IsDate(reportFilterObjectArry.Value))
                    val = Convert.ToDateTime(reportFilterObjectArry.Value.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.Float)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = 0.00;
                else if (Information.IsNumeric(reportFilterObjectArry.Value))
                    val = Convert.ToDouble(reportFilterObjectArry.Value.ToString());
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.Int)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = 0;
                else if (Information.IsNumeric(reportFilterObjectArry.Value))
                    val = Convert.ToInt64(reportFilterObjectArry.Value.ToString());
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.LowerString)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "";
                else
                    val = reportFilterObjectArry.Value.ToString().ToLower();
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.UpperString)
            {
                if (reportFilterObjectArry.Value.ToString() == "")
                    val = "";
                else
                    val = reportFilterObjectArry.Value.ToString().ToUpper();
            }
            else if (reportFilterObjectArry.SRFieldType == AppEnum.KendoGridFilterSRFieldType.Boolean)
            {
                if (Convert.ToBoolean(reportFilterObjectArry.Value.ToString()))
                    val = 1;
                else
                    val = 0;
            }

            if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.inlistfilter || reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notinlistfilter)
            {
                if (val.ToString() == "")
                    val = "''";
                else
                    val = SetOrders(val.ToString(), true);
            }

            if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.contains)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'%{val}%'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.doesnotcontain)
            {
                sQLReportFilterObjectArry.Type = " not like ";
                sQLReportFilterObjectArry.Value = $"'%{val}%'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notequal && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Date && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Boolean && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " not in ";
                sQLReportFilterObjectArry.Value = $"('{val}')";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notequal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " not in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notequal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Boolean)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = val;
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notequal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Date)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = $"'{val}'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.equal && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Date && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Boolean && reportFilterObjectArry.FieldType != AppEnum.KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"('{val}')";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.equal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.equal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Boolean)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = val;
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.equal && reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Date)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = $"'{val}'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.startswith)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'{val}%'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.endswith)
            {
                sQLReportFilterObjectArry.Type = " like ";
                sQLReportFilterObjectArry.Value = $"'%{val}'";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isnull)
            {
                sQLReportFilterObjectArry.Type = " is ";
                sQLReportFilterObjectArry.Value = $"null";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isnotnull)
            {
                sQLReportFilterObjectArry.Type = " is not ";
                sQLReportFilterObjectArry.Value = $"null";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.orderno)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isempty)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isnotempty)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isnullorempty)
            {
                sQLReportFilterObjectArry.Type = " = ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isnotnullorempty)
            {
                sQLReportFilterObjectArry.Type = " <> ";
                sQLReportFilterObjectArry.Value = $"''";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isequalorgreather)
            {
                sQLReportFilterObjectArry.Type = " >= ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.greather)
            {
                sQLReportFilterObjectArry.Type = " > ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.isequalorless)
            {
                sQLReportFilterObjectArry.Type = " <= ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.less)
            {
                sQLReportFilterObjectArry.Type = " < ";
                sQLReportFilterObjectArry.Value = (reportFilterObjectArry.FieldType == AppEnum.KendoGridFilterFieldType.Number ? val : $"'{val}'");
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.notinlistfilter)
            {
                sQLReportFilterObjectArry.Type = " not in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
            else if (reportFilterObjectArry.Type == AppEnum.KendoGridFilterType.inlistfilter)
            {
                sQLReportFilterObjectArry.Type = " in ";
                sQLReportFilterObjectArry.Value = $"({val})";
            }
        }
        public static void GetKendoFilter(ref ReportParams _ReportParams, ref List<Dynamic_SP_Params> List_Dynamic_SP_Params, PublicClaimObjects _PublicClaimObjects, bool IsUserNameSet)
        {
            ReportResponse reportResponse = new ReportResponse();
            SetReportFilterClause(ref _ReportParams);

            Int32 pagesize = Convert.ToInt32(_ReportParams.PageSize);
            Int32 pageindex = Convert.ToInt32(_ReportParams.PageIndex);
            string sortExpression = _ReportParams.SortExpression;

            List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PageIndex";
            Dynamic_SP_Params.Val = pageindex;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "PageSize";
            Dynamic_SP_Params.Val = pagesize;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "SortExpression";
            Dynamic_SP_Params.Val = sortExpression;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "FilterClause";
            Dynamic_SP_Params.Val = _ReportParams.FilterClause;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "TotalRowCount";
            Dynamic_SP_Params.Val = 0;
            Dynamic_SP_Params.IsInputType = false;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "TimeZoneID";
            Dynamic_SP_Params.Val = 13;
            //if (_PublicClaimObjects.P_Get_User_Info_Class != null)
            //    Dynamic_SP_Params.Val = _PublicClaimObjects.P_Get_User_Info_Class?.TimeZoneID;
            //List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "FilterObject";
            Dynamic_SP_Params.Val = JsonConvert.SerializeObject(_ReportParams.ReportFilterObjectList);
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "ColumnObject";
            Dynamic_SP_Params.Val = JsonConvert.SerializeObject(_ReportParams.ReportColumnObjectList);
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            if (IsUserNameSet)
            {
                Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "Username";
                Dynamic_SP_Params.Val = _PublicClaimObjects.username;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
            }

        }
        public static ShowHideReportColumnObject GetGridReportTemplateColumns(PublicClaimObjects _PublicClaimObjects, int GRL_ID, int UGRTL_ID, string GRGUID, string UGRCGUID, string kendoid, string kendofunctionname, bool iscollapse = true)
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Username";
            Dynamic_SP_Params.Val = _PublicClaimObjects.username;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "UserType_MTV_CODE";
            //Dynamic_SP_Params.Val = _PublicClaimObjects.P_Get_User_Info_Class.UserTypeMTVCode;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "GRL_ID";
            Dynamic_SP_Params.Val = GRL_ID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "UGRTL_ID";
            Dynamic_SP_Params.Val = UGRTL_ID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "GRGUID";
            Dynamic_SP_Params.Val = GRGUID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "UGRCGUID";
            Dynamic_SP_Params.Val = UGRCGUID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            ShowHideReportColumnObject result = new ShowHideReportColumnObject();
            List<ReportColumnObject> reportColumnObjects = new List<ReportColumnObject>();
            reportColumnObjects = StaticPublicObjects.ado.ExecuteSelectSQLMapList<ReportColumnObject>("P_Get_User_Grid_Report_Columns_List", true, 1000, ref List_Dynamic_SP_Params, true);

            result.kendoid = kendoid;
            result.kendofunctionname = kendofunctionname;
            result.iscollapse = iscollapse;
            result.reportColumnObjectList = reportColumnObjects;

            return result;

        }
        public static List<ReportFilterDropDownList> GetGridUserReportTemplateList(PublicClaimObjects _PublicClaimObjects, int GRL_ID, string GRGUID)
        {
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "Username";
            Dynamic_SP_Params.Val = _PublicClaimObjects.username;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "GRL_ID";
            Dynamic_SP_Params.Val = GRL_ID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "GRGUID";
            Dynamic_SP_Params.Val = GRGUID;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);

            List<ReportFilterDropDownList> ReportTemplateList = StaticPublicObjects.ado.ExecuteSelectSQLMapList<ReportFilterDropDownList>("P_Get_User_Grid_Report_Template_List", true, 1000, ref List_Dynamic_SP_Params, true);

            return ReportTemplateList;

        }
        public static List<SelectDropDownList> GetDropDownListByID(int ID, string code, string name, string tableName, string mapTableName, string filterByColumn, bool IsDistinct = false, string orderby = "")
        {
            var removeduplicate = "";
            List<Dynamic_SP_Params> paramsList = new List<Dynamic_SP_Params> { new Dynamic_SP_Params() { ParameterName = "ID", Val = ID } };
            if (IsDistinct == true)
            {
                removeduplicate = "DISTINCT";
            }
            string query = $"SELECT {removeduplicate} code = {code}, name = {name} FROM [POMS_DB].[dbo].[{tableName}] tn with (nolock)" +
                           $" WHERE {code} NOT IN (SELECT {code} FROM [POMS_DB].[dbo].[{mapTableName}] with (nolock) WHERE {filterByColumn} = @ID) AND IsActive = 1";
            if (orderby != "")
            {
                query = $"{query} {orderby}";
            }
            List<SelectDropDownList> result = StaticPublicObjects.ado.ExecuteSelectSQLMapList<SelectDropDownList>(query, false, 0, ref paramsList);
            return result;
        }
        public static List<SelectDropDownList> GetDropDownListByQuery(int ID, string query)
        {
            List<Dynamic_SP_Params> paramsList = new List<Dynamic_SP_Params> { new Dynamic_SP_Params() { ParameterName = "ID", Val = ID } };
            List<SelectDropDownList> result = StaticPublicObjects.ado.ExecuteSelectSQLMapList<SelectDropDownList>(query, false, 0, ref paramsList);
            return result;
        }
        public static List<SelectDropDownList> GetDropDownListCommon(string code, string name, string tableName, bool active = false, string filterBy = "", string orderByColumn = "")
        {
            string query = $"SELECT code = {code}, name = {name} FROM [POMS_DB].[dbo].[{tableName}] with (nolock)";
            if (active)
            {
                query += $" WHERE IsActive = 1";
                if (filterBy != "")
                {
                    query += " AND " + filterBy;
                }
            }
            else
            {
                if (filterBy != "")
                {
                    query += " WHERE" + filterBy;
                }
            }

            if (!string.IsNullOrWhiteSpace(orderByColumn))
            {
                query += $" ORDER BY {orderByColumn}";
            }
            List<SelectDropDownList> result = StaticPublicObjects.ado.Get_DropDownList_Result(query);
            return result;
        }
        public static bool IsPasswordValid(string password, int passwordlength)
        {
            // Define regular expressions for each criterion
            var hasCapitalLetter = new Regex(@"[A-Z]").IsMatch(password);
            var hasSmallLetter = new Regex(@"[a-z]").IsMatch(password);
            var hasSpecialCharacter = new Regex(@"[!@#$%^&*()_+{}\[\]:;<>,.?~\\/\-=]").IsMatch(password);
            var hasNumber = new Regex(@"\d").IsMatch(password);
            var haslength = password.Length < passwordlength ? false : true;

            // Check if all criteria are met
            return hasCapitalLetter && hasSmallLetter && hasSpecialCharacter && hasNumber && haslength;
        }
        public static bool IsValidEmail(string originalemail)
        {
            bool isvalidemail = false;
            if (string.IsNullOrWhiteSpace(originalemail))
                return false;

            try
            {
                string[] emailobj;
                emailobj = originalemail.Split(';');
                // Normalize the domain
                foreach (string s in emailobj)
                {
                    string email = s;
                    email = Regex.Replace(email, @"(@)(.+)$", DomainMapper,
                                      RegexOptions.None, TimeSpan.FromMilliseconds(200));

                    // Examines the domain part of the email and normalizes it.
                    string DomainMapper(Match match)
                    {
                        // Use IdnMapping class to convert Unicode domain names.
                        var idn = new IdnMapping();

                        // Pull out and process domain name (throws ArgumentException on invalid)
                        string domainName = idn.GetAscii(match.Groups[2].Value);

                        return match.Groups[1].Value + domainName;
                    }
                    isvalidemail = Regex.IsMatch(email,
                    @"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                    RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250));
                    if (isvalidemail == false)
                        break;
                }
            }
            catch (RegexMatchTimeoutException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }
            catch (ArgumentException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail 1", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }

            try
            {
                return isvalidemail;
            }
            catch (RegexMatchTimeoutException e)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValidEmail 2", SmallMessage: e.Message, Message: e.ToString());
                return false;
            }
        }
        public static string GetSortingModelWithData(string query)
        {
            string HtmlString = "";
            List<Dynamic_SP_Params> List_Dynamic_SP_Params = null;
            List<Sorting_Result> SortList = StaticPublicObjects.ado.ExecuteSelectSQLMapList<Sorting_Result>(query, false, 0, ref List_Dynamic_SP_Params);
            foreach (var item in SortList)
            {
                HtmlString += "<tr>";
                HtmlString += "<td>";
                HtmlString += "<img src = '../icon/up.png' class='cursor-pointer up mr-1' /><br />";
                HtmlString += "<img src = '../icon/down.png' class='cursor-pointer down mr-1' /><br />";
                HtmlString += "</td>";
                HtmlString += "<td id='New_Sort_Value' class='text-center'>" + item.New_Sort_Value + "</td>";
                HtmlString += "<td id='Sort_ID' class='text-center d-none'>" + item.Sort_ID + "</td>";
                HtmlString += "<td id='Sort_Text' class='text-center'>" + item.Sort_Text + "</td>";
                HtmlString += "<td id='Old_Sort_Value' class='text-center'>" + item.Old_Sort_Value + "</td>";
                HtmlString += "<td id='Sort_Input' class='text-center'><input type='number' class='form-control Sort_Input_Value' placeholder='Sort' onkeyup='moveToPosition(this)'></td>";
                HtmlString += "</tr>";
            }
            return HtmlString;
        }
        public static T? GetValueFromReturnParameter<T>(List<Dynamic_SP_Params> List_Dynamic_SP_Params, string ParameterName, Type type_)
        {
            object? returnvalue = null;
            for (int i = 0; i <= List_Dynamic_SP_Params.Count - 1; i++)
            {
                if (type_ == typeof(int))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && Information.IsNumeric(List_Dynamic_SP_Params[i].Val))
                        returnvalue = Convert.ToInt32(List_Dynamic_SP_Params[i].Val);
                }
                else if (type_ == typeof(long))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && Information.IsNumeric(List_Dynamic_SP_Params[i].Val))
                        returnvalue = Convert.ToInt64(List_Dynamic_SP_Params[i].Val);
                }
                else if (type_ == typeof(string))
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName && List_Dynamic_SP_Params[i].Val != null)
                        returnvalue = List_Dynamic_SP_Params[i].Val.ToString();
                }
                else
                {
                    if (List_Dynamic_SP_Params[i].ParameterName == ParameterName)
                        returnvalue = List_Dynamic_SP_Params[i].Val;
                }
            }
            return (T?)returnvalue;
        }

        //public static List<UploadFile> UploadTMSFile(List<IFormFile> formFiles, string uploadPath, List<string> allowFileExtensions, int T_ID = 0, int TD_ID = 0)
        //{
        //    List<UploadFile> uploadFiles = new List<UploadFile>();

        //    if (T_ID > 0 && TD_ID > 0)
        //    {
        //        uploadPath = $"{uploadPath}/{T_ID}/{TD_ID}";
        //    }

        //    if (!Directory.Exists(uploadPath))
        //    {
        //        Directory.CreateDirectory(uploadPath);
        //    }


        //    foreach (var file in formFiles)
        //    {
        //        if (file.Length > 0)
        //        {
        //            var originalName = file.FileName.ToLower();

        //            var fileExtension = Path.GetExtension(originalName).ToLower();
        //            var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(originalName);

        //            string[] splitFileName = fileNameWithoutExtension.Split('_');
        //            int getRowNo = int.Parse(splitFileName[splitFileName.Length - 1]);
        //            string fileWithoutRowNo = string.Join("_", splitFileName.Take(splitFileName.Length - 1)) + fileExtension;

        //            if (allowFileExtensions.Contains(fileExtension))
        //            {
        //                string fileName = $"{Guid.NewGuid()}{fileExtension}".ToLower();
        //                string filePath = Path.Combine(uploadPath, fileName);

        //                using (var stream = new FileStream(filePath, FileMode.Create))
        //                {
        //                    file.CopyTo(stream);
        //                }

        //                uploadFiles.Add(new UploadFile
        //                {
        //                    RowNo = getRowNo,
        //                    FileName = fileName,
        //                    OriginalFileName = fileWithoutRowNo,
        //                    FileExt = fileExtension,
        //                    Path = filePath,
        //                });
        //            }
        //        }
        //    }

        //    return uploadFiles;
        //}

        public static P_ReturnMessage_Result MoveTMSFile(string FileName, int T_ID, int TD_ID, int TA_ID, string OldPath, string newPath)
        {
            P_ReturnMessage_Result attachmentResponse = new P_ReturnMessage_Result();
            try
            {
                newPath = $"{newPath}/{T_ID}/{TD_ID}";
                if (File.Exists(OldPath))
                {
                    string fullNewPath = Path.Combine(newPath, FileName);

                    if (!Directory.Exists(newPath))
                    {
                        Directory.CreateDirectory(newPath);
                    }

                    File.Move(OldPath, fullNewPath);
                    UpdateAttachmentPath updateAttachmentPath = new UpdateAttachmentPath
                    {
                        TA_ID = TA_ID,
                        TD_ID = TD_ID,
                        Path = fullNewPath

                    };
                    try
                    {
                        attachmentResponse = StaticPublicObjects.ado.P_SP_MultiParm_Result("P_Update_TasksAttachmentsPath", updateAttachmentPath, "");
                        if (attachmentResponse.ReturnCode == false)
                        {
                            if (File.Exists(fullNewPath))
                            {
                                File.Move(fullNewPath, OldPath);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (File.Exists(fullNewPath))
                        {
                            File.Move(fullNewPath, OldPath);
                        }
                        attachmentResponse.ReturnText = "Internal Error";
                        attachmentResponse.ReturnCode = false;
                        return attachmentResponse;
                    }

                }

                return attachmentResponse;
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "MoveTMSFile", SmallMessage: ex.Message.ToString()!, Message: ex.Message.ToString());
                attachmentResponse.ReturnText = "Internal Error";
                attachmentResponse.ReturnCode = false;
                return attachmentResponse;
            }
        }

        public static void DeleteTMSFile(string Path)
        {
            if (File.Exists(Path))
            {
                File.Delete(Path);

            }
        }

    }
}

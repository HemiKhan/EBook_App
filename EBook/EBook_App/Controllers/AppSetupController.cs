using EBook_App.Extension;
using EBook_Data.Common;
using EBook_Data.DataAccess;
using EBook_Data.Dtos;
using EBook_Data.Interfaces;
using EBook_Models.App_Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using static EBook_Data.Dtos.AppEnum;

namespace EBook_App.Controllers
{
    public class AppSetupController : Controller
    {
        #region Controller Constructor
        private IConfiguration _config;
        private IHttpContextAccessor _httpContextAccessor;
        private readonly IADORepository ado;
        private PublicClaimObjects? _PublicClaimObjects
        {
            get
            {
                return ado.GetPublicClaimObjects();
            }
        }
        private readonly string _bodystring = "";
        public AppSetupController(IConfiguration config, IHttpContextAccessor httpContextAccessor, IADORepository ado)
        {
            this._config = config;
            this._httpContextAccessor = httpContextAccessor;
            this.ado = ado;
            this._bodystring = ado.GetRequestBodyString().Result;
        }
        #endregion Controller Constructor

        #region User Setup
        [CustomPageSetupAttribute]
        public IActionResult UserSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);

                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "Username";
                dynamic_SP_Params.Val = _PublicClaimObjects?.username;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                dynamic_SP_Params = new Dynamic_SP_Params();
                dynamic_SP_Params.ParameterName = "UserType_MTV_CODE";
                dynamic_SP_Params.Val = _PublicClaimObjects?.P_Get_User_Info?.UserType;
                List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                List<ReportFilterDropDownList> reportFilterDropDownLists = new List<ReportFilterDropDownList>();
                DataSet DS = new DataSet();
                DS = ado.ExecuteStoreProcedureDS("P_Get_UserSetup_Dropdown_Lists", ref List_Dynamic_SP_Params);
                ViewBag.UserTypeDT = DS.Tables[0];
                ViewBag.DepartmentDT = DS.Tables[1];
                ViewBag.QuestionDT = DS.Tables[2];
                ViewBag.BlockDT = DS.Tables[3];
                ViewBag.TimeZoneDT = DS.Tables[4];
                ViewBag.RolesDT = DS.Tables[5];
                ViewBag.ApplicationAccessDT = DS.Tables[6];
                ViewBag.SellerDT = DS.Tables[7];

                ViewBag.UserTypeList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.DepartmentList = JsonConvert.SerializeObject(DS.Tables[1]);
                ViewBag.QuestionList = JsonConvert.SerializeObject(DS.Tables[2]);
                ViewBag.BlockList = JsonConvert.SerializeObject(DS.Tables[3]);
                ViewBag.TimeZoneList = JsonConvert.SerializeObject(DS.Tables[4]);
                ViewBag.RolesList = JsonConvert.SerializeObject(DS.Tables[5]);
                ViewBag.ApplicationAccessList = JsonConvert.SerializeObject(DS.Tables[6]);
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access User Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/UserSetup", "User Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }

        [HttpPost]
        public IActionResult GetFilterData_Users_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    Dynamic_SP_Params dynamic_SP_Params = new Dynamic_SP_Params();
                    dynamic_SP_Params.ParameterName = "UserType_MTV_CODE";
                    dynamic_SP_Params.Val = _PublicClaimObjects?.P_Get_User_Info?.UserType;
                    List_Dynamic_SP_Params.Add(dynamic_SP_Params);

                    List<P_Users_Result> ResultList = ado.P_Get_Generic_List_SP<P_Users_Result>("P_Get_Users_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_Users_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }

        [HttpPost]
        public string GetAddEditUserSetupModal([FromBody] int UserID)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Edit);

            if ((UserID == 0 && IsAdd == false) || (UserID > 0 && IsEdit == false))
                return "No Rights";

            string HtmlString = "";
            DataSet DS = new DataSet();

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_User_Response UserEdit = new P_AddOrEdit_User_Response();
            if (UserID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "USER_ID";
                Dynamic_SP_Params.Val = UserID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                string query = "SELECT USER_ID, USERNAME, UserType_MTV_CODE, Password = '', ConfrimPassword = '', D_ID, Designation, FirstName, MiddleName, LastName, Company, Address, Address2, City, State, ZipCode, Country, Email, Mobile, Phone, PhoneExt, SecurityQuestion_MTV_ID, EncryptedAnswer, TIMEZONE_ID, IsApproved, BlockType_MTV_ID, IsAPIUser, IsActive FROM [EBook_DB].[dbo].[T_Users] u with (nolock) WHERE USER_ID = @USER_ID";
                UserEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_User_Response>(query, false, 0, ref List_Dynamic_SP_Params);
            }

            List<Dynamic_SP_Params> UserTypeList_Params = new List<Dynamic_SP_Params>() { new Dynamic_SP_Params { ParameterName = "MT_ID", Val = 106 } };
            List<SelectDropDownList> UserTypeList = ado.Get_DropDownList_Result("SELECT code = MTV_CODE, name = Name FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MT_ID = @MT_ID", UserTypeList_Params);
            List<SelectDropDownList> DepartmentList = ado.Get_DropDownList_Result("SELECT code = D_ID, name = DepartmentName FROM [EBook_DB].[dbo].[T_Department] with (nolock)");
            List<Dynamic_SP_Params> QuestionTypeList_Params = new List<Dynamic_SP_Params>() { new Dynamic_SP_Params { ParameterName = "MT_ID", Val = 150 } };
            List<SelectDropDownList> QuestionTypeList = ado.Get_DropDownList_Result("SELECT code = MTV_ID, name = Name FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MT_ID = @MT_ID", QuestionTypeList_Params);
            List<Dynamic_SP_Params> BlockTypeList_Params = new List<Dynamic_SP_Params>() { new Dynamic_SP_Params { ParameterName = "MT_ID", Val = 149 } };
            List<SelectDropDownList> BlockTypeList = ado.Get_DropDownList_Result("SELECT code = MTV_ID, name = Name FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MT_ID = @MT_ID", BlockTypeList_Params);

            getModalDetail.getmodelsize = GetModalSize.modal_lg;
            getModalDetail.modaltitle = (UserID == 0 ? "Add New User" : "Edit User");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (UserID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditUser()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "User ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.IsHidden = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.number;
            modalBodyTypeInfo.PlaceHolder = "User ID";
            modalBodyTypeInfo.id = "modalUserID";
            if (UserEdit.USER_ID > 0)
            {
                modalBodyTypeInfo.value = UserEdit.USER_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "readonly", Value = "readonly"}
            };
            if (UserEdit.USER_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "User Type";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalUserType_MTV_CODE";
            if (!string.IsNullOrWhiteSpace(UserEdit.UserType_MTV_CODE))
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = UserEdit.UserType_MTV_CODE;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = UserTypeList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this);"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "First Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "First Name";
            modalBodyTypeInfo.id = "modalFirstName";
            if (UserEdit.FirstName != "")
            {
                modalBodyTypeInfo.value = UserEdit.FirstName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Middle Name";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Middle Name";
            modalBodyTypeInfo.id = "modalMiddleName";
            if (UserEdit.MiddleName != "")
            {
                modalBodyTypeInfo.value = UserEdit.MiddleName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Last Name";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Last Name";
            modalBodyTypeInfo.id = "modalLastName";
            if (UserEdit.LastName != "")
            {
                modalBodyTypeInfo.value = UserEdit.LastName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "User Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text1;
            modalBodyTypeInfo.PlaceHolder = "User Name";
            modalBodyTypeInfo.id = "modalUserName";
            if (UserEdit.USERNAME != "")
            {
                modalBodyTypeInfo.value = UserEdit.USERNAME;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Email";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Email";
            modalBodyTypeInfo.id = "modalEmail";
            if (UserEdit.Email != "")
            {
                modalBodyTypeInfo.value = UserEdit.Email;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Password";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.password1;
            modalBodyTypeInfo.PlaceHolder = "Password";
            modalBodyTypeInfo.id = "modalPassword";
            modalBodyTypeInfo.value = "";
            modalBodyTypeInfo.ClassName = "form-control custompassword";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onchange", Value = "ValidatePassword(this)"},
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            if (UserID == 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Confirm Password";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.password1;
            modalBodyTypeInfo.PlaceHolder = "Confirm Password";
            modalBodyTypeInfo.id = "modalConfirmPassword";
            modalBodyTypeInfo.value = "";
            modalBodyTypeInfo.ClassName = "form-control custompassword";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            if (UserID == 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Department";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalD_ID";
            if (UserEdit.D_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = UserEdit.D_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = DepartmentList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this);"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Designation";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Designation";
            modalBodyTypeInfo.id = "modalDesignation";
            if (UserEdit.Designation != "")
            {
                modalBodyTypeInfo.value = UserEdit.Designation;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Company";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Company";
            modalBodyTypeInfo.id = "modalCompany";
            if (UserEdit.Company != "")
            {
                modalBodyTypeInfo.value = UserEdit.Company;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRTextArea;
            modalBodyTypeInfo.LabelName = "Address";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Address";
            modalBodyTypeInfo.id = "modalAddress";
            if (UserEdit.Address != "")
            {
                modalBodyTypeInfo.value = UserEdit.Address;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRTextArea;
            modalBodyTypeInfo.LabelName = "Address2";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Address2";
            modalBodyTypeInfo.id = "modalAddress2";
            if (UserEdit.Address2 != "")
            {
                modalBodyTypeInfo.value = UserEdit.Address2;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "City";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "City";
            modalBodyTypeInfo.id = "modalCity";
            if (UserEdit.City != "")
            {
                modalBodyTypeInfo.value = UserEdit.City;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "State";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "State";
            modalBodyTypeInfo.id = "modalState";
            if (UserEdit.State != "")
            {
                modalBodyTypeInfo.value = UserEdit.State;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "ZipCode";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "ZipCode";
            modalBodyTypeInfo.id = "modalZipCode";
            if (UserEdit.ZipCode != "")
            {
                modalBodyTypeInfo.value = UserEdit.ZipCode;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Country";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Country";
            modalBodyTypeInfo.id = "modalCountry";
            if (UserEdit.Country != "")
            {
                modalBodyTypeInfo.value = UserEdit.Country;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Mobile";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Mobile";
            modalBodyTypeInfo.id = "modalMobile";
            if (UserEdit.Mobile != "")
            {
                modalBodyTypeInfo.value = UserEdit.Mobile;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Phone";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Phone";
            modalBodyTypeInfo.id = "modalPhone";
            if (UserEdit.Phone != "")
            {
                modalBodyTypeInfo.value = UserEdit.Phone;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "PhoneExt";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "PhoneExt";
            modalBodyTypeInfo.id = "modalPhoneExt";
            if (UserEdit.PhoneExt != "")
            {
                modalBodyTypeInfo.value = UserEdit.PhoneExt;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Block Type";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalBlockType_MTV_ID";
            if (UserEdit.BlockType_MTV_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = UserEdit.BlockType_MTV_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = BlockTypeList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Security Question";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalSecurityQuestion_MTV_ID";
            if (UserEdit.SecurityQuestion_MTV_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = UserEdit.SecurityQuestion_MTV_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = QuestionTypeList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "EncryptedAnswer";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "EncryptedAnswer";
            modalBodyTypeInfo.id = "modalEncryptedAnswer";
            if (UserEdit.EncryptedAnswer != "")
            {
                modalBodyTypeInfo.value = UserEdit.EncryptedAnswer;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Approved";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Approved";
            modalBodyTypeInfo.id = "modalIsApproved";
            modalBodyTypeInfo.value = "";
            if (UserEdit.IsApproved)
            {
                modalBodyTypeInfo.ischecked = true;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is API User";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is API User";
            modalBodyTypeInfo.id = "modalIsAPIUser";
            modalBodyTypeInfo.value = "";
            if (UserEdit.IsAPIUser)
            {
                modalBodyTypeInfo.ischecked = true;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalIsActive";
            modalBodyTypeInfo.value = "";
            if (UserID > 0)
            {
                modalBodyTypeInfo.ischecked = UserEdit.IsActive;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }

        [HttpPost]
        public IActionResult AddOrEdit_User([FromBody] string JsonData)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }

            P_ReturnMessage_Result response = new P_ReturnMessage_Result();
            if (!string.IsNullOrEmpty(JsonData))
            {
                byte[] storeSalt = Crypto.GenerateSalt(new byte[20]);
                JObject obj = JObject.Parse(JsonData);
                string password = (string)obj["UserDetails"]["PasswordHash"];
                string confirmPassword = (string)obj["UserDetails"]["PasswordHash"];
                string encryptedAnswer = (string)obj["UserDetails"]["EncryptedAnswer"];
                response = UserValidator.ValidateUser(obj);
                if (response.ReturnCode)
                {
                    string PasswordSalt = Convert.ToBase64String(storeSalt);
                    string PasswordHash = Crypto.EncodePassword(2, password, PasswordSalt);
                    obj["UserDetails"]["PasswordHash"] = PasswordHash;
                    obj["UserDetails"]["PasswordSalt"] = PasswordSalt;

                    if (encryptedAnswer != null)
                    {
                        encryptedAnswer = Crypto.EncryptQueryString(encryptedAnswer);
                        obj["UserDetails"]["EncryptedAnswer"] = encryptedAnswer;

                    }

                    JToken userSeller = obj["UserSeller"];
                    if (userSeller != null && userSeller.HasValues)
                    {
                        foreach (var userToSeller in userSeller)
                        {
                            var isBlankSubSellerAllowed = (bool)userToSeller["UserToSeller"]["IsBlankSubSellerAllowed"];
                            var isAllPartnerAllowed = (bool)userToSeller["UserToSeller"]["IsAllPartnerAllowed"];
                            var isAllTariffAllowed = (bool)userToSeller["UserToSeller"]["IsAllTariffAllowed"];

                            if (!isBlankSubSellerAllowed)
                            {
                                userSeller["SubSellerTo"] = null;

                            }
                            if (isAllPartnerAllowed)
                            {
                                userSeller["PartnerTo"] = null;
                            }
                            if (isAllTariffAllowed)
                            {
                                userSeller["Tariff"] = null;
                            }

                        }
                    }


                    var modifiedJson = JsonConvert.SerializeObject(obj);

                    P_ReturnMessageForJson_Result SPResponse = ado.P_Create_User(modifiedJson, _PublicClaimObjects.username);
                    if (SPResponse.ReturnCode == false)
                    {
                        StaticPublicObjects.logFile.ErrorLog(FunctionName: "P_Create_User", SmallMessage: SPResponse.ReturnText!, Message: SPResponse.ReturnText!);
                    }
                    response.ReturnText = SPResponse.ReturnText;
                    response.ReturnCode = SPResponse.ReturnCode;
                    return Content(JsonConvert.SerializeObject(response));
                }
                else
                {
                    return Content(JsonConvert.SerializeObject(response));
                }

            }
            else
            {
                response.ReturnText = "Internal Error";
                response.ReturnCode = false;
                return Content(JsonConvert.SerializeObject(response));
            }


        }

        [HttpPost]
        public IActionResult GetAllDropDownDataForUser([FromBody] string SellerKey)
        {
            if (SellerKey != null)
            {
                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];

                ParamsNameValues[0] = ("Seller_key", SellerKey);
                DS = ado.ExecuteStoreProcedureDS("P_GetAllDropdownData_UserSetup", ParamsNameValues);

                return Content(JsonConvert.SerializeObject(DS));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("The seller key is null."));
            }

        }

        [HttpPost]
        public IActionResult GetUserInfoByID([FromBody] int UserID)
        {
            List<Dynamic_SP_Params> ParmList = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "@UserID", Val = UserID}
            };
            string query = "SELECT USER_ID, USERNAME, UserType_MTV_CODE, UserType = ut.Name, d.D_ID, d.DepartmentName, Designation, FirstName, MiddleName, LastName, Company, Address, Address2, City, State, ZipCode, Country, Email, Mobile, phone, PhoneExt, SecurityQuestion_MTV_ID, Question = q.Name, EncryptedAnswer, u.TIMEZONE_ID, TIMEZONE = tz.TimeZoneDisplay, IsApproved, BlockType_MTV_ID, BlockType = b.Name, IsAPIUser, u.IsActive FROM [EBook_DB].[dbo].[T_Users] u with (nolock) LEFT JOIN [EBook_DB].[dbo].[T_Master_Type_Value] ut with (nolock) ON u.UserType_MTV_CODE = ut.MTV_CODE LEFT JOIN [EBook_DB].[dbo].[T_Department] d with (nolock) ON u.D_ID = d.D_ID LEFT JOIN [EBook_DB].[dbo].[T_Master_Type_Value] q with (nolock) ON u.SecurityQuestion_MTV_ID = q.MTV_ID LEFT JOIN [EBook_DB].[dbo].[T_Time_Zone_List] tz with (nolock) ON u.TIMEZONE_ID = tz.TIMEZONE_ID LEFT JOIN [EBook_DB].[dbo].[T_Master_Type_Value] b with (nolock) ON u.BlockType_MTV_ID = b.MTV_ID WHERE USER_ID = @UserID";
            P_Get_User_By_ID response = ado.ExecuteSelectSQLMap<P_Get_User_By_ID>(query, false, 0, ref ParmList);
            return Content(JsonConvert.SerializeObject(response));
        }

        [HttpPost]
        public IActionResult Remove_User([FromBody] int UserID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.User_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_User", "UserID", UserID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_User", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }



        [HttpPost]
        public IActionResult GetUserDetails([FromBody] string UserID)
        {
            int Int_UserID = 0;
            if (UserID != "")
                Int_UserID = Convert.ToInt32(Crypto.DecryptNumericToStringWithOutNull(UserID));

            string json = ado.P_Get_SingleParm_String_Result("P_Get_UserSetup_Json", "UserID", Int_UserID);
            if (json != null)
            {
                return Content(JsonConvert.SerializeObject(json));
            }
            else
            {
                P_ReturnMessage_Result response = new P_ReturnMessage_Result();
                response.ReturnCode = false;
                response.ReturnText = "No data exist";
                return Content(JsonConvert.SerializeObject(response));
            }


        }

        [HttpPost]
        public IActionResult GetUserNameListForSearch([FromBody] string SearchTerm)
        {

            List<Dynamic_SP_Params> parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "SearchTerm", Val = SearchTerm},

            };
            List<P_Get_SearchUsersName> UserNameList = ado.P_Get_Generic_List_SP<P_Get_SearchUsersName>("P_Get_SearchUsersName", ref parms);

            if (UserNameList.Count > 0)
            {
                return Content(JsonConvert.SerializeObject(UserNameList));
            }
            else
            {
                P_ReturnMessage_Result response = new P_ReturnMessage_Result();
                response.ReturnCode = false;
                response.ReturnText = "No data exist";
                return Content(JsonConvert.SerializeObject(response));
            }
        }

        #endregion User Setup        

        #region Page Setup
        [CustomPageSetupAttribute]
        public IActionResult PageSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);

                int SortPosition = 0;
                ReportColumnObject reportColumnObject = new ReportColumnObject();
                ShowHideReportColumnObject PageGroupDetailShowHideReportColumnObject = new ShowHideReportColumnObject();
                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "RowNo";
                reportColumnObject.Name = "#";
                reportColumnObject.IsChecked = true;
                reportColumnObject.IsHidden = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "PG_ID";
                reportColumnObject.Name = "Page ID";
                reportColumnObject.IsChecked = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "PageGroupName";
                reportColumnObject.Name = "Page Group Name";
                reportColumnObject.IsChecked = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "Sort_";
                reportColumnObject.Name = "Sort_";
                reportColumnObject.IsChecked = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "IsHide";
                reportColumnObject.Name = "IsHide";
                reportColumnObject.IsChecked = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                reportColumnObject = new ReportColumnObject();
                reportColumnObject.Code = "IsActive";
                reportColumnObject.Name = "IsActive";
                reportColumnObject.IsChecked = true;
                reportColumnObject.SortPosition = SortPosition;
                SortPosition += 1;
                PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);

                if (IsAdd || IsEdit || IsDelete)
                {
                    reportColumnObject = new ReportColumnObject();
                    reportColumnObject.Code = "Action";
                    reportColumnObject.Name = "Action";
                    reportColumnObject.IsChecked = true;
                    reportColumnObject.SortPosition = SortPosition;
                    SortPosition += 1;
                    PageGroupDetailShowHideReportColumnObject.reportColumnObjectList.Add(reportColumnObject);
                }

                PageGroupDetailShowHideReportColumnObject.kendoid = "grid";
                ViewBag.PageGroupDetailShowHideReportColumnObject = PageGroupDetailShowHideReportColumnObject;

                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Username", _PublicClaimObjects.username);
                DS = ado.ExecuteStoreProcedureDS("P_Get_Page_Setup_DropDown_Lists", ParamsNameValues);
                ViewBag.PageGroupList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.PageList = JsonConvert.SerializeObject(DS.Tables[1]);
                ViewBag.ApplicationList = JsonConvert.SerializeObject(DS.Tables[2]);
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Page Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/PageSetup", "Page Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }
        [CheckSessionExpiration]
        [HttpPost]
        public IActionResult GetPageGroupsList([FromBody] ReportParams _ReportParams)
        {
            ReportResponsePageSetup reportResponse = new ReportResponsePageSetup();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_PageGroup_Result> ResultList = ado.P_Get_Generic_List_SP<P_PageGroup_Result>("P_Get_PageGroup_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetPageGroupsList", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [CheckSessionExpiration]
        [HttpPost]
        public IActionResult GetPagesList([FromBody] ReportParams _ReportParams)
        {
            ReportResponsePageSetup reportResponse = new ReportResponsePageSetup();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_Page_Result> ResultList = ado.P_Get_Generic_List_SP<P_Page_Result>("P_Get_Page_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetPagesList", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [CheckSessionExpiration]
        [HttpPost]
        public string GetAddEditPageGroupModal([FromBody] string Encrypted_PG_ID)
        {
            string HtmlString = "";
            int PG_ID = Crypto.DecryptNumericToStringWithOutNull(Encrypted_PG_ID);

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Edit);
            if ((PG_ID == 0 && IsAdd == false) || (PG_ID > 0 && IsEdit == false))
                return "No Rights";


            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_PageGroup_Response PageGroupEdit = new P_AddOrEdit_PageGroup_Response();
            if (PG_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "PG_ID";
                Dynamic_SP_Params.Val = PG_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                PageGroupEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_PageGroup_Response>("SELECT PG_ID, PageGroupName, IsHide, IsActive Active FROM [EBook_DB].[dbo].[T_Page_Group] with (nolock) WHERE PG_ID = @PG_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (PG_ID == 0 ? "Add New Page Group" : "Edit Page Group");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (PG_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditPageGroup()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page Group ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.IsHidden = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page Group ID";
            modalBodyTypeInfo.id = "modalpagegroupid";
            if (PageGroupEdit.PG_ID > 0)
            {
                modalBodyTypeInfo.value = PageGroupEdit.PG_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (PageGroupEdit.PG_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page Group Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page Group Name";
            modalBodyTypeInfo.id = "modalpagegroupname";
            if (PageGroupEdit.PageGroupName != "")
            {
                modalBodyTypeInfo.value = PageGroupEdit.PageGroupName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Hide";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Hide";
            modalBodyTypeInfo.id = "modalpagegroupishide";
            modalBodyTypeInfo.value = "";
            if (PageGroupEdit.IsHide)
            {
                modalBodyTypeInfo.ischecked = PageGroupEdit.IsHide;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalpgisactive";
            modalBodyTypeInfo.value = "";
            if (PageGroupEdit.PG_ID > 0)
            {
                modalBodyTypeInfo.ischecked = PageGroupEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);
            return HtmlString;
        }
        [CheckSessionExpiration]
        [HttpPost]
        public string GetAddEditPageModal([FromBody] string Encrypted_P_ID)
        {
            string HtmlString = "";
            DataSet DS = new DataSet();
            int P_ID = Crypto.DecryptNumericToStringWithOutNull(Encrypted_P_ID);

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Edit);
            if ((P_ID == 0 && IsAdd == false) || (P_ID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Page_Response PageEdit = new P_AddOrEdit_Page_Response();
            if (P_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "P_ID";
                Dynamic_SP_Params.Val = P_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                PageEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Page_Response>("SELECT P_ID, PG_ID, PageName, PageURL, Application_MTV_ID, IsHide, IsActive Active FROM [EBook_DB].[dbo].[T_Page] with (nolock) WHERE P_ID = @P_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            List<SelectDropDownList> PageGroupList = ado.Get_DropDownList_Result("SELECT PG_ID code, PageGroupName name FROM [EBook_DB].[dbo].[T_Page_Group] with (nolock) WHERE isActive = 1 ORDER BY Sort_");
            List<Dynamic_SP_Params> Application_Parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "MT_ID", Val = 148}
            };
            List<SelectDropDownList> ApplicationList = ado.Get_DropDownList_Result("SELECT code = MTV_ID, name = Name FROM T_Master_Type_Value where MT_ID = @MT_ID ORDER BY Sort_", Application_Parms);

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (P_ID == 0 ? "Add New Page" : "Edit Page");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (P_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditPage()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page ID";
            modalBodyTypeInfo.id = "modalpageid";
            if (PageEdit.P_ID > 0)
            {
                modalBodyTypeInfo.value = PageEdit.P_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (PageEdit.P_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Application";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalApplication_MTV_ID";
            if (PageEdit.Application_MTV_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = PageEdit.Application_MTV_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = ApplicationList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Page Group Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalSelectPageGroupName";
            if (PageEdit.PG_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = PageEdit.PG_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = PageGroupList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page Name";
            modalBodyTypeInfo.id = "modalpagename";
            if (PageEdit.PageName != "")
            {
                modalBodyTypeInfo.value = PageEdit.PageName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page URL";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page URL";
            modalBodyTypeInfo.id = "modalpageurl";
            if (PageEdit.PageUrl != "")
            {
                modalBodyTypeInfo.value = PageEdit.PageUrl;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Hide";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Hide";
            modalBodyTypeInfo.id = "modalpageishide";
            modalBodyTypeInfo.value = "";
            if (PageEdit.IsHide)
            {
                modalBodyTypeInfo.ischecked = PageEdit.IsHide;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalpisactive";
            modalBodyTypeInfo.value = "";
            if (PageEdit.Active)
            {
                modalBodyTypeInfo.ischecked = PageEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;
            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);
            return HtmlString;
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult AddOrEdit_PageGroup([FromBody] P_AddOrEdit_PageGroup_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_PageGroup", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_PageGroup", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult AddOrEdit_Page([FromBody] P_AddOrEdit_Page_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Page", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Page", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult Remove_PageGroup([FromBody] string Ery_PG_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Delete);
            if (IsDelete)
            {
                int PG_ID = Crypto.DecryptNumericToStringWithOutNull(Ery_PG_ID);
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_PageGroup", "PG_ID", PG_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_PageGroup", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult Remove_Page([FromBody] string Ery_P_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_Delete);
            if (IsDelete)
            {
                int P_ID = Crypto.DecryptNumericToStringWithOutNull(Ery_P_ID);
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Page", "P_ID", P_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Page", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [CheckSessionExpiration]
        [HttpPost]
        public string Get_PageGroup_Sorting()
        {
            string query = "SELECT ROW_NUMBER() OVER (ORDER BY Sort_) New_Sort_Value, PG_ID Sort_ID, PageGroupName Sort_Text, Sort_ Old_Sort_Value FROM [EBook_DB].[dbo].[T_Page_Group] with (nolock) WHERE isActive = 1 ORDER BY Sort_";
            string result = CustomFunctions.GetSortingModelWithData(query);
            return result;
        }
        [CheckSessionExpiration]
        [HttpPost]
        public string Get_Page_Sorting([FromBody] string Ery_PG_ID)
        {
            int PG_ID = Crypto.DecryptNumericToStringWithOutNull(Ery_PG_ID);
            string query = "SELECT ROW_NUMBER() OVER (ORDER BY Sort_) New_Sort_Value, P_ID Sort_ID, PageName Sort_Text, Sort_ Old_Sort_Value FROM [EBook_DB].[dbo].[T_Page] with (nolock) WHERE PG_ID = " + PG_ID + " AND isActive = 1 ORDER BY Sort_";
            string result = CustomFunctions.GetSortingModelWithData(query);
            return result;
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult Update_PageGroup_Sorting([FromBody] List<Sorting_Result> res)
        {
            var json = JsonConvert.SerializeObject(res);
            P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Update_PageGroup_Sorting", "json", json, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Update_PageGroup_Sorting", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [CheckSessionExpiration]
        [HttpPost]
        public ActionResult Update_Page_Sorting([FromBody] List<Sorting_Result> res)
        {
            var json = JsonConvert.SerializeObject(res);
            P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Update_Page_Sorting", "json", json, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "Update_Page_Sorting", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }

        #endregion  Page Setup

        #region Page Chart 
        public IActionResult PageChart()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Chart_View);
            if (IsView)
            {
                DataSet DS = new DataSet();
                DS = ado.ExecuteStoreProcedureDS("P_Get_PageChart_Dropdown_Lists");
                ViewBag.ApplicationList = DS.Tables[0];
                ViewBag.RolesList = DS.Tables[1];
                ViewBag.UserList = DS.Tables[2];
                ViewBag.GUID = Guid.NewGuid().ToString().ToLower();
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Page Chart");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/PageChart", "Page Chart", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }
        [HttpPost]
        public IActionResult GetPageChart([FromBody] P_PageChart_Response res)
        {
            if (!string.IsNullOrWhiteSpace(res.UserName))
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "UserName";
                Dynamic_SP_Params.Val = res.UserName;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                res.RoleID = Convert.ToInt32(ado.ExecuteSelectObj("SELECT ROLE_ID FROM [EBook_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE USERNAME = @UserName", ref List_Dynamic_SP_Params));
            }
            List<Dynamic_SP_Params> parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "RoleID", Val = res.RoleID},
                new Dynamic_SP_Params {ParameterName = "ApplicationID", Val = res.AppID},
            };
            string json = ado.P_Get_MultiParm_String_Result("P_Get_PageChart_Json", parms);
            List<P_Get_PageChart_TreeView> treeViewResult = null;
            if (json != "")
            {
                treeViewResult = new List<P_Get_PageChart_TreeView>();
                treeViewResult = JsonConvert.DeserializeObject<List<P_Get_PageChart_TreeView>>(json);
            }
            return Content(JsonConvert.SerializeObject(treeViewResult));
        }
        #endregion Page Chart 

        #region Role Setup
        [CustomPageSetupAttribute]
        public IActionResult RoleSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);
                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Username", _PublicClaimObjects.username);
                DS = ado.ExecuteStoreProcedureDS("[P_Get_Role_Setup_DropDown_Lists]", ParamsNameValues);
                ViewBag.RoleList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.RoleGroupList = JsonConvert.SerializeObject(DS.Tables[1]);
                ViewBag.DepartmentList = JsonConvert.SerializeObject(DS.Tables[2]);
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Role Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/PageSetup", "Role Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }

        [HttpPost]
        public IActionResult GetFilterData_Role_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_Role_Result> ResultList = ado.P_Get_Generic_List_SP<P_Role_Result>("P_Get_Roles_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_Role_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_RoleGroup_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_RoleGroup_Result> ResultList = ado.P_Get_Generic_List_SP<P_RoleGroup_Result>("P_Get_Roles_Group_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_RoleGroup_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_RoleGroupMap_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_RoleGroupMap_Result> ResultList = ado.P_Get_Generic_List_SP<P_RoleGroupMap_Result>("P_Get_RolesGroupMap_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_RoleGroupMap_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_DepartmentRoleMap_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_DepartmentRoleMap_Result> ResultList = ado.P_Get_Generic_List_SP<P_DepartmentRoleMap_Result>("P_Get_DepartmentRoleMap_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_DepartmentRoleMap_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }


        [HttpPost]
        public string GetAddEditRoleSetupModal([FromBody] int RoleID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((RoleID == 0 && IsAdd == false) || (RoleID > 0 && IsEdit == false))
                return "No Rights";


            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Role_Response RoleEdit = new P_AddOrEdit_Role_Response();
            if (RoleID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "R_ID";
                Dynamic_SP_Params.Val = RoleID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                RoleEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Role_Response>("SELECT R_ID RoleID, RoleName, IsActive Active FROM [EBook_DB].[dbo].[T_Roles] with (nolock) WHERE R_ID = @R_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (RoleID == 0 ? "Add New Role" : "Edit Role");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (RoleID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditRole()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Role ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.number;
            modalBodyTypeInfo.PlaceHolder = "Role ID";
            modalBodyTypeInfo.id = "modalroleid";
            if (RoleEdit.RoleID > 0)
            {
                modalBodyTypeInfo.value = RoleEdit.RoleID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (RoleEdit.RoleID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Role Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Role Name";
            modalBodyTypeInfo.id = "modalrolename";
            if (RoleEdit.RoleName != "")
            {
                modalBodyTypeInfo.value = RoleEdit.RoleName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            if (RoleEdit.RoleID > 0)
            {
                modalBodyTypeInfo.ischecked = RoleEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalroleisactive";
            modalBodyTypeInfo.value = "";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public string GetAddEditRoleGroupModal([FromBody] int RoleGroupID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((RoleGroupID == 0 && IsAdd == false) || (RoleGroupID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Role_Group_Response RoleGroupEdit = new P_AddOrEdit_Role_Group_Response();
            if (RoleGroupID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "RG_ID";
                Dynamic_SP_Params.Val = RoleGroupID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                RoleGroupEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Role_Group_Response>("SELECT RG_ID RoleGroupID, RoleGroupName, IsActive Active FROM [EBook_DB].[dbo].[T_Role_Group] with (nolock) WHERE RG_ID = @RG_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (RoleGroupID == 0 ? "Add New Role Group" : "Edit Role Group");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (RoleGroupID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEdit_Role_Group()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Role Group ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.number;
            modalBodyTypeInfo.PlaceHolder = "Role Group ID";
            modalBodyTypeInfo.id = "modalrolegroupid";
            if (RoleGroupEdit.RoleGroupID > 0)
            {
                modalBodyTypeInfo.value = RoleGroupEdit.RoleGroupID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (RoleGroupEdit.RoleGroupID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Role Group Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Role Group Name";
            modalBodyTypeInfo.id = "modalrolegroupname";
            if (RoleGroupEdit.RoleGroupName != "")
            {
                modalBodyTypeInfo.value = RoleGroupEdit.RoleGroupName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            if (RoleGroupEdit.RoleGroupID > 0)
            {
                modalBodyTypeInfo.ischecked = RoleGroupEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalrolegroupisactive";
            modalBodyTypeInfo.value = "";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public string GetAddEditRoleGroupMappingModal([FromBody] int RoleGroupMappingID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((RoleGroupMappingID == 0 && IsAdd == false) || (RoleGroupMappingID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Role_Group_Mapping_Response RoleGroupMappingEdit = new P_AddOrEdit_Role_Group_Mapping_Response();
            if (RoleGroupMappingID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "RGM_ID";
                Dynamic_SP_Params.Val = RoleGroupMappingID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                RoleGroupMappingEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Role_Group_Mapping_Response>("SELECT RGM_ID RoleGroupMappingID, R_ID RoleID, RG_ID RoleGroupID, IsActive Active FROM [EBook_DB].[dbo].[T_Role_Group_Mapping] with (nolock) WHERE RGM_ID = @RGM_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            List<Dynamic_SP_Params> RoleGroup_Params = null;
            List<SelectDropDownList> List_RoleGroup_SelectDropDownList = ado.ExecuteSelectSQLMapList<SelectDropDownList>("SELECT code = RG_ID, name = RoleGroupName FROM [EBook_DB].[dbo].[T_Role_Group] with (nolock) WHERE isActive = 1", false, 0, ref RoleGroup_Params);
            List<SelectDropDownList> List_Role_SelectDropDownList = new List<SelectDropDownList>();
            if (RoleGroupMappingID > 0)
            {
                List_Role_SelectDropDownList = ado.ExecuteSelectSQLMapList<SelectDropDownList>("SELECT code = R_ID, name = RoleName FROM [EBook_DB].[dbo].[T_Roles] with (nolock) WHERE isActive = 1", false, 0, ref RoleGroup_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (RoleGroupMappingID == 0 ? "Add New Role Group Mapping" : "Edit Role Group Mapping");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (RoleGroupMappingID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEdit_Role_Group_Mapping()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Role Group Mapping ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.number;
            modalBodyTypeInfo.PlaceHolder = "Role Group Mapping ID";
            modalBodyTypeInfo.id = "modalrolegroupmaingid";
            if (RoleGroupMappingEdit.RoleGroupMappingID > 0)
            {
                modalBodyTypeInfo.value = RoleGroupMappingEdit.RoleGroupMappingID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" },
            };
            if (RoleGroupMappingEdit.RoleGroupMappingID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Role Group Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Role Group Name";
            modalBodyTypeInfo.id = "modalrgmrolegroupname";
            if (RoleGroupMappingEdit.RoleGroupID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = RoleGroupMappingEdit.RoleGroupID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = List_RoleGroup_SelectDropDownList;
            modalBodyTypeInfo.ClassName = "form-control";
            if (RoleGroupMappingID > 0)
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList { Name = "onchange", Value = "validate(this)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            else
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList { Name = "onchange", Value = "Load_Roles_By_RoleGroup_Dropdown(this.value)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Role Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Role Name";
            modalBodyTypeInfo.id = "modalrgmrolename";
            if (RoleGroupMappingEdit.RoleID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = RoleGroupMappingEdit.RoleID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = List_Role_SelectDropDownList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            if (RoleGroupMappingEdit.RoleGroupMappingID > 0)
            {
                modalBodyTypeInfo.ischecked = RoleGroupMappingEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalrolegroupmappingisactive";
            modalBodyTypeInfo.value = "";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public string GetAddEditDepartmentRoleMappingModal([FromBody] int DepartmentRoleMappingID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((DepartmentRoleMappingID == 0 && IsAdd == false) || (DepartmentRoleMappingID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Department_Role_Mapping_Response DeptartmentRoleMappingEdit = new P_AddOrEdit_Department_Role_Mapping_Response();
            if (DepartmentRoleMappingID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "DRM_ID";
                Dynamic_SP_Params.Val = DepartmentRoleMappingID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                DeptartmentRoleMappingEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Department_Role_Mapping_Response>("SELECT DRM_ID DepartmentRoleMappingID, R_ID RoleID, D_ID DepartmentID, IsActive Active FROM [EBook_DB].[dbo].[T_Department_Role_Mapping] with (nolock) WHERE DRM_ID = @DRM_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            List<Dynamic_SP_Params> RoleGroup_Params = null;
            List<SelectDropDownList> List_Department_SelectDropDownList = ado.ExecuteSelectSQLMapList<SelectDropDownList>("SELECT code = D_ID, name = DepartmentName FROM [EBook_DB].[dbo].T_Department with (nolock) WHERE isActive = 1", false, 0, ref RoleGroup_Params);
            List<SelectDropDownList> List_Role_SelectDropDownList = new List<SelectDropDownList>();
            if (DepartmentRoleMappingID > 0)
            {
                List_Role_SelectDropDownList = ado.ExecuteSelectSQLMapList<SelectDropDownList>("SELECT code = R_ID, name = RoleName FROM [EBook_DB].[dbo].[T_Roles] with (nolock) WHERE isActive = 1", false, 0, ref RoleGroup_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (DepartmentRoleMappingID == 0 ? "Add New Department Role Mapping" : "Edit Department Role Mapping");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (DepartmentRoleMappingID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEdit_Department_Role_Mapping()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Department Role Mapping ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.number;
            modalBodyTypeInfo.PlaceHolder = "Department Role Mapping ID";
            modalBodyTypeInfo.id = "modaldepartmentrolemapid";
            if (DeptartmentRoleMappingEdit.DepartmentRoleMappingID > 0)
            {
                modalBodyTypeInfo.value = DeptartmentRoleMappingEdit.DepartmentRoleMappingID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (DeptartmentRoleMappingEdit.DepartmentRoleMappingID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Department Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modaldrmdepartmentname";
            if (DeptartmentRoleMappingEdit.DepartmentID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = DeptartmentRoleMappingEdit.DepartmentID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = List_Department_SelectDropDownList;
            modalBodyTypeInfo.ClassName = "form-control";
            if (DepartmentRoleMappingID > 0)
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList { Name = "onchange", Value = "validate(this)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            else
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList { Name = "onchange", Value = "Load_Roles_By_Department_Dropdown(this.value)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Role Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modaldrmrolename";
            if (DeptartmentRoleMappingEdit.RoleID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = DeptartmentRoleMappingEdit.RoleID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = List_Role_SelectDropDownList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            if (DeptartmentRoleMappingEdit.DepartmentRoleMappingID > 0)
            {
                modalBodyTypeInfo.ischecked = DeptartmentRoleMappingEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modaldrmdepartmentrolemappingisactive";
            modalBodyTypeInfo.value = "";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }


        [HttpPost]
        public ActionResult AddOrEdit_Role([FromBody] P_AddOrEdit_Role_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));


            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Roles", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Role", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public ActionResult AddOrEdit_Role_Group([FromBody] P_AddOrEdit_Role_Group_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Role_Group", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Role_Group", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public ActionResult AddOrEdit_Role_Group_Mapping([FromBody] P_AddOrEdit_Role_Group_Mapping_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Role_Group_Mapping", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Role_Group_Mapping", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public ActionResult AddOrEdit_Department_Role_Mapping([FromBody] P_AddOrEdit_Department_Role_Mapping_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Department_Role_Mapping", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Department_Role_Mapping", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }


        [HttpPost]
        public ActionResult Remove_Role([FromBody] int RoleID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Roles", "R_ID", RoleID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Role", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [HttpPost]
        public ActionResult Remove_Role_Group([FromBody] int RoleGroupID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Role_Group", "RoleGroupID", RoleGroupID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Role_Group", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [HttpPost]
        public ActionResult Remove_Role_Group_Mapping([FromBody] int RoleGroupMappingID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Role_Group_Mapping", "RGM_ID", RoleGroupMappingID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Role_Group_Mapping", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [HttpPost]
        public ActionResult Remove_Department_Role_Mapping([FromBody] int DepartmentRoleMappingID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Role_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Department_Role_Mapping", "DRM_ID", DepartmentRoleMappingID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Department_Role_Mapping", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }


        [HttpPost]
        public ActionResult Get_Roles_By_RoleGroup_Dropdown([FromBody] int RG_ID)
        {
            var result = CustomFunctions.GetDropDownListByID(RG_ID, "R_ID", "RoleName", "T_Roles", "T_Role_Group_Mapping", "RG_ID");
            return Content(JsonConvert.SerializeObject(result));
        }
        [HttpPost]
        public ActionResult Get_Roles_By_Department_Dropdown([FromBody] int D_ID)
        {
            var result = CustomFunctions.GetDropDownListByID(D_ID, "R_ID", "RoleName", "T_Roles", "T_Department_Role_Mapping", "D_ID");
            return Content(JsonConvert.SerializeObject(result));
        }
        #endregion  Role Setup

        #region Rights Setup
        [CustomPageSetup]
        public IActionResult RightsSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);
                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Username", _PublicClaimObjects.username);
                DS = ado.ExecuteStoreProcedureDS("[P_Get_Rights_Setup_DropDown_Lists]", ParamsNameValues);
                ViewBag.RRoleList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.PageList = JsonConvert.SerializeObject(DS.Tables[1]);
                ViewBag.PageRightList = JsonConvert.SerializeObject(DS.Tables[2]);
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Rigths Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/PageSetup", "Rights Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }

        [HttpPost]
        public IActionResult GetFilterData_PageRights_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_PageRight_Result> ResultList = ado.P_Get_Generic_List_SP<P_PageRight_Result>("P_Get_PageRight_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_PageRights_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_RolePageRights_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_RolePageRight_Result> ResultList = ado.P_Get_Generic_List_SP<P_RolePageRight_Result>("P_Get_RolePageRightMap_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_RolePageRights_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_UserRoleMap_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_UserRoleMap_Result> ResultList = ado.P_Get_Generic_List_SP<P_UserRoleMap_Result>("P_Get_UserRoleMap_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_DepartmentRoleMap_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }


        [HttpPost]
        public string GetAddEditPageRightsModal([FromBody] int PR_ID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((PR_ID == 0 && IsAdd == false) || (PR_ID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_PageRights_Response PageRightEdit = new P_AddOrEdit_PageRights_Response();
            if (PR_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "PR_ID";
                Dynamic_SP_Params.Val = PR_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                PageRightEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_PageRights_Response>("SELECT PR_ID, P_ID, PR_CODE, PageRightName, PageRightType_MTV_CODE PageRightType, IsHide, IsActive Active FROM [EBook_DB].[dbo].[T_Page_Rights] with (nolock) WHERE PR_ID = @PR_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            List<SelectDropDownList> PageList = ado.Get_DropDownList_Result("SELECT P_ID code, PageName name FROM [EBook_DB].[dbo].[T_Page] with (nolock) WHERE isActive = 1 ORDER BY Sort_");
            List<Dynamic_SP_Params> PageRightTypeList_Parm = new List<Dynamic_SP_Params>
            {
                new Dynamic_SP_Params(){ ParameterName = "MT_ID", Val = 133 }
            };
            List<SelectDropDownList> PageRightTypeList = ado.Get_DropDownList_Result("SELECT MTV_CODE code, Name name FROM[EBook_DB].[dbo].[T_Master_Type_Value] with(nolock) Where MT_ID = @MT_ID ORDER BY Sort_", PageRightTypeList_Parm);

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (PR_ID == 0 ? "Add Page Rights Setup" : "Edit Add Page Rights Setup");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (PR_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditPageRights()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page Right ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page Right ID";
            modalBodyTypeInfo.id = "modalPageRightId";
            if (PageRightEdit.PR_ID > 0)
            {
                modalBodyTypeInfo.value = PageRightEdit.PR_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (PageRightEdit.PR_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Page Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalSelectPageName";
            if (PageRightEdit.P_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = PageRightEdit.P_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = PageList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "PR Code";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "PR Code";
            modalBodyTypeInfo.id = "modalPageRightCode";
            if (PageRightEdit.PR_CODE != "")
            {
                modalBodyTypeInfo.value = PageRightEdit.PR_CODE;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Page Right Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Page Right Name";
            modalBodyTypeInfo.id = "modalPageRightName";
            if (PageRightEdit.PageRightName != "")
            {
                modalBodyTypeInfo.value = PageRightEdit.PageRightName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Page Right Type";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalPageRightType";
            if (PageRightEdit.PageRightType != "")
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = PageRightEdit.PageRightType;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = PageRightTypeList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Hide";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Hide";
            modalBodyTypeInfo.id = "modalprishide";
            if (PageRightEdit.PR_ID > 0)
            {
                modalBodyTypeInfo.ischecked = PageRightEdit.IsHide;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalprisactive";
            modalBodyTypeInfo.value = "";
            if (PageRightEdit.PR_ID > 0)
            {
                modalBodyTypeInfo.ischecked = PageRightEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public ActionResult GetAddEditRolePageRightsModal([FromBody] int RoleID)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            string json = ado.P_Get_SingleValue_String_SP("P_Get_Role_Rights_Json", "RoleID", RoleID);
            P_AddOrEdit_RolePageRights_TreeView treeViewResult = null;
            if (json != "")
            {
                treeViewResult = new P_AddOrEdit_RolePageRights_TreeView();
                treeViewResult = JsonConvert.DeserializeObject<P_AddOrEdit_RolePageRights_TreeView>(json);
            }
            return Content(JsonConvert.SerializeObject(treeViewResult));
        }
        [HttpPost]
        public string GetAddEditUserRoleMappingModal([FromBody] int URM_ID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((URM_ID == 0 && IsAdd == false) || (URM_ID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_UserRoleMapping_Response UserRoleMappingEdit = new P_AddOrEdit_UserRoleMapping_Response();
            if (URM_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "URM_ID";
                Dynamic_SP_Params.Val = URM_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                UserRoleMappingEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_UserRoleMapping_Response>("SELECT URM_ID, USERNAME UNAME, ROLE_ID R_ID, IsGroupRoleID, IsActive Active FROM [EBook_DB].[dbo].[T_User_Role_Mapping] with (nolock) WHERE URM_ID = @URM_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            List<SelectDropDownList> UserList = new List<SelectDropDownList>();
            List<SelectDropDownList> RoleList = ado.Get_DropDownList_Result("SELECT R_ID code, RoleName name FROM [EBook_DB].[dbo].[T_Roles] with (nolock) WHERE isActive = 1 ORDER BY Sort_");
            if (URM_ID > 0)
            {
                UserList = ado.Get_DropDownList_Result("SELECT code = USERNAME, name = USERNAME FROM [EBook_DB].[dbo].[T_Users] with (nolock) WHERE IsActive = 1");
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (URM_ID == 0 ? "Add User Role Mapping Setup" : "Edit Add User Role Mapping Setup");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (URM_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditUserRoleMapping()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "User Role Mapping ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "User Role Mapping ID";
            modalBodyTypeInfo.id = "modalUserRoleMappingID";
            if (UserRoleMappingEdit.URM_ID > 0)
            {
                modalBodyTypeInfo.value = UserRoleMappingEdit.URM_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (UserRoleMappingEdit.URM_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Role Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalurmSelectRoleName";
            if (UserRoleMappingEdit.R_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = UserRoleMappingEdit.R_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = RoleList;
            modalBodyTypeInfo.ClassName = "form-control";
            if (URM_ID > 0)
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList(){ Name = "onchange", Value = "validate(this)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            else
            {
                modalBodyTypeInfo.AttributeList = new List<AttributeList>
                {
                    new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                    new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                    new AttributeList { Name = "onchange", Value = "Load_Users_By_Role_Dropdown(this.value)" },
                    new AttributeList(){Name = "autocomplete", Value = "off"}
                };
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "User Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalurmUserName";
            if (UserRoleMappingEdit.UNAME != "")
            {
                modalBodyTypeInfo.value = UserRoleMappingEdit.UNAME;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = UserList;
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Group Role ID";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Group Role ID";
            modalBodyTypeInfo.id = "modalIsGroupRoleID";
            if (UserRoleMappingEdit.R_ID > 0)
            {
                modalBodyTypeInfo.ischecked = UserRoleMappingEdit.IsGroupRoleID;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.ischecked = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalurmisactive";
            modalBodyTypeInfo.value = "";
            if (UserRoleMappingEdit.R_ID > 0)
            {
                modalBodyTypeInfo.ischecked = UserRoleMappingEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public ActionResult GetAddEditUserRoleMappingModal1([FromBody] string UserName)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);

            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
            Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
            Dynamic_SP_Params.ParameterName = "UserName";
            Dynamic_SP_Params.Val = UserName;
            List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
            int RoleID = Convert.ToInt32(ado.ExecuteSelectObj("SELECT ROLE_ID FROM [EBook_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE USERNAME = @UserName", ref List_Dynamic_SP_Params));
            string json = ado.P_Get_SingleValue_String_SP("P_Get_Role_Rights_Json", "RoleID", RoleID);
            P_AddOrEdit_RolePageRights_TreeView treeViewResult = null;
            if (json != "")
            {
                treeViewResult = new P_AddOrEdit_RolePageRights_TreeView();
                treeViewResult = JsonConvert.DeserializeObject<P_AddOrEdit_RolePageRights_TreeView>(json);
            }
            return Content(JsonConvert.SerializeObject(treeViewResult));
        }


        [HttpPost]
        public ActionResult AddOrEdit_PageRights([FromBody] P_AddOrEdit_PageRights_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));


            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Page_Rights", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_PageRights", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public ActionResult AddOrEdit_RolePageRights([FromBody] P_AddOrEdit_RolePageRights_TreeView res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            List<P_AddOrEdit_RolePageRights_Response> RPRM_Response_List = res.pageGroupInfo
                .SelectMany(pg => pg.pageInfo
                .SelectMany(p => p.pageRightsInfo
                .Select(pr => new P_AddOrEdit_RolePageRights_Response
                {
                    R_ID = res.R_ID,
                    IsRightActive = true,
                    Active = true,
                    PR_ID = pr.PR_ID
                }))).ToList();
            var json = JsonConvert.SerializeObject(RPRM_Response_List);
            P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_AddOrEdit_RolePageRight_Json", "json", json, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_RolePageRights", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public ActionResult Sync_RolePageRights([FromBody] P_Sync_RolePageRights_TreeView res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
            else
            {
                bool? ActiveRights = null;
                if (res.Active == false)
                {
                    res.Active = null;
                }

                P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_Sync_RolePageRights", res, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Sync_RolePageRights", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
        }
        [HttpPost]
        public ActionResult AddOrEdit_UserRoleMap([FromBody] P_AddOrEdit_UserRoleMapping_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_User_Role_Map", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_UserRoleMap", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }


        [HttpPost]
        public ActionResult Remove_PageRights([FromBody] int PR_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Page_Rights", "PR_ID", PR_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_PageRights", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else { return Content(JsonConvert.SerializeObject("No Rights")); }
        }
        [HttpPost]
        public ActionResult Remove_RolePageRights([FromBody] int RPRM_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Role_Page_Rights", "RPRM_ID", RPRM_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_RolePageRights", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [HttpPost]
        public ActionResult Remove_UserRoleMap([FromBody] int URM_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Right_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_User_Role_Mapping", "URM_ID", URM_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_UserRoleMap", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }


        [HttpPost]
        public ActionResult Get_Roles_Dropdown()
        {
            List<SelectDropDownList> result = ado.Get_DropDownList_Result("SELECT code = R_ID, name = RoleName FROM [EBook_DB].[dbo].[T_Roles] with (nolock) WHERE R_ID NOT IN (1) ORDER BY Sort_");
            return Content(JsonConvert.SerializeObject(result));
        }
        [HttpPost]
        public ActionResult Get_Users_By_Role_Dropdown([FromBody] int R_ID)
        {
            var result = CustomFunctions.GetDropDownListByID(R_ID, "USERNAME", "USERNAME", "T_Users", "T_User_Role_Mapping", "ROLE_ID");
            return Content(JsonConvert.SerializeObject(result));
        }
        [HttpPost]
        public ActionResult Get_Users_Dropdown()
        {
            var result = CustomFunctions.GetDropDownListCommon("USERNAME", "USERNAME", "T_Users", true);
            return Content(JsonConvert.SerializeObject(result));
        }
        #endregion  Rights Setup

        #region Department Setup
        [CustomPageSetupAttribute]
        public IActionResult DepartmentSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);
                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Department Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/PageSetup", "Department Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }
        [HttpPost]
        public IActionResult GetFilterData_Department_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_Department_Result> ResultList = ado.P_Get_Generic_List_SP<P_Department_Result>("P_Get_Department_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_Department_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public string GetAddEditDepartmentSetupModal([FromBody] int D_ID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Edit);
            if ((D_ID == 0 && IsAdd == false) || (D_ID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_Department_Response DepartmentEdit = new P_AddOrEdit_Department_Response();
            if (D_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "D_ID";
                Dynamic_SP_Params.Val = D_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                DepartmentEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_Department_Response>("SELECT D_ID, DepartmentName, IsHidden, IsActive Active FROM [EBook_DB].[dbo].[T_Department] with (nolock) WHERE D_ID = @D_ID", false, 0, ref List_Dynamic_SP_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (D_ID == 0 ? "Add Department" : "Edit Department");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (D_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditDepartment()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Department ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Department ID";
            modalBodyTypeInfo.id = "modalDepartmentID";
            if (DepartmentEdit.D_ID > 0)
            {
                modalBodyTypeInfo.value = DepartmentEdit.D_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (DepartmentEdit.D_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Department Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Department Name";
            modalBodyTypeInfo.id = "modaldsDepartmentName";
            if (DepartmentEdit.DepartmentName != "")
            {
                modalBodyTypeInfo.value = DepartmentEdit.DepartmentName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Hidden";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Hidden";
            modalBodyTypeInfo.id = "modaldsishide";
            if (DepartmentEdit.D_ID > 0)
            {
                modalBodyTypeInfo.ischecked = DepartmentEdit.IsHidden;
            }
            else
            {
                modalBodyTypeInfo.ischecked = false;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.ischecked = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modaldsisactive";
            modalBodyTypeInfo.value = "";
            if (DepartmentEdit.D_ID > 0)
            {
                modalBodyTypeInfo.ischecked = DepartmentEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);

            return HtmlString;
        }
        [HttpPost]
        public IActionResult AddOrEdit_Department([FromBody] P_AddOrEdit_Department_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_Department", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_Department", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public IActionResult Remove_Department([FromBody] int D_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Department_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_Department", "D_ID", D_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_Department", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        #endregion  Department Setup

        #region Master Setup
        [CustomPageSetupAttribute]
        public IActionResult MasterSetup()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_View);
            if (IsView)
            {
                bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Add);
                bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Edit);
                bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Delete);
                ViewBag.RightsListObj = new { IsView = IsView, IsAdd = IsAdd, IsEdit = IsEdit, IsDelete = IsDelete };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);
                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Username", _PublicClaimObjects.username);
                DS = ado.ExecuteStoreProcedureDS("P_Get_Master_Setup_DropDown_Lists", ParamsNameValues);
                ViewBag.MasterTypeList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.MasterTypeValueList = JsonConvert.SerializeObject(DS.Tables[1]);

                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Master Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/MasterSetup", "Master Setup", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }
        [HttpPost]
        public IActionResult GetFilterData_MT_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_MT_Result> ResultList = ado.P_Get_Generic_List_SP<P_MT_Result>("P_Get_MasterType_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_MT_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        [HttpPost]
        public IActionResult GetFilterData_MTV_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Page_Setup_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_MTV_Result> ResultList = ado.P_Get_Generic_List_SP<P_MTV_Result>("P_Get_MasterTypeValue_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_MTV_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }


        [HttpPost]
        public string GetAddEditMTModal([FromBody] int MT_ID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Edit);
            if ((MT_ID == 0 && IsAdd == false) || (MT_ID > 0 && IsEdit == false))
                return "No Rights";

            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_MT_Response MTEdit = new P_AddOrEdit_MT_Response();
            if (MT_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "MT_ID";
                Dynamic_SP_Params.Val = MT_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                MTEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_MT_Response>("SELECT MT_ID, MasterTypeName = Name, Description, IsActive Active FROM [EBook_DB].[dbo].[T_Master_Type] with (nolock) WHERE MT_ID = @MT_ID ORDER BY [Name]", false, 0, ref List_Dynamic_SP_Params);
            }

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (MT_ID == 0 ? "Add New Master Type" : "Edit Master Type");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (MT_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditMT()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Master Type ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Master Type ID";
            modalBodyTypeInfo.id = "modalMT_ID";
            if (MTEdit.MT_ID > 0)
            {
                modalBodyTypeInfo.value = MTEdit.MT_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (MTEdit.MT_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Master Type Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Master Type Name";
            modalBodyTypeInfo.id = "modalMasterTypeName";
            if (MTEdit.MasterTypeName != "")
            {
                modalBodyTypeInfo.value = MTEdit.MasterTypeName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRTextArea;
            modalBodyTypeInfo.LabelName = "Description";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Description";
            modalBodyTypeInfo.id = "modalDescription";
            if (MTEdit.Description != "")
            {
                modalBodyTypeInfo.value = MTEdit.Description;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalMTisActive";
            modalBodyTypeInfo.value = "";
            if (MTEdit.MT_ID > 0)
            {
                modalBodyTypeInfo.ischecked = MTEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;

            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);
            return HtmlString;
        }
        [HttpPost]
        public string GetAddEditMTVModal([FromBody] int MTV_ID)
        {
            string HtmlString = "";

            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Edit);
            if ((MTV_ID == 0 && IsAdd == false) || (MTV_ID > 0 && IsEdit == false))
                return "No Rights";

            DataSet DS = new DataSet();
            GetModalDetail getModalDetail = new GetModalDetail();
            List<ModalBodyTypeInfo> List_ModalBodyTypeInfo = new List<ModalBodyTypeInfo>();
            ModalBodyTypeInfo modalBodyTypeInfo = new ModalBodyTypeInfo();

            P_AddOrEdit_MTV_Response MTVEdit = new P_AddOrEdit_MTV_Response();
            List<SelectDropDownList> MTVDropDownList = new List<SelectDropDownList>();
            List<SelectDropDownList> SubMTVDropDownList = new List<SelectDropDownList>();
            if (MTV_ID > 0)
            {
                List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                Dynamic_SP_Params Dynamic_SP_Params = new Dynamic_SP_Params();
                Dynamic_SP_Params.ParameterName = "MTV_ID";
                Dynamic_SP_Params.Val = MTV_ID;
                List_Dynamic_SP_Params.Add(Dynamic_SP_Params);
                MTVEdit = ado.ExecuteSelectSQLMap<P_AddOrEdit_MTV_Response>("SELECT MTV_ID, MT_ID, MTV_CODE, MasterTypeValueName = Name, Sub_MTV_ID ,IsActive Active FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID ORDER BY [Name]", false, 0, ref List_Dynamic_SP_Params);

                List<Dynamic_SP_Params> mtv_parms = new List<Dynamic_SP_Params>()
                {
                    new Dynamic_SP_Params {ParameterName = "MT_ID", Val = MTVEdit.MT_ID}
                };
                MTVDropDownList = ado.Get_DropDownList_Result("SELECT code = MTV_ID , name = Name FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE isActive = 1 AND MT_ID = @MT_ID ORDER BY [Name]", mtv_parms);
            }

            List<SelectDropDownList> MTList = ado.Get_DropDownList_Result("SELECT code = MT_ID , name = Name FROM [EBook_DB].[dbo].[T_Master_Type] with (nolock) WHERE isActive = 1 ORDER BY [Name]");

            getModalDetail.getmodelsize = GetModalSize.modal_md;
            getModalDetail.modaltitle = (MTV_ID == 0 ? "Add New Master Type Value" : "Edit Master Type Value");
            getModalDetail.modalfootercancelbuttonname = "Cancel";
            getModalDetail.modalfootersuccessbuttonname = (MTV_ID == 0 ? "Add" : "Update");
            getModalDetail.modalBodyTypeInfos = new List<ModalBodyTypeInfo>();

            getModalDetail.onclickmodalsuccess = "AddOrEditMTV()";

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Master Type Value ID";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.IsHidden = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Master Type Value ID";
            modalBodyTypeInfo.id = "modalMTV_ID";
            if (MTVEdit.MTV_ID > 0)
            {
                modalBodyTypeInfo.value = MTVEdit.MTV_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList { Name = "readonly", Value = "readonly" }
            };
            if (MTVEdit.MTV_ID > 0)
                List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Master Type Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalSelectMasterTypeName";
            if (MTVEdit.MT_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = MTVEdit.MT_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = MTList;
            modalBodyTypeInfo.ClassName = "form-control select2";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "onfocus", Value = "validate(this)"},
                new AttributeList(){Name = "onkeydown", Value = "validate(this)"},
                new AttributeList(){Name = "onchange", Value = "validate(this)"},
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Master Type Value Code";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Master Type Value Code";
            modalBodyTypeInfo.id = "modalMasterTypeValueCode";
            if (MTVEdit.MT_ID > 0)
            {
                modalBodyTypeInfo.value = MTVEdit.MTV_CODE;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList(){Name = "autocomplete", Value = "off"}
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRInput;
            modalBodyTypeInfo.LabelName = "Master Type Value Name";
            modalBodyTypeInfo.IsRequired = true;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Master Type Value Name";
            modalBodyTypeInfo.id = "modalMasterTypeValueName";
            if (MTVEdit.MT_ID > 0)
            {
                modalBodyTypeInfo.value = MTVEdit.MasterTypeValueName;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.ClassName = "form-control";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);


            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Sub Master Type Name";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.id = "modalMasterTypeNameForFilter";
            int Sub_MT_ID = 0;
            if (MTVEdit.Sub_MTV_ID > 0)
            {
                object Sub_MT_ID_obj;
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Sub_MTV_ID", MTVEdit.Sub_MTV_ID);
                Sub_MT_ID_obj = ado.ExecuteSelectObj("select MT_ID from [EBook_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @Sub_MTV_ID ORDER BY [MT_ID]", ParamsNameValues);
                if (Sub_MT_ID_obj != null)
                {
                    Sub_MT_ID = Convert.ToInt32(Sub_MT_ID_obj);
                }
            }
            if (Sub_MT_ID > 0)
            {
                modalBodyTypeInfo.IsSelectOption = true;
                modalBodyTypeInfo.value = Sub_MT_ID;
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = MTList;
            modalBodyTypeInfo.ClassName = "form-control select2";
            modalBodyTypeInfo.AttributeList = new List<AttributeList>
            {
                new AttributeList {Name = "onchange", Value = "MTVDynamicDropDown(this.value)"},
            };
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRselect;
            modalBodyTypeInfo.LabelName = "Sub MTV Name";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.text;
            modalBodyTypeInfo.PlaceHolder = "Sub MTV Name";
            modalBodyTypeInfo.id = "modalsubmtvname";
            if (MTVEdit.Sub_MTV_ID > 0)
            {
                modalBodyTypeInfo.value = MTVEdit.Sub_MTV_ID;
                List<Dynamic_SP_Params> sub_mtv_parms = new List<Dynamic_SP_Params>()
                {
                    new Dynamic_SP_Params {ParameterName = "Sub_MT_ID", Val = Sub_MT_ID}
                };
                SubMTVDropDownList = ado.Get_DropdownList_MT_ID(Sub_MT_ID, _PublicClaimObjects.username);
            }
            else
            {
                modalBodyTypeInfo.value = "";
            }
            modalBodyTypeInfo.selectLists = SubMTVDropDownList;
            modalBodyTypeInfo.ClassName = "form-control";
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            modalBodyTypeInfo = new ModalBodyTypeInfo();
            modalBodyTypeInfo.ModelBodyType = GetModelBodyType.TRCheckBox;
            modalBodyTypeInfo.LabelName = "Is Active";
            modalBodyTypeInfo.IsRequired = false;
            modalBodyTypeInfo.GetInputTypeString = GetInputStringType.checkbox;
            modalBodyTypeInfo.PlaceHolder = "Is Active";
            modalBodyTypeInfo.id = "modalMTVisActive";
            modalBodyTypeInfo.value = "";
            if (MTVEdit.MTV_ID > 0)
            {
                modalBodyTypeInfo.ischecked = MTVEdit.Active;
            }
            else
            {
                modalBodyTypeInfo.ischecked = true;
            }
            List_ModalBodyTypeInfo.Add(modalBodyTypeInfo);

            getModalDetail.modalBodyTypeInfos = List_ModalBodyTypeInfo;
            HtmlString = CustomFunctions.GetModalWithBody(getModalDetail);
            return HtmlString;
        }


        [HttpPost]
        public IActionResult AddOrEdit_MT([FromBody] P_AddOrEdit_MT_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_MasterType", res, _PublicClaimObjects.username, "");
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_MT", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }
        [HttpPost]
        public IActionResult AddOrEdit_MTV([FromBody] P_AddOrEdit_MTV_Response res)
        {
            bool IsAdd = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Add);
            bool IsEdit = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Edit);
            if ((IsAdd == false) || (IsEdit == false))
                return Content(JsonConvert.SerializeObject("No Rights"));

            P_ReturnMessage_Result response = ado.P_SP_MultiParm_Result("P_AddOrEdit_MasterTypeValue", res, _PublicClaimObjects.username);
            if (response.ReturnCode == false)
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "AddOrEdit_MTV", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
            return Content(JsonConvert.SerializeObject(response));
        }


        [HttpPost]
        public IActionResult Remove_MT([FromBody] int MT_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_MasterType", "MT_ID", MT_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_MT", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }
        [HttpPost]
        public IActionResult Remove_MTV([FromBody] int MTV_ID)
        {
            bool IsDelete = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Master_Setup_Delete);
            if (IsDelete)
            {
                P_ReturnMessage_Result response = ado.P_SP_SingleParm_Result("P_Remove_MasterTypeValue", "MTV_ID", MTV_ID, _PublicClaimObjects.username);
                if (response.ReturnCode == false)
                    StaticPublicObjects.logFile.ErrorLog(FunctionName: "Remove_MTV", SmallMessage: response.ReturnText!, Message: response.ReturnText!);
                return Content(JsonConvert.SerializeObject(response));
            }
            else
            {
                return Content(JsonConvert.SerializeObject("No Rights"));
            }
        }


        [HttpPost]
        public IActionResult DynamicMTVDropDown([FromBody] int MT_ID)
        {
            List<Dynamic_SP_Params> parms = new List<Dynamic_SP_Params>()
            {
                new Dynamic_SP_Params {ParameterName = "MT_ID", Val = MT_ID}
            };
            List<SelectDropDownList> result = ado.Get_DropDownList_Result("SELECT code = MTV_ID , name = Name FROM [EBook_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE isActive = 1 AND MT_ID = @MT_ID ORDER BY [Name]", parms);
            return Content(JsonConvert.SerializeObject(result));
        }
        #endregion  Master Setup

        #region Audit History Setup
        [CustomPageSetupAttribute]
        public IActionResult AuditHistory()
        {
            bool IsView = ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Audit_History_View);
            if (IsView)
            {
                ViewBag.RightsListObj = new { IsView = IsView };
                ViewBag.RightsList = JsonConvert.SerializeObject(ViewBag.RightsListObj);
                DataSet DS = new DataSet();
                (string Name, object Value)[] ParamsNameValues = new (string, object)[1];
                ParamsNameValues[0] = ("Username", _PublicClaimObjects.username);
                DS = ado.ExecuteStoreProcedureDS("P_Get_Audit_History_DropDown_Lists", ParamsNameValues);
                ViewBag.AuditTypeList = JsonConvert.SerializeObject(DS.Tables[0]);
                ViewBag.AuditSourceList = JsonConvert.SerializeObject(DS.Tables[1]);

                return View();
            }
            else
            {
                string ID = "";
                Exception exception = new Exception("You Don't Have Rights To Access Audit History Setup");
                ID = _httpContextAccessor.HttpContext.Session.SetupSessionError("No Rights", "~/Account/AuditHistory", "Audit History", exception);
                return Redirect($"/Error/Index?ID={ID}");
            }
        }
        [HttpPost]
        public IActionResult GetFilterData_AuditHistory_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Audit_History_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_AuditHistory_Result> ResultList = ado.P_Get_Generic_List_SP<P_AuditHistory_Result>("P_Get_AuditHistory_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_AuditHistory_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }

        [HttpPost]
        public IActionResult GetFilterData_AuditColumn_List([FromBody] ReportParams _ReportParams)
        {
            ReportResponse reportResponse = new ReportResponse();
            try
            {
                if (ado.P_Is_Has_Right_From_Username_And_PR_ID_From_Memory(_PublicClaimObjects.username, RightsList_ID.Audit_History_View))
                {
                    List<Dynamic_SP_Params> List_Dynamic_SP_Params = new List<Dynamic_SP_Params>();
                    CustomFunctions.GetKendoFilter(ref _ReportParams, ref List_Dynamic_SP_Params, _PublicClaimObjects, true);

                    List<P_AuditColumn_Result> ResultList = ado.P_Get_Generic_List_SP<P_AuditColumn_Result>("P_Get_AuditColumn_List", ref List_Dynamic_SP_Params);

                    reportResponse.TotalRowCount = CustomFunctions.GetValueFromReturnParameter<long>(List_Dynamic_SP_Params, "TotalRowCount", typeof(long));
                    reportResponse.ResultData = ResultList;
                    reportResponse.response_code = true;
                }
                else
                {
                    reportResponse.TotalRowCount = 0;
                    reportResponse.ResultData = null;
                    reportResponse.response_code = false;
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "GetFilterData_AuditColumn_List", SmallMessage: ex.Message, Message: ex.ToString());
                reportResponse.TotalRowCount = 0;
                reportResponse.ResultData = null;
                reportResponse.response_code = false;
            }
            return Globals.GetAjaxJsonReturn(reportResponse);
        }
        #endregion Audit History Setup
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EBook_Models.App_Models
{
    public class AppEnum
    {
        public AppEnum() { }
        public enum CustomValidationType
        {
            Custom = 0,
            Date = 1,
            DateIgnoreEmpty = 2,
            Email = 3,
            EmailIgnoreEmpty = 4,
            Numeric = 5,
            NumericIgnoreEmpty = 6,
        }
        public struct JsonIgnorePropertyType
        {
            public const int Standard = 0;
            public const int None = 1;
            public const int HideProperty = 2;
        }
        public struct CaptchaVersion
        {
            public const string Version3 = "Version3";
            public const string Version2Robot = "Version2Robot";
            public const string Version2Invisible = "Version2Invisible";
        }
        public struct KendoGridFilterType
        {
            public const string contains = "contains";
            public const string notequal = "neq";
            public const string equal = "eq";
            public const string doesnotcontain = "doesnotcontain";
            public const string startswith = "startswith";
            public const string endswith = "endswith";
            public const string isnull = "isnull";
            public const string isnotnull = "isnotnull";
            public const string orderno = "orderno";
            public const string isempty = "isempty";
            public const string isnotempty = "isnotempty";
            public const string isequalorgreather = "gte";
            public const string greather = "gt";
            public const string isequalorless = "lte";
            public const string less = "lt";
            public const string isnullorempty = "isnullorempty";
            public const string isnotnullorempty = "isnotnullorempty";
            public const string inlistfilter = "inlistfilter";
            public const string notinlistfilter = "notinlistfilter";
        }
        public struct KendoGridFilterSRFieldType
        {
            public const string String = "string";
            public const string UpperString = "upstring";
            public const string LowerString = "lwstring";
            public const string Int = "int";
            public const string Float = "float";
            public const string Date = "date";
            public const string Datetime = "datetime";
            public const string Boolean = "boolean";
        }
        public struct KendoGridFilterFieldType
        {
            public const string String = "string";
            public const string Number = "number";
            public const string Date = "date";
            public const string Boolean = "boolean";
        }
        public struct ExcelColumnType
        {
            public const string General = "General";
            public const string Date_mmddyyyy = "mm/dd/yyyy";
            public const string Time_hhmmss = "hh:mm:ss";
            public const string DateTime_mmddyyyyhhmmss = "mm/dd/yyyy hh:mm:ss";
            public const string Accounting = "$ #,##0.00;[Red]($ #,##0.00)";
            public const string Text = "@";
            public const string Number = "0.00";
            public const string Percentage = "0.00%";
            public const string Scientific = "0.00E+00";
            public const string Currency = "$ #,##0.00";
            public const string Fraction = "# ?/?";
            //public const string Custom = "0.0\" \"m/s";
        }
        public struct MasterTypeID
        {
            public const int Order_Comment_Importance_Level = 110;
            public const int Order_Document_Type = 111;
            public const int Order_Event_Source = 112;
            public const int Item_To_Ship = 117;
            public const int Item_Code_Type = 118;
            public const int Packing_Code = 119;
            public const int Weight_Unit = 120;
            public const int Dimension_Unit = 121;
            public const int Order_Special_Instruction_Type = 124;
            public const int Service_Type = 125;
        }
        public struct ImportOrderPageSource
        {
            public const string UploadOrderNew = "UPLOAD-ORDER-NEW";
            public const string UploadOrderOld = "UPLOAD-ORDER-OLD";
            public const string ASN = "ASN";
        }
        public struct ImportOrderFileSource
        {
            public const string CommenerceHub = "COMMERENCE-HUB";
            public const string ASN_EXCEL = "ASN-EXCEL";
            public const string ASN_CSV = "ASN-CSV";
            public const string ASN_XML = "ASN-XML";
            public const string API = "API";
            public const string ASN_EDI_850 = "ASN-EDI-850";
        }
        public struct CommerenceHubSeller
        {
            public const string SellerKey = "AF4C1BC7-4903-4196-BE9B-D251C0A14024";
        }
        public struct AutoUser
        {
            public const string PPAutoUser = "PPLUS";
        }
        public struct ImportOrderFileSourceSetupType
        {
            public const string Seller_Code = "SELLER-CODE";
            public const string BillTo_Code = "BILLTO-CODE";
            public const string SellTo_Partner = "SELLTO-PARTNER";
            public const string ShipFrom_AddressCode = "SHIPFROM-ADDRESSCODE";
            public const string ShipFrom_Email = "SHIPFROM-EMAIL";
            public const string ShipTo_Email = "SHIPTO-EMAIL";
            public const string Pickup_ServiceCode = "PICKUP-SERVICECODE";
            public const string Delivery_ServiceCode = "DELIVERY-SERVICECODE";
            public const string Item_Code = "ITEM-CODE";
            public const string Item_Dimension = "ITEM-DIMENSION";
            public const string Item_Dimension_Unit = "ITEM-DIMENSION-UNIT";
            public const string Item_Weight = "ITEM-WEIGHT";
            public const string Item_Weight_Unit = "ITEM-WEIGHT-UNIT";
            public const string Item_Value = "ITEM-VALUE";
            public const string Item_PackingCode = "ITEM-PACKINGCODE";
            public const string ItemToShip_Code = "ITEMTOSHIP-CODE";
            public const string Pickup_Driver_Instruction = "PICKUP-DRIVER-INST";
            public const string Delivery_Driver_Instruction = "DELIVERY-DRIVER-INST";
            public const string Order_Initial_Comment_Is_Public = "INITIAL-COM-PUBLIC";
            public const string Order_Initial_Comment = "ORDER-INITIAL-COM";
            public const string Order_Initial_Comment_Is_Public_2 = "INITIAL-COM-PUBLIC2";
            public const string Order_Initial_Comment_2 = "ORDER-INITIAL-COM2";
        }
        public struct AddressType
        {
            public const int ShipFrom = 130100;
            public const int ShipTo = 130101;
            public const int BillTo = 130102;
        }
        public struct SeviceLevelTypeID
        {
            public const int Pickup = 125100;
            public const int Delivery_ForwardShipment = 125101;
            public const int Delivery_ReverseShipment = 125102;
        }
        public struct OrderSource
        {
            public const int Web = 101100;
            public const int API = 101101;
            public const int ASN = 101102;
            public const int Mobile = 101103;
            public const int Guest = 101104;
            public const int Import_Client_User = 101105;
            public const int Import_Metro_User = 101106;
            public const int PPlus = 101107;
        }
        public struct OrderSubSource
        {
            public const string Excel = "EXCEL";
            public const string CSV = "CSV";
            public const string EDI = "EDI";
            public const string EDI_850 = "EDI-850";
            public const string EDI_204 = "EDI-204";
            public const string JSON = "JSON";
            public const string XML = "XML";
            public const string Custom_Excel = "CUSTOM-EXCEL";
            public const string Custom_CSV = "CUSTOM-CSV";
            public const string Custom_XML = "CUSTOM-XML";
        }
        public struct ZipCodeType
        {
            public const int BillTo = 1;
            public const int ShipFrom = 2;
            public const int ShipTo = 3;
        }
        public struct WebTokenExpiredTime
        {
            public const int Seconds = (60 * 20);
            public const int Minites = 20;
            public const int Hours = 0;
            public const int Days = 0;
        }
        public struct NewTokenExpiry
        {
            public const int Seconds = (24 * 60 * 60);
            public const int Minites = (24 * 60);
            public const int Hours = 24;
            public const int Days = 1 * 365;
        }
        public struct BillingType
        {
            public const string Prepaid = "110";
            public const string PayBeforeDelivery = "120";
            public const string PayAtTimeOfOrderReg = "130";
        }
        public struct AttachmentType
        {
            public const int OrderLevel = 128100;
            public const int ItemLevel = 128101;
            public const int ItemScanLevel = 128102;
        }
        public struct Units
        {
            public const double Grams = 1;
            public const double KiloGrams = 0.001;
            public const double Milligram = 1000;
            public const double Pounds = 0.00220462;
            public const double KGtoPound = 2.20462;
            public const double Ounces = 0.035274;
            public const double Tonnes = 0.000001;
            public const double DimensionInches = 1.00 / 1728.00;
            public const double DimensionCentiMeters = 0.00003531466247;
            // Add Remaining units / values
        }
        public struct APIType
        {
            public const int POMSAPI = 10120;
        }
        public struct APISourceName
        {
            public const string GetLogAllFailedRequest = "GLAFR";
            public const string GetOnChallenge = "GOC";
            public const string GetValidateUserToken = "GVUT";
            public const string SignInAsync = "SIA";
            public const string RefreshToken = "RT";
            public const string ResetMemoryCache = "RMC";
            public const string GetDocumentTypeList = "GDTL";
            public const string GetPackingDetaillList = "GPDL";
            public const string GetItemToShipList = "GITSL";
            public const string GetItemTypeList = "GITL";
            public const string GetServiceLevelList = "GSLL";
            public const string GetOrderIdentifierFieldsList = "GOIFL";
            public const string GetClientSpecialServicesList = "GCSSL";
            public const string GetSellerClientList = "GSCL";
            public const string CreateOrderAPI = "CO-API";
            public const string LogOut = "LO";
            public const string GetOrderRegisterSettingDetail = "GORSD";
            public const string ValidateCreateOrderAPIReq = "VCOAR";
            public const string GetSellerClientListFullDetail = "GSCLFD";
            public const string OrderDetailPage = "ODP";
            public const string ShareTokenRequestSet = "STRS";
            public const string ShareTokenRequestGet = "STRG";
            public const string GetPriceKey = "GPK";
            public const string GetSavedAddressList = "GSAL";
            public const string GetPriceWP = "GPWP";
            public const string GetOrderImportFieldsNameAndSetting = "GOIFNAS";
            public const string CreateOrderAPIList = "CO-API2";
            public const string GetCreateOrderRequestList = "GCORL";
            public const string SaveOrderProcessRequestJson = "SOPRJ";
            public const string GetOrderProcessRequestJson = "GOPRJ";
            public const string GetPriceWPFromQuoteID = "GPWFQ";
            public const string GetSearchSkuList = "GSSL";
            public const string GoogleAddressValidation = "GAV";
            public const string ProcessOrderImportFile = "POIF";
            public const string ProcessOrderFromRequestIDs = "ProcessOrderFromRequestIDs";
            public const string GoogleAddressValidationWrapper = "GAVW";
        }
        public struct APIMethods
        {
            public const int SignInAsync = 60010;
            public const int RefreshToken = 60020;
            public const int ResetMemoryCache = 60030;
            public const int GetDocumentTypeList = 60040;
            public const int GetPackingDetaillList = 60050;
            public const int GetItemToShipList = 60060;
            public const int GetItemTypeList = 60070;
            public const int GetServiceLevelList = 60080;
            public const int GetOrderIdentifierFieldsList = 60090;
            public const int GetClientSpecialServicesList = 60100;
            public const int GetSellerClientList = 60110;
            public const int CreateOrderAPI = 60120;
            public const int LogOut = 60130;
            public const int GetOrderRegisterSettingDetail = 60140;
            public const int ValidateCreateOrderAPIReq = 60150;
            public const int GetSellerClientListFullDetail = 60160;
            public const int OrderDetailPage = 60170;
            public const int ShareTokenRequestSet = 60180;
            public const int ShareTokenRequestGet = 60190;
            public const int GetPriceKey = 60200;
            public const int GetSavedAddressList = 60210;
            public const int GetPriceWP = 60220;
            public const int GetOrderImportFieldsNameAndSetting = 60230;
            public const int CreateOrderAPIList = 60240;
            public const int GetCreateOrderRequestList = 60250;
            public const int SaveOrderProcessRequestJson = 60260;
            public const int GetOrderProcessRequestJson = 60270;
            public const int GetPriceWPFromQuoteID = 60280;
            public const int GetSearchSkuList = 60290;
            public const int GoogleAddressValidation = 60300;
            public const int ProcessOrderImportFile = 60310;
            public const int ProcessOrderFromRequestIDs = 60340;
            public const int GoogleAddressValidationWrapper = 60350;
        }
        public struct CacheType
        {
            public const string TConfig = "TConfig";
            public const string TAPIUserMapRequestLimit = "TAPIUserMapRequestLimit";
            public const string TAPIRemoteDomainIPRequestLimit = "TAPIRemoteDomainIPRequestLimit";
            public const string MetropolitanAdditionalApprovers = "MetropolitanAdditionalApprovers";
            public const string MetropolitanUserAPIMap = "MetropolitanUserAPIMap";
            public const string TApiRemoteDomainIPWhiteListing = "TApiRemoteDomainIPWhiteListing";
            public const string TUsers = "TUsers";
            public const string MetropolitanWebUserLogin = "MetropolitanWebUserLogin";
            public const string MetropolitanTimeZone = "MetropolitanTimeZone";
            public const string MetropolitanCustomer = "MetropolitanCustomer";
            public const string TMasterTypeValue = "TMasterTypeValue";
            public const string TServiceType = "TServiceType";
            public const string TSubServiceType = "TSubServiceType";
            public const string TClientServiceType = "TClientServiceType";
            public const string TServiceTypeDetail = "TServiceTypeDetail";
            public const string TOrderIdentifierFields = "TOrderIdentifierFields";
            public const string TOrderClientIdentifierFields = "TOrderClientIdentifierFields";
            public const string TServiceLevelSpecialService = "TServiceLevelSpecialService";
            public const string TSpecialServicesList = "TSpecialServicesList";
            public const string TClientServiceLevelSpecialService = "TClientServiceLevelSpecialService";
            public const string TIgnoreAPIErrorsList = "TIgnoreAPIErrorsList";
            public const string TClientIgnoreAPIErrorsList = "TClientIgnoreAPIErrorsList";
            public const string TSellerList = "TSellerList";
            public const string TSellerBillToMapping = "TSellerBillToMapping";
            public const string TSellerPartnerMapping = "TSellerPartnerMapping";
            public const string TSellerPartnerList = "TSellerPartnerList";
            public const string TSellerTariffMapping = "TSellerTariffMapping";
            public const string TTariffList = "TTariffList";
            public const string TSellerAllMappingPriceKey = "TSellerAllMappingPriceKey";
            public const string QuotesTPriceKey = "QuotesTPriceKey";
            public const string TGetRoleRightsFromRoleID = "TGetRoleRightsFromRoleID";
            public const string TGetRoleRightsFromUsername = "TGetRoleRightsFromUsername";
            public const string TIsHasRightFromRoleID = "TIsHasRightFromRoleID";
            public const string TIsHasRightFromUsername = "TIsHasRightFromUsername";
            public const string TGetUserOrderDetailGridList = "TGetUserOrderDetailGridList";
            public const string TGetPagesInfoByUser = "TGetPagesInfoByUser";
            public const string ReadOnlyServer = "ReadOnlyServer";
            public const string TGetQuoteAPIToken = "TGetQuoteAPIToken";
            public const string TGetOrderGUIDByOrderID = "TGetOrderGUIDByOrderID";
            public const string TGetOrderAccessByGUID = "TGetOrderAccessByGUID";
            public const string TGetArchiveDetailByOrderID = "TGetArchiveDetailByOrderID";
            public const string TGetOrderDetailAssignmentByGUID = "TGetOrderDetailAssignmentByGUID";
            public const string TGetOrderDetailBasicSummaryByGUID = "TGetOrderDetailBasicSummaryByGUID";
            public const string TGetOrderDetailClientIdentifierByGUID = "TGetOrderDetailClientIdentifierByGUID";
            public const string TGetOrderDetailSpecialServicesByGUID = "TGetOrderDetailSpecialServicesByGUID";
            public const string TGetOrderDetailAccessLogByGUID = "TGetOrderDetailAccessLogByGUID";
            public const string TGetOrderDetailItemDetailByGUID = "TGetOrderDetailItemDetailByGUID";
            public const string TGetOrderDetailInvoiceHeaderByGUID = "TGetOrderDetailInvoiceHeaderByGUID";
            public const string TGetOrderDetailInvoiceLineByGUID = "TGetOrderDetailInvoiceLineByGUID";
            public const string TGetOrderDetailCommentsByGUID = "TGetOrderDetailCommentsByGUID";
            public const string TGetOrderDetailEventsByGUID = "TGetOrderDetailEventsByGUID";
            public const string TGetOrderDetailDocumentsByGUID = "TGetOrderDetailDocumentsByGUID";
            public const string TGetOrderDetailScanHistoryByGUID = "TGetOrderDetailScanHistoryByGUID";
            public const string TGetOrderDetailManifestByGUID = "TGetOrderDetailManifestByGUID";
            public const string TGetOrderDetailPOPPODByGUID = "TGetOrderDetailPOPPODByGUID";
            public const string TGetOrderDetailChangeLogByGUID = "TGetOrderDetailChangeLogByGUID";
            public const string TGetSellerImportFieldsNameSetting = "TGetSellerImportFieldsNameSetting";
            public const string TGoogleMapsAPICall = "TGoogleMapsAPICall";
            public const string TGetSellerBillToFromPinnacleUser = "TGetSellerBillToFromPinnacleUser";
            public const string TGetShipmentTypeFromServiceLevel = "TGetShipmentTypeFromServiceLevel";
            public const string TGetSearchSkuList = "TGetSearchSkuList";
            public const string TGoogleAddressValidationAPICall = "TGoogleAddressValidationAPICall";
            public const string TGetGoogleAddressValidationJson = "TGetGoogleAddressValidationJson";
            public const string TGetSellerAddressList = "TGetSellerAddressList";
            public const string TGetAddressList = "TGetAddressList";
            public const string TGetImportOrderFileSourceSetup = "TGetImportOrderFileSourceSetup";
        }
        public struct CacheSubType
        {
            public const string P_Get_API_User_Map_Request_Limit = "P_Get_API_User_Map_Request_Limit";
            public const string P_Get_API_User_Map = "P_Get_API_User_Map";
            public const string P_Get_API_RemoteDomain_IP_Request_Limit = "P_Get_API_RemoteDomain_IP_Request_Limit";
            public const string P_Get_User_Info = "P_Get_User_Info";
            public const string P_Get_API_RemoteDomain_IP_WhiteListing = "P_Get_API_RemoteDomain_IP_WhiteListing";
            public const string P_Get_T_Config_Detail = "P_Get_T_Config_Detail";
            public const string P_Get_List_By_ID = "P_Get_List_By_ID";
            public const string P_Get_Client_Service_Type_List = "P_Get_Client_Service_Type_List";
            public const string P_Get_Order_Client_Identifier_Fields_List = "P_Get_Order_Client_Identifier_Fields_List";
            public const string P_Get_Client_Special_Service_List = "P_Get_Client_Special_Service_List";
            public const string P_Get_Client_Ignore_API_Errors_List = "P_Get_Client_Ignore_API_Errors_List";
            public const string P_Get_Seller_All_MappingList_ReturnJson = "P_Get_Seller_All_MappingList_ReturnJson";
            public const string P_Get_SellToClientList = "P_Get_SellToClientList";
            public const string P_GetDBServerForDataRead_2 = "P_GetDBServerForDataRead_2";
            public const string P_Get_Price_Key = "P_Get_Price_Key";
            public const string P_Get_Role_Rights_From_RoleID = "P_Get_Role_Rights_From_RoleID";
            public const string P_Get_Role_Rights_From_Username = "P_Get_Role_Rights_From_Username";
            public const string P_Is_Has_Right_From_RoleID = "P_Is_Has_Right_From_RoleID";
            public const string P_Is_Has_Right_From_Username = "P_Is_Has_Right_From_Username";
            public const string P_Get_User_Order_Detail_Grid_List = "P_Get_User_Order_Detail_Grid_List";
            public const string P_Get_Pages_Info_By_User = "P_Get_Pages_Info_By_User";
            public const string GetQuoteAPIToken = "GetQuoteAPIToken";
            public const string P_Get_Order_GUID_By_OrderID = "P_Get_Order_GUID_By_OrderID";
            public const string P_Get_OrderAccess_By_GUID = "P_Get_OrderAccess_By_GUID";
            public const string P_Get_ArchiveDetail_By_OrderID = "P_Get_ArchiveDetail_By_OrderID";
            public const string P_Get_OrderDetail_Assignment_By_GUID = "P_Get_OrderDetail_Assignment_By_GUID";
            public const string P_Get_OrderDetail_BasicSummary_By_GUID = "P_Get_OrderDetail_BasicSummary_By_GUID";
            public const string P_Get_OrderDetail_ClientIdentifier_By_GUID = "P_Get_OrderDetail_ClientIdentifier_By_GUID";
            public const string P_Get_OrderDetail_SpecialServices_By_GUID = "P_Get_OrderDetail_SpecialServices_By_GUID";
            public const string P_Get_OrderDetail_AccessLog_By_GUID = "P_Get_OrderDetail_AccessLog_By_GUID";
            public const string P_Get_OrderDetail_ItemDetail_By_GUID = "P_Get_OrderDetail_ItemDetail_By_GUID";
            public const string P_Get_OrderDetail_InvoiceHeader_By_GUID = "P_Get_OrderDetail_InvoiceHeader_By_GUID";
            public const string P_Get_OrderDetail_InvoiceLine_By_GUID = "P_Get_OrderDetail_InvoiceLine_By_GUID";
            public const string P_Get_OrderDetail_Comments_By_GUID = "P_Get_OrderDetail_Comments_By_GUID";
            public const string P_Get_OrderDetail_Events_By_GUID = "P_Get_OrderDetail_Events_By_GUID";
            public const string P_Get_OrderDetail_Documents_By_GUID = "P_Get_OrderDetail_Documents_By_GUID";
            public const string P_Get_OrderDetail_ScanHistory_By_GUID = "P_Get_OrderDetail_ScanHistory_By_GUID";
            public const string P_Get_OrderDetail_Manifest_By_GUID = "P_Get_OrderDetail_Manifest_By_GUID";
            public const string P_Get_OrderDetail_POPPOD_By_GUID = "P_Get_OrderDetail_POPPOD_By_GUID";
            public const string P_Get_OrderDetail_ChangeLog_By_GUID = "P_Get_OrderDetail_ChangeLog_By_GUID";
            public const string P_Get_Seller_Import_Fields_Name_Setting = "P_Get_Seller_Import_Fields_Name_Setting";
            public const string GoogleMapsAPICall = "GoogleMapsAPICall";
            public const string P_Get_SellerBillTo_From_Pinnacle_User = "P_Get_SellerBillTo_From_Pinnacle_User";
            public const string P_Get_ShipmentType_From_ServiceLevel = "P_Get_ShipmentType_From_ServiceLevel";
            public const string P_Get_Search_Sku_List = "P_Get_Search_Sku_List";
            public const string GoogleAddressValidationAPICall = "GoogleAddressValidationAPICall";
            public const string P_Get_Google_Address_Validation_Json = "P_Get_Google_Address_Validation_Json";
            public const string P_Get_SellerAddressList = "P_Get_SellerAddressList";
            public const string P_Get_AddressList = "P_Get_AddressList";
            public const string P_Get_Import_Order_File_Source_Setup = "P_Get_Import_Order_File_Source_Setup";
            public const string P_Get_List_By_ID_2 = "P_Get_List_By_ID_2";
        }
        public struct Database_Name
        {
            public const string POMS = "POMS"; //default
            public const string EBook = "EBook"; //default
        }
        public struct ApplicationId
        {
            public const int EBookAppID = 148111;
            public const int AppID = 148104;
        }
        public struct ApplicationName
        {
            public const string AppName = "EBook";
        }
        public struct Granularity
        {
            public const string GRANULARITY_UNSPECIFIED = "GRANULARITY_UNSPECIFIED";
            public const string SUB_PREMISE = "SUB_PREMISE";
            public const string PREMISE = "PREMISE";
            public const string PREMISE_PROXIMITY = "PREMISE_PROXIMITY";
            public const string BLOCK = "BLOCK";
            public const string ROUTE = "ROUTE";
            public const string OTHER = "OTHER";
        }
        public struct ComponentType
        {
            public const string administrative_area_level_1 = "administrative_area_level_1";
            public const string administrative_area_level_2 = "administrative_area_level_2";
            public const string administrative_area_level_3 = "administrative_area_level_3";
            public const string administrative_area_level_4 = "administrative_area_level_4";
            public const string administrative_area_level_5 = "administrative_area_level_5";
            public const string administrative_area_level_6 = "administrative_area_level_6";
            public const string administrative_area_level_7 = "administrative_area_level_7";
            public const string archipelago = "archipelago";
            public const string colloquial_area = "colloquial_area";
            public const string continent = "continent";
            public const string country = "country";
            public const string establishment = "establishment";
            public const string finance = "finance";
            public const string floor = "floor";
            public const string food = "food";
            public const string general_contractor = "general_contractor";
            public const string geocode = "geocode";
            public const string health = "health";
            public const string intersection = "intersection";
            public const string landmark = "landmark";
            public const string locality = "locality";
            public const string natural_feature = "natural_feature";
            public const string neighborhood = "neighborhood";
            public const string place_of_worship = "place_of_worship";
            public const string plus_code = "plus_code";
            public const string point_of_interest = "point_of_interest";
            public const string political = "political";
            public const string post_box = "post_box";
            public const string postal_code = "postal_code";
            public const string postal_code_prefix = "postal_code_prefix";
            public const string postal_code_suffix = "postal_code_suffix";
            public const string postal_town = "postal_town";
            public const string premise = "premise";
            public const string room = "room";
            public const string route = "route";
            public const string street_address = "street_address";
            public const string street_number = "street_number";
            public const string sublocality = "sublocality";
            public const string sublocality_level_1 = "sublocality_level_1";
            public const string sublocality_level_2 = "sublocality_level_2";
            public const string sublocality_level_3 = "sublocality_level_3";
            public const string sublocality_level_4 = "sublocality_level_4";
            public const string sublocality_level_5 = "sublocality_level_5";
            public const string subpremise = "subpremise";
            public const string town_square = "town_square";
        }
        public struct ConfirmationLevel
        {
            public const string CONFIRMATION_LEVEL_UNSPECIFIED = "GRANULARITY_UNSPECIFIED";
            public const string CONFIRMED = "SUB_PREMISE";
            public const string UNCONFIRMED_BUT_PLAUSIBLE = "PREMISE";
            public const string UNCONFIRMED_AND_SUSPICIOUS = "PREMISE_PROXIMITY";
        }

        public struct JavascriptValidationType
        {
            public const string none = "";
            public const string checkboxrequired = "checkboxrequired";
            public const string requiredvalue = "requiredvalue";
            public const string numbernotemtpy = "numbernotemtpy";
            public const string positivenumber = "positivenumber";
            public const string negativenumber = "negativenumber";
            public const string withoutzeronumber = "withoutzeronumber";
            public const string textwithempty = "textwithempty";
            public const string textnotempty = "textnotempty";
            public const string datewithempty = "datewithempty";
            public const string datenotempty = "datenotempty";
        }
        public struct GetModelBodyType
        {
            public const string TRInput = "TRInput";
            public const string TRselect = "TRselect";
            public const string TRTextArea = "TRTextArea";
            public const string TRCheckBox = "TRCheckBox";
        }
        public struct GetInputStringType
        {
            public const string button = "button";
            public const string checkbox = "checkbox";
            public const string color = "color";
            public const string date = "date";
            public const string datetime = "datetime";
            public const string datetime_local = "datetime-local";
            public const string email = "email";
            public const string file = "file";
            public const string hidden = "hidden";
            public const string image = "image";
            public const string month = "month";
            public const string number = "number";
            public const string password = "password";
            public const string password1 = "password1";
            public const string radio = "radio";
            public const string range = "range";
            public const string reset = "reset";
            public const string search = "search";
            public const string submit = "submit";
            public const string tel = "tel";
            public const string text = "text";
            public const string text1 = "text1";
            public const string time = "time";
            public const string url = "url";
            public const string week = "week";
        }
        public struct GetModalSize
        {
            public const string modal_sm = "modal-sm";
            public const string modal_md = "modal-md";
            public const string modal_lg = "modal-lg";
            public const string modal_xl = "modal-xl";
        }
        public struct GridReportsListGUID
        {
            public const string Task_Detail_Grid = "78007833-1daa-43e5-a893-cdc7f4d0bbf8";
        }
        public struct GridReportsListGRL_ID
        {
            public const int Task_Detail_Grid = 1;
        }
        public struct RightsList_ID
        {
            #region General;
            public const int Admin = 100100;
            public const int Scan_Special_Permission = 100101;
            public const int Can_Scan_Non_Active_Order = 100102;
            #endregion General;      
            #region PageSetup;     
            public const int Page_Setup_View = 203100;
            public const int Page_Setup_Add = 203101;
            public const int Page_Setup_Edit = 203102;
            public const int Page_Setup_Delete = 203103;
            #endregion PageSetup;
            #region MasterSetup;
            public const int Master_Setup_View = 207100;
            public const int Master_Setup_Add = 207101;
            public const int Master_Setup_Edit = 207102;
            public const int Master_Setup_Delete = 207103;
            #endregion MasterSetup;
            #region OrderDetail;     
            public const int Order_Detail_View = 401100;
            public const int Basic_Summary_View = 401101;
            public const int Advance_Summary_View = 401102;
            public const int Custom_Information_View = 401103;
            public const int Order_Basic_Information_View = 401104;
            public const int Origin__Destination_And_Client_Info_View = 401105;
            public const int Shipping_Info_View = 401106;
            public const int Item_Details_View = 401107;
            public const int Invoice_View = 401108;
            public const int Invoice_Allocation_With_Cost_View = 401109;
            public const int Recheck_Invoice_View = 401110;
            public const int Comments_View = 401111;
            public const int Activities___Events_View = 401112;
            public const int Document_Thumnail_View = 401113;
            public const int Documents_View = 401114;
            public const int Barcode_Scan_History_View = 401115;
            public const int Manifest_View = 401116;
            public const int POP_And_POD_Thumnail_View = 401117;
            public const int POP_And_POD_View = 401118;
            public const int Change_Log_View = 401119;
            public const int Over_Shortage_And_Damage = 401120;
            #endregion OrderDetail;      
            #region SellerAllocationSetup;     
            public const int Seller_Allocation_List_View = 800100;
            public const int Seller_Allocation_List_Tab_View = 800101;
            public const int Seller_Allocation_Mapping_Tab_View = 800102;
            public const int User_Seller_Allocation_Mapping_Tab_View = 800103;
            public const int Seller_Allocation_List_Edit = 800104;
            public const int Seller_Allocation_List_Add = 800105;
            public const int Seller_Allocation_List_Delete = 800106;
            public const int Seller_Allocation_Mapping_Edit = 800107;
            public const int Seller_Allocation_Mapping_Add = 800108;
            public const int Seller_Allocation_Mapping_Delete = 800109;
            public const int User_Seller_Allocation_Mapping_Edit = 800110;
            public const int User_Seller_Allocation_Mapping_Add = 800111;
            public const int User_Seller_Allocation_Mapping_Delete = 800112;
            public const int Account_Manager_List_View = 800113;
            public const int Account_Manager_List_Add = 800114;
            public const int Account_Manager_List_Edit = 800115;
            public const int Account_Manager_List_Delete = 800116;
            public const int Account_Manager_CSR_Mapping_List_View = 800117;
            public const int Account_Manager_CSR_Mapping_List_Add = 800118;
            public const int Account_Manager_CSR_Mapping_List_Edit = 800119;
            public const int Account_Manager_CSR_Mapping_List_Delete = 800120;
            #endregion SellerAllocationSetup;    
            #region UserSetup;     
            public const int User_Setup_View = 202100;
            public const int User_Setup_Add = 202101;
            public const int User_Setup_Edit = 202102;
            public const int User_Setup_Delete = 202103;
            #endregion UserSetup;
            #region PageChart;     
            public const int Page_Chart_View = 212100;
            #endregion ;
            #region RoleSetup;     
            public const int Role_Setup_View = 204100;
            public const int Role_Setup_Add = 204101;
            public const int Role_Setup_Edit = 204102;
            public const int Role_Setup_Delete = 204103;
            #endregion RoleSetup;
            #region RightsSetup;     
            public const int Right_Setup_View = 205100;
            public const int Right_Setup_Add = 205101;
            public const int Right_Setup_Edit = 205102;
            public const int Right_Setup_Delete = 205103;
            #endregion RightsSetup;
            #region DepartmentSetup;     
            public const int Department_Setup_View = 208100;
            public const int Department_Setup_Add = 208101;
            public const int Department_Setup_Edit = 208102;
            public const int Department_Setup_Delete = 208103;
            #endregion DepartmentSetup;
            #region AuditHistory;     
            public const int Audit_History_View = 206100;
            #endregion ;
            #region EventSetup;     
            public const int Event_Setup_View = 1000100;
            public const int Event_Setup_Add = 1000101;
            public const int Event_Setup_Edit = 1000102;
            public const int Event_Setup_Delete = 1000103;
            #endregion EventSetup;
            #region HubSetup;     
            public const int Hub_Setup_View = 1001100;
            public const int Hub_Setup_Add = 1001101;
            public const int Hub_Setup_Edit = 1001102;
            public const int Hub_Setup_Delete = 1001103;
            public const int Address_List_View = 1001104;
            public const int Address_List_Add = 1001105;
            public const int Address_List_Edit = 1001106;
            public const int Address_List_Delete = 1001107;
            public const int Address_List_Approval = 1001108;
            public const int Airport_List_View = 1001109;
            public const int Airport_List_Add = 1001110;
            public const int Airport_List_Edit = 1001111;
            public const int Airport_List_Delete = 1001112;
            public const int Time_Zone_List_View = 1001113;

            #endregion HubSetup;
            #region UserSellerSetup;     
            public const int User_Seller_Setup_View = 1005100;
            public const int User_Seller_Setup_Add = 1005101;
            public const int User_Seller_Setup_Edit = 1005102;
            public const int User_Seller_Setup_Delete = 1005103;
            #endregion UserSellerSetup;
            #region SellerSetup;     
            public const int Seller_Setup_View = 1006100;
            public const int Seller_Setup_Add = 1006101;
            public const int Seller_Setup_Edit = 1006102;
            public const int Seller_Setup_Delete = 1006103;
            #endregion SellerSetup;
            #region DefaultSetup;     
            public const int Default_Setup_View = 1003100;
            public const int Default_Setup_Add = 1003101;
            public const int Default_Setup_Edit = 1003102;
            public const int Default_Setup_Delete = 1003103;
            #endregion DefaultSetup;
            #region ServiceSetup;     
            public const int Service_Setup_View = 1004100;
            public const int Service_Setup_Add = 1004101;
            public const int Service_Setup_Edit = 1004102;
            public const int Service_Setup_Delete = 1004103;
            #endregion ServiceSetup;
            #region ApplicationSetup;     
            public const int Application_Setup_View = 1002100;
            public const int Application_Setup_Add = 1002101;
            public const int Application_Setup_Edit = 1002102;
            public const int Application_Setup_Delete = 1002103;
            #endregion ApplicationSetup;
            #region TaskManagementSetup;     
            public const int Task_Management_View = 1007100;
            public const int Task_Management_Add = 1007101;
            public const int Task_Management_Edit = 1007102;
            public const int Task_Management_Delete = 1007103;
            #endregion TaskManagementSetup;
            #region LogiwaClients;     
            public const int Inventory_Logiwa_Clients_View = 1200100;
            public const int Inventory_Logiwa_Clients_Add = 1200101;
            public const int Inventory_Logiwa_Clients_Edit = 1200102;
            public const int Inventory_Logiwa_Clients_Delete = 1200103;
            #endregion LogiwaClients;
        }
        public struct RightsList_Code
        {
            #region General;     
            public const string Scan_Special_Permission = "SCAN_SPECIAL_PERMISSION";
            public const string Can_Scan_Non_Active_Order = "CAN_SCAN_NON_ACTIVE_ORDER";
            #endregion General;  
            #region PageSetup;   
            public const string Page_Setup_View = "PAGE_SETUP_VIEW";
            public const string Page_Setup_Add = "PAGE_SETUP_ADD";
            public const string Page_Setup_Edit = "PAGE_SETUP_EDIT";
            public const string Page_Setup_Delete = "PAGE_SETUP_DELETE";
            #endregion PageSetup;  
            #region MasterSetup;     
            public const string Master_Setup_View = "MASTER_SETUP_VIEW";
            public const string Master_Setup_Add = "MASTER_SETUP_ADD";
            public const string Master_Setup_Edit = "MASTER_SETUP_EDIT";
            public const string Master_Setup_Delete = "MASTER_SETUP_DELETE";
            #endregion MasterSetup;
            #region OrderDetail;  
            public const string Order_Detail_View = "ORDER_DETAIL_VIEW";
            public const string Basic_Summary_View = "BASIC_SUMMARY_VIEW";
            public const string Advance_Summary_View = "ADVANCE_SUMMARY_VIEW";
            public const string Custom_Information_View = "CUSTOM_INFORMATION_VIEW";
            public const string Order_Basic_Information_View = "ORDER_BASIC_INFORMATION_VIEW";
            public const string Origin__Destination_And_Client_Info_View = "ORIGIN,_DESTINATION_&_CLIENT_INFO_VIEW";
            public const string Shipping_Info_View = "SHIPPING_INFO_VIEW";
            public const string Item_Details_View = "ITEM_DETAILS_VIEW";
            public const string Invoice_View = "INVOICE_VIEW";
            public const string Invoice_Allocation_With_Cost_View = "INVOICE_ALLOCATION_WITH_COST_VIEW";
            public const string Recheck_Invoice_View = "RECHECK_INVOICE_VIEW";
            public const string Comments_View = "COMMENTS_VIEW";
            public const string Activities___Events_View = "ACTIVITIES_/_EVENTS_VIEW";
            public const string Document_Thumnail_View = "DOCUMENT_THUMNAIL_VIEW";
            public const string Documents_View = "DOCUMENTS_VIEW";
            public const string Barcode_Scan_History_View = "BARCODE_SCAN_HISTORY_VIEW";
            public const string Manifest_View = "MANIFEST_VIEW";
            public const string POP_And_POD_Thumnail_View = "POP_POD_THUMNAIL_VIEW";
            public const string POP_And_POD_View = "POP_POD_VIEW";
            public const string Change_Log_View = "CHANGE_LOG_VIEW";
            public const string Over_Shortage_And_Damage = "OVER_SHORTAGE_DAMAGE";
            #endregion OrderDetail;      
            #region SellerAllocationSetup;     
            public const string Seller_Allocation_List_View = "SELLER_ALLOCATION_LIST_VIEW";
            public const string Seller_Allocation_List_Tab_View = "SELLER_ALLOCATION_LIST_TAB_VIEW";
            public const string Seller_Allocation_Mapping_Tab_View = "SELLER_ALLOCATION_MAPPING_TAB_VIEW";
            public const string User_Seller_Allocation_Mapping_Tab_View = "USER_SELLER_ALLOCATION_MAPPING_TAB_VIEW";
            public const string Seller_Allocation_List_Edit = "SELLER_ALLOCATION_LIST_EDIT";
            public const string Seller_Allocation_List_Add = "SELLER_ALLOCATION_LIST_ADD";
            public const string Seller_Allocation_List_Delete = "SELLER_ALLOCATION_LIST_DELETE";
            public const string Seller_Allocation_Mapping_Edit = "SELLER_ALLOCATION_MAPPING_EDIT";
            public const string Seller_Allocation_Mapping_Add = "SELLER_ALLOCATION_MAPPING_ADD";
            public const string Seller_Allocation_Mapping_Delete = "SELLER_ALLOCATION_MAPPING_DELETE";
            public const string User_Seller_Allocation_Mapping_Edit = "USER_SELLER_ALLOCATION_MAPPING_EDIT";
            public const string User_Seller_Allocation_Mapping_Add = "USER_SELLER_ALLOCATION_MAPPING_ADD";
            public const string User_Seller_Allocation_Mapping_Delete = "USER_SELLER_ALLOCATION_MAPPING_DELETE";
            public const string Account_Manager_List_View = "SAL_ACCOUNT_MANAGER_LIST_VIEW";
            public const string Account_Manager_List_Add = "SAL_ACCOUNT_MANAGER_LIST_ADD";
            public const string Account_Manager_List_Edit = "SAL_ACCOUNT_MANAGER_LIST_EDIT";
            public const string Account_Manager_List_Delete = "SAL_ACCOUNT_MANAGER_LIST_DELETE";
            public const string Account_Manager_CSR_Mapping_List_View = "SAL_ACCT_MANGR_CSR_MAPPING_VIEW";
            public const string Account_Manager_CSR_Mapping_List_Add = "SAL_ACCT_MANGR_CSR_MAPPING_ADD";
            public const string Account_Manager_CSR_Mapping_List_Edit = "SAL_ACCT_MANGR_CSR_MAPPING_EDIT";
            public const string Account_Manager_CSR_Mapping_List_Delete = "SAL_ACCT_MANGR_CSR_MAPPING_DELETE";
            #endregion SellerAllocationSetup;    
            #region UserSetup;     
            public const string User_Setup_View = "USER_SETUP_VIEW";
            public const string User_Setup_Add = "USER_SETUP_ADD";
            public const string User_Setup_Edit = "USER_SETUP_EDIT";
            public const string User_Setup_Delete = "USER_SETUP_DELETE";
            #endregion UserSetup;
            #region PageChart;     
            public const string Page_Chart_View = "PAGE_CHART_VIEW";
            #endregion ;
            #region RightsSetup;     
            public const string Right_Setup_View = "RIGHT_SETUP_VIEW";
            public const string Right_Setup_Add = "RIGHT_SETUP_ADD";
            public const string Right_Setup_Edit = "RIGHT_SETUP_EDIT";
            public const string Right_Setup_Delete = "RIGHT_SETUP_DELETE";
            #endregion RightsSetup;
            #region DepartmentSetup;     
            public const string Department_Setup_View = "DEPARTMENT_SETUP_VIEW";
            public const string Department_Setup_Add = "DEPARTMENT_SETUP_ADD";
            public const string Department_Setup_Edit = "DEPARTMENT_SETUP_EDIT";
            public const string Department_Setup_Delete = "DEPARTMENT_SETUP_DELETE";
            #endregion DepartmentSetup;
            #region AuditHistory;     
            public const string Audit_History_View = "AUDIT_HISTORY_VIEW";
            #endregion ;
            #region EventSetup;     
            public const string Event_Setup_View = "EVENT_SETUP_VIEW";
            public const string Event_Setup_Add = "EVENT_SETUP_ADD";
            public const string Event_Setup_Edit = "EVENT_SETUP_EDIT";
            public const string Event_Setup_Delete = "EVENT_SETUP_DELETE";
            #endregion EventSetup;
            #region HubSetup;     
            public const string Hub_Setup_View = "HUB_SETUP_VIEW";
            public const string Hub_Setup_Add = "HUB_SETUP_ADD";
            public const string Hub_Setup_Edit = "HUB_SETUP_EDIT";
            public const string Hub_Setup_Delete = "HUB_SETUP_DELETE";
            public const string Address_List_View = "ADDRESS_LIST_VIEW";
            public const string Address_List_Add = "ADDRESS_LIST_ADD";
            public const string Address_List_Edit = "ADDRESS_LIST_EDIT";
            public const string Address_List_Delete = "ADDRESS_LIST_DELETE";
            public const string Address_List_Approval = "ADDRESS_LIST_APPROVAL";
            public const string Airport_List_View = "AIRPORT_LIST_VIEW";
            public const string Airport_List_Add = "AIRPORT_LIST_ADD";
            public const string Airport_List_Edit = "AIRPORT_LIST_EDIT";
            public const string Airport_List_Delete = "AIRPORT_LIST_DELETE";
            public const string Time_Zone_List_View = " TIMEZONELIST_VIEW";

            #endregion HubSetup;
            #region UserSellerSetup;     
            public const string User_Seller_Setup_View = "USER_SELLER_SETUP_VIEW";
            public const string User_Seller_Setup_Add = "USER_SELLER_SETUP_ADD";
            public const string User_Seller_Setup_Edit = "USER_SELLER_SETUP_EDIT";
            public const string User_Seller_Setup_Delete = "USER_SELLER_SETUP_DELETE";
            #endregion UserSellerSetup;
            #region SellerSetup;     
            public const string Seller_Setup_View = "SELLER_SETUP_VIEW";
            public const string Seller_Setup_Add = "SELLER_SETUP_ADD";
            public const string Seller_Setup_Edit = "SELLER_SETUP_EDIT";
            public const string Seller_Setup_Delete = "SELLER_SETUP_DELETE";
            #endregion SellerSetup;
            #region DefaultSetup;     
            public const string Default_Setup_View = "DEFAULT_SETUP_VIEW";
            public const string Default_Setup_Add = "DEFAULT_SETUP_ADD";
            public const string Default_Setup_Edit = "DEFAULT_SETUP_EDIT";
            public const string Default_Setup_Delete = "DEFAULT_SETUP_DELETE";
            #endregion DefaultSetup;
            #region ServiceSetup;     
            public const string Service_Setup_View = "SERVICE_SETUP_VIEW";
            public const string Service_Setup_Add = "SERVICE_SETUP_ADD";
            public const string Service_Setup_Edit = "SERVICE_SETUP_EDIT";
            public const string Service_Setup_Delete = "SERVICE_SETUP_DELETE";
            #endregion ServiceSetup;
            #region ApplicationSetup;     
            public const string Application_Setup_View = "APPLICATION_SETUP_VIEW";
            public const string Application_Setup_Add = "APPLICATION_SETUP_ADD";
            public const string Application_Setup_Edit = "APPLICATION_SETUP_EDIT";
            public const string Application_Setup_Delete = "APPLICATION_SETUP_DELETE";
            #endregion ApplicationSetup;
            #region TaskManagementSetup;     
            public const string Task_Management_View = "TASK_MANAGEMENT_VIEW";
            public const string Task_Management_Add = "TASK_MANAGEMENT_ADD";
            public const string Task_Management_Edit = "TASK_MANAGEMENT_EDIT";
            public const string Task_Management_Delete = "TASK_MANAGEMENT_DELETE";
            #endregion TaskManagementSetup;
            #region LogiwaClients;     
            public const string Inventory_Logiwa_Clients_View = "LOGIWA_CLIENTS_VIEW";
            public const string Inventory_Logiwa_Clients_Add = "LOGIWA_CLIENTS_ADD";
            public const string Inventory_Logiwa_Clients_Edit = "LOGIWA_CLIENTS_EDIT";
            public const string Inventory_Logiwa_Clients_Delete = "LOGIWA_CLIENTS_DELETE";
            #endregion LogiwaClients;
        }
    }
    public struct CacheType
    {
        public const string TConfig = "TConfig";
        public const string TAPIUserMapRequestLimit = "TAPIUserMapRequestLimit";
        public const string TUsers = "TUsers";
    }
    public struct CacheSubType
    {       
        public const string P_Get_Role_Rights_From_RoleID = "P_Get_Role_Rights_From_RoleID";
        public const string P_Get_Role_Rights_From_Username = "P_Get_Role_Rights_From_Username";
        public const string P_Is_Has_Right_From_RoleID = "P_Is_Has_Right_From_RoleID";
        public const string P_Is_Has_Right_From_Username = "P_Is_Has_Right_From_Username";
        public const string P_GetDBServerForDataRead_2 = "P_GetDBServerForDataRead_2";
        public const string P_Get_User_Info = "P_Get_User_Info";
    }
    public class ErrorList
    {
        public struct ErrorListInvalidCustomer
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INCUS";
            public const string ErrorMsg = "Invalid Customer";
            public const string DetailErrorMsg = "Invalid Customer";
        }
        public struct ErrorListCustomerBlocked
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CUSBLK";
            public const string ErrorMsg = "Customer is Blocked";
            public const string DetailErrorMsg = "Customer is Blocked";
        }
        public struct ErrorListInvalidBillingType
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INBT";
            public const string ErrorMsg = "Invalid Billing Type";
            public const string DetailErrorMsg = "Invalid Billing Type";
        }
        public struct ErrorListInvalidSellerKey
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INCUSKEY";
            public const string ErrorMsg = "Invalid Customer Key";
            public const string DetailErrorMsg = "Invalid Customer Key";
        }
        public struct ErrorListInternalServerError
        {
            public const int StatusCode = 500;
            public const string ErrorCode = "INTSRVERR";
            public const string ErrorMsg = "Internal Server Error";
            public const string DetailErrorMsg = "Internal Server Error";
        }
        public struct ErrorListSystemDown
        {
            public const int StatusCode = 503;
            public const string ErrorCode = "SYTDOWN";
            public const string ErrorMsg = "System is Down for Maintenance";
            public const string DetailErrorMsg = "System is Down for Maintenance";
        }
        public struct ErrorListUnableToGenerateQuoteID
        {
            public const int StatusCode = 500;
            public const string ErrorCode = "UNBGENQTID";
            public const string ErrorMsg = "Unable to Generate QuoteID";
            public const string DetailErrorMsg = "Unable to Generate QuoteID";
        }
        public struct ErrorListInvalidJson
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INJSON";
            public const string ErrorMsg = "Invalid JSON";
            public const string DetailErrorMsg = "Invalid JSON";
        }
        public struct ErrorListArryLimit
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "ARRYLMT";
            public const string ErrorMsg = "Json Array is Reached";
            public const string DetailErrorMsg = "Json Array is Reached";
        }
        public struct ErrorListLimitReached
        {
            public const int StatusCode = 429;
            public const string ErrorCode = "LMTRH";
            public const string ErrorMsg = "Limit Reached";
            public const string DetailErrorMsg = "Limit Reached";
        }
        public struct ErrorListLimitNotSetup
        {
            public const int StatusCode = 429;
            public const string ErrorCode = "LMTNST";
            public const string ErrorMsg = "Limit is Not Setup";
            public const string DetailErrorMsg = "Limit is Not Setup, Please Contact Metro to Setup Throttling";
        }
        public struct ErrorListInvalidAuth
        {
            public const int StatusCode = 401;
            public const string ErrorCode = "INAUTH";
            public const string ErrorMsg = "Invalid Authentication";
            public const string DetailErrorMsg = "Invalid Authentication";
        }
        public struct ErrorListNoRight
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "NORIGHT";
            public const string ErrorMsg = "No Right";
            public const string DetailErrorMsg = "No Right";
        }
        public struct ErrorListBlock
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "BLOCK";
            public const string ErrorMsg = "Blocked";
            public const string DetailErrorMsg = "Blocked";
        }
        public struct ErrorListNotWhiteList
        {
            public const int StatusCode = 429;
            public const string ErrorCode = "NWHTLT";
            public const string ErrorMsg = "Not White Listed";
            public const string DetailErrorMsg = "Not White Listed";
        }
        public struct ErrorListInvalidToken
        {
            public const int StatusCode = 401;
            public const string ErrorCode = "INTOKN";
            public const string ErrorMsg = "Invalid Token";
            public const string DetailErrorMsg = "Invalid Token";
        }
        public struct ErrorListInvalidRefreshToken
        {
            public const int StatusCode = 401;
            public const string ErrorCode = "INRFTOKN";
            public const string ErrorMsg = "Invalid Refresh Token";
            public const string DetailErrorMsg = "Invalid Refresh Token";
        }
        public struct ErrorListTokenRequired
        {
            public const int StatusCode = 401;
            public const string ErrorCode = "TOKNREQD";
            public const string ErrorMsg = "Token Required";
            public const string DetailErrorMsg = "Token Required";
        }
        public struct ErrorListTooManyRequest
        {
            public const int StatusCode = 429;
            public const string ErrorCode = "TOMNYREQ";
            public const string ErrorMsg = "Too Many Requests";
            public const string DetailErrorMsg = "Too Many Requests";
        }
        public struct ErrorListInvalidAPIKey
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INKEY";
            public const string ErrorMsg = "Invalid API Key";
            public const string DetailErrorMsg = "Invalid API Key";
        }
        public struct ErrorListInvalidUser
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INUSER";
            public const string ErrorMsg = "Invalid User";
            public const string DetailErrorMsg = "Invalid User";
        }
        public struct ErrorListInvalidReq
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "INREQ";
            public const string ErrorMsg = "Invalid Request";
            public const string DetailErrorMsg = "Invalid Request";
        }
        public struct ErrorListDuringExecution
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "EXECERR";
            public const string ErrorMsg = "Error During Execution";
            public const string DetailErrorMsg = "Error During Execution";
        }
        public struct ErrorListCHR50
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL50";
            public const string ErrorMsg = "Exceed 50 Characters";
            public const string DetailErrorMsg = "Exceed 50 Characters";
        }
        public struct ErrorListCHR75
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL75";
            public const string ErrorMsg = "Exceed 75 Characters";
            public const string DetailErrorMsg = "Exceed 75 Characters";
        }
        public struct ErrorListCHR150
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL150";
            public const string ErrorMsg = "Exceed 150 Characters";
            public const string DetailErrorMsg = "Exceed 150 Characters";
        }
        public struct ErrorListCHR250
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL250";
            public const string ErrorMsg = "Exceed 250 Characters";
            public const string DetailErrorMsg = "Exceed 250 Characters";
        }
        public struct ErrorListCHR500
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL500";
            public const string ErrorMsg = "Exceed 500 Characters";
            public const string DetailErrorMsg = "Exceed 500 Characters";
        }
        public struct ErrorListCHR1000
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL1000";
            public const string ErrorMsg = "Exceed 1000 Characters";
            public const string DetailErrorMsg = "Exceed 1000 Characters";
        }
        public struct ErrorListDuplicateRequest
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "DUPREQ";
            public const string ErrorMsg = "Duplicate Request";
            public const string DetailErrorMsg = "Duplicate Request";
        }
        public struct ErrorListAPINotActive
        {
            public const int StatusCode = 500;
            public const string ErrorCode = "INAPI";
            public const string ErrorMsg = "API is Not Active";
            public const string DetailErrorMsg = "API is Not Active";
        }
        public struct ErrorListCHR5
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL5";
            public const string ErrorMsg = "Exceed 5 Characters";
            public const string DetailErrorMsg = "Exceed 5 Characters";
        }
        public struct ErrorListCHR10
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL10";
            public const string ErrorMsg = "Exceed 10 Characters";
            public const string DetailErrorMsg = "Exceed 10 Characters";
        }
        public struct ErrorListCHR30
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL30";
            public const string ErrorMsg = "Exceed 30 Characters";
            public const string DetailErrorMsg = "Exceed 30 Characters";
        }
        public struct ErrorListCHR20
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "CHRL20";
            public const string ErrorMsg = "Exceed 20 Characters";
            public const string DetailErrorMsg = "Exceed 20 Characters";
        }
        public struct ErrorListNoRecord
        {
            public const int StatusCode = 400;
            public const string ErrorCode = "NOREC";
            public const string ErrorMsg = "No Record Found";
            public const string DetailErrorMsg = "No Record Found";
        }
    }    
}

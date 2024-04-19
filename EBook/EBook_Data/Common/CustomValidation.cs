using System.ComponentModel.DataAnnotations;
using EBook_Data.DataAccess;
using EBook_Models.App_Models;
using Microsoft.VisualBasic;
using static EBook_Models.App_Models.AppEnum;

namespace EBook_Data.Common
{
    public class CustomValidationAttribute2 : ValidationAttribute
    {
        private readonly string _propertyname;
        private readonly int _minlength;
        private readonly int _maxlength;
        private readonly bool _allowemptystring;
        private readonly string _param1;
        private readonly string _param2;
        private readonly string _param3;
        private readonly string _param4;
        private readonly string _param5;
        private readonly string _minlenerrormessage;
        private readonly string _maxlenerrormessage;
        private readonly string _allowemptystringerrormessage;
        private readonly string _othererrormessage;
        private readonly int _vtype;
        private readonly bool _ignorenull;
        private readonly bool _isshowbasetype;
        private readonly bool _ischeckbasetype;
        private readonly bool _rangeapplicable;
        private readonly double _rangestart;
        private readonly double _rangeend;
        private readonly string _rangeerrormessage;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyname"></param>
        /// <param name="minlength">-1 Means Do Not Check This Condition</param>
        /// <param name="maxlength">-1 Means Do Not Check This Condition</param>
        /// <param name="allowemptystring"></param>
        /// <param name="param1"></param>
        /// <param name="param2"></param>
        /// <param name="param3"></param>
        /// <param name="param4"></param>
        /// <param name="param5"></param>
        /// <param name="minlenerrormessage"></param>
        /// <param name="maxlenerrormessage"></param>
        /// <param name="allowemptystringerrormessage">For IngnoreNull and AllowEmptyString</param>
        /// <param name="othererrormessage"></param>
        /// <param name="vtype"></param>
        /// <param name="ignorenull"></param>
        /// /// <param name="isshowbasetype">{BaseTypeName} use in ErrorMessage</param>
        /// /// <param name="ischeckbasetype"></param>
        public CustomValidationAttribute2(string propertyname = "", int minlength = -1, int maxlength = -1, bool allowemptystring = true
            , string param1 = "", string param2 = "", string param3 = "", string param4 = "", string param5 = ""
            , string minlenerrormessage = "Invalid Value"
            , string maxlenerrormessage = "Invalid Value"
            , string allowemptystringerrormessage = "Invalid Value"
            , string othererrormessage = "Invalid Value"
            , CustomValidationType vtype = CustomValidationType.Custom, bool ignorenull = true
            , bool isshowbasetype = false, bool ischeckbasetype = false, bool rangeapplicable = false
            , double rangestart = double.MinValue, double rangeend = double.MaxValue, string rangeerrormessage = "Invalid Value")
        {
            _minlenerrormessage = minlenerrormessage;
            _maxlenerrormessage = maxlenerrormessage;
            _allowemptystringerrormessage = allowemptystringerrormessage;
            _othererrormessage = othererrormessage;
            _allowemptystring = allowemptystring;
            _propertyname = propertyname;
            _minlength = minlength;
            _maxlength = maxlength;
            _param1 = param1;
            _param2 = param2;
            _param3 = param3;
            _param4 = param4;
            _param5 = param5;
            _vtype = (int)vtype;
            _ignorenull = ignorenull;
            _isshowbasetype = isshowbasetype;
            _ischeckbasetype = ischeckbasetype;
            _rangeapplicable = rangeapplicable;
            _rangestart = rangestart;
            _rangeend = rangeend;
            _rangeerrormessage = rangeerrormessage;
        }
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            string BaseTypeName = "";
            string ShowBaseTypeName = "";
            try
            {
                if (_ischeckbasetype == true || _isshowbasetype == true)
                {
                    BaseTypeName = validationContext.ObjectType.Name.ToLower();
                    if (BaseTypeName != "")
                    {
                        if (BaseTypeName == "BillToAddressField".ToLower())
                            BaseTypeName = "billtoinformation";
                        else if (BaseTypeName == "ShipFromAddressField".ToLower())
                            BaseTypeName = "shipfrominformation";
                        else if (BaseTypeName == "ShipToAddressField".ToLower())
                            BaseTypeName = "shiptoinformation";
                        else if (BaseTypeName == "RequestClientIdentifier".ToLower())
                            BaseTypeName = "clientidentifiers";
                        else if (BaseTypeName == "PickupInfo".ToLower())
                            BaseTypeName = "pickupotherinfo";
                        else if (BaseTypeName == "RequestPickupSpecialServices".ToLower())
                            BaseTypeName = "pickupspecialservices";
                        else if (BaseTypeName == "DeliveryInfo".ToLower())
                            BaseTypeName = "deliveryotherinfo";
                        else if (BaseTypeName == "RequestDeliverySpecialServices".ToLower())
                            BaseTypeName = "deliveryspecialservices";
                        else if (BaseTypeName == "RequestOrderItems".ToLower())
                            BaseTypeName = "itemsdetails";
                        else if (BaseTypeName == "RequestDocs".ToLower())
                            BaseTypeName = "orderdocs";
                        else if (BaseTypeName == "BarcodeList2".ToLower())
                            BaseTypeName = "barcodes";
                        else if (BaseTypeName == "RequestItemDocs".ToLower())
                            BaseTypeName = "itemimages";
                        else if (BaseTypeName == "BarcodeList".ToLower())
                            BaseTypeName = "barcodes";
                        else if (BaseTypeName == "ResponseDetail".ToLower())
                            BaseTypeName = "response";
                        else if (BaseTypeName == "RequestOrder2".ToLower())
                            BaseTypeName = "request";
                        else if (BaseTypeName == "PickupResInfo".ToLower())
                            BaseTypeName = "pickupinfo";
                        else if (BaseTypeName == "DeliveryResInfo".ToLower())
                            BaseTypeName = "deliveryinfo";
                        else if (BaseTypeName == "ZipCodeInfo".ToLower())
                            BaseTypeName = "zipcodes";
                        else if (BaseTypeName == "RequestClientIdentifier".ToLower())
                            BaseTypeName = "clientidentifiers";
                        else if (BaseTypeName == "RequestPickupSpecialServices".ToLower())
                            BaseTypeName = "pickupspecialservices";
                        else if (BaseTypeName == "RequestDeliverySpecialServices".ToLower())
                            BaseTypeName = "deliveryspecialservices";

                        if (_isshowbasetype == true)
                            ShowBaseTypeName = $"{BaseTypeName}.";
                    }
                }
            }
            catch (Exception ex)
            {
                StaticPublicObjects.logFile.ErrorLog(FunctionName: "IsValid", SmallMessage: ex.Message, Message: ex.ToString());
            }
            if (_ignorenull == false && value == null)
            {
                return new ValidationResult(_allowemptystringerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
            }
            if (value != null)
            {
                if (_allowemptystring == false && value.ToString() == "")
                {
                    return new ValidationResult(_allowemptystringerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                }
            }
            if (_minlength > -1 && value != null)
            {
                if (value.ToString().Length < _minlength && _allowemptystring == false && value.ToString().Length == 0)
                    return new ValidationResult(_minlenerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                else if (value.ToString().Length < _minlength && value.ToString().Length != 0)
                    return new ValidationResult(_minlenerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
            }
            if (_maxlength > -1 && value != null)
            {
                if (value.ToString().Length > _maxlength)
                    return new ValidationResult(_maxlenerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
            }
            if (_rangeapplicable)
            {
                if (value != null)
                {
                    if (Convert.ToDouble(value) < _rangestart || Convert.ToDouble(value) > _rangeend)
                        return new ValidationResult(_rangeerrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                }
            }
            if (_vtype == (int)CustomValidationType.Date && value != null)
            {
                if (Information.IsDate(value) == false)
                    return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
            }
            if (_vtype == (int)CustomValidationType.DateIgnoreEmpty && value != null)
            {
                if (value.ToString() != "")
                {
                    if (Information.IsDate(value) == false)
                        return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                }
            }
            if (_vtype == (int)CustomValidationType.Numeric && value != null)
            {
                if (Information.IsNumeric(value.ToString()) == false)
                    return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
            }
            if (_vtype == (int)CustomValidationType.NumericIgnoreEmpty && value != null)
            {
                if (value.ToString() != "")
                {
                    if (Information.IsNumeric(value.ToString()) == false)
                        return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                }
            }
            if (_vtype == (int)CustomValidationType.Custom)
            {
                if (_propertyname.ToLower() == "phoneext")
                {
                    if (value != null)
                    {
                        if (value.ToString() != "")
                        {
                            if (Information.IsNumeric(value.ToString()) == false)
                                return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                        }
                    }

                    var phonenumber = validationContext.ObjectInstance.GetType().GetProperty(_param1)?.GetValue(validationContext.ObjectInstance);
                    phonenumber = (phonenumber == null ? "" : phonenumber);
                    value = (value == null ? "" : value);
                    if (Information.IsNumeric(value) == false && value != "")
                        return new ValidationResult("*{BaseTypeName}phoneext* invalid value. Only numeric values are required".Replace("{BaseTypeName}", ShowBaseTypeName));
                    if (value.ToString().Length > 0 && phonenumber.ToString().Length == 0)
                        return new ValidationResult("*{BaseTypeName}phoneext* should be null or empty if *phone* was not provided".Replace("{BaseTypeName}", ShowBaseTypeName));
                }
                else if (_propertyname.ToLower() == "parentitemid")
                {
                    if (value != null)
                    {
                        if (value.ToString() != "")
                        {
                            if (Information.IsNumeric(value.ToString()) == false)
                                return new ValidationResult(_othererrormessage.Replace("{BaseTypeName}", ShowBaseTypeName));
                        }

                        if ((int)value < 0)
                            return new ValidationResult("*parentitemid* invalid value");
                        var quantity = validationContext.ObjectInstance.GetType().GetProperty(_param1)?.GetValue(validationContext.ObjectInstance);

                        if ((int)quantity > 1)
                            return new ValidationResult("*parentitemid* cannot be mapped with more than 1. Please Provide all items quantity separately or *parentitemid* should be null");
                    }
                }
                else if (_propertyname.ToLower() == "reqclientidentifier.value")
                {
                    if (value != null)
                    {
                        if (value.ToString().Length > 50)
                        {
                            var codename = validationContext.ObjectInstance.GetType().GetProperty(_param1)?.GetValue(validationContext.ObjectInstance);
                            codename = (codename == null ? "" : codename);
                            return new ValidationResult((codename == "" ? "" : codename + " ") + _othererrormessage);
                        }
                    }
                }
                else if (_propertyname.ToLower() == "CheckIsUpdateRecord".ToLower())
                {
                    var IsUpdateRecord = validationContext.ObjectInstance.GetType().GetProperty("GetIsUpdateRecord")?.GetValue(validationContext.ObjectInstance);
                    IsUpdateRecord = IsUpdateRecord ?? false;
                    if ((bool)IsUpdateRecord)
                    {
                        var field1value = validationContext.ObjectInstance.GetType().GetProperty(_param1)?.GetValue(validationContext.ObjectInstance);
                        if (string.IsNullOrEmpty(field1value?.ToString()))
                        {
                            return new ValidationResult($"*{_param1}* is required");
                        }
                        else if (string.IsNullOrEmpty(field1value?.ToString()) == false)
                        {
                            var field2value = validationContext.ObjectInstance.GetType().GetProperty(_param2)?.GetValue(validationContext.ObjectInstance);
                            bool IsNullableValue = (field2value == null ? true : false);
                            field2value = field2value ?? 0;
                            if (IsNullableValue && _ignorenull == false)
                            {
                                return new ValidationResult($"*{_param1}* invalid value");
                            }
                            else if ((int)field2value == 0)
                            {
                                return new ValidationResult($"*{_param1}* invalid value");
                            }
                        }
                    }
                }
                else if (_propertyname.ToLower() == "CheckIsUpdateRecordOptional".ToLower())
                {
                    var IsUpdateRecord = validationContext.ObjectInstance.GetType().GetProperty("GetIsUpdateRecord")?.GetValue(validationContext.ObjectInstance);
                    IsUpdateRecord = IsUpdateRecord ?? false;
                    if ((bool)IsUpdateRecord)
                    {
                        var field1value = validationContext.ObjectInstance.GetType().GetProperty(_param1)?.GetValue(validationContext.ObjectInstance);
                        if (string.IsNullOrEmpty(field1value?.ToString()) == false)
                        {
                            var field2value = validationContext.ObjectInstance.GetType().GetProperty(_param2)?.GetValue(validationContext.ObjectInstance);
                            bool IsNullableValue = (field2value == null ? true : false);
                            field2value = field2value ?? 0;
                            if (IsNullableValue && _ignorenull == false)
                            {
                                return new ValidationResult($"*{_param1}* invalid value");
                            }
                            else if ((int)field2value == 0)
                            {
                                return new ValidationResult($"*{_param1}* invalid value");
                            }
                        }
                    }
                }
            }

            return ValidationResult.Success;
        }
    }

}

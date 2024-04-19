var json = {
    pageIndex: 0,
    pageSize: 0,
    sortExpression: "",
    reportFilterObjectList: [
        {
            code: "",
            name: "",
            isFilterApplied: false,
            reportFilterObjectArry: []
        }
    ],
    ReportColumnObjectList: [
        {
            Code: "",
            Name: "",
            IsColumnRequired: true,
        }
    ]
};

var filterobject = {
    logic: "",
    value: "",
    type: "",
    isList: false,
    listType: 0
};

Date.prototype.MMddyyyy = function () {
    var mm = this.getMonth() + 1; // getMonth() is zero-based
    var dd = this.getDate();

    return [(mm > 9 ? '' : '0') + mm,
    (dd > 9 ? '' : '0') + dd,
    this.getFullYear()
    ].join('/');
}

function formatDateToDateTime(getinputDate, isString) {
    isString = (isString == undefined ? true : false);
    var inputDate;

    if (isString) {
        // Create a Date object from the input date string
        inputDate = new Date(getinputDate);
    }
    else {
        inputDate = getinputDate;
    }

    // Check if the inputDate is valid
    if (isNaN(inputDate.getTime())) {
        //return "Invalid Date";
        return '';
    }

    // Format the date as "MM/dd/yyyy HH:mm:ss.fff"
    var formattedDate = `${(inputDate.getMonth() + 1).toString().padStart(2, '0')}/` +
        `${inputDate.getDate().toString().padStart(2, '0')}/` +
        `${inputDate.getFullYear()} ` +
        `${inputDate.getHours().toString().padStart(2, '0')}:` +
        `${inputDate.getMinutes().toString().padStart(2, '0')}:` +
        `${inputDate.getSeconds().toString().padStart(2, '0')}.` +
        `${inputDate.getMilliseconds().toString().padStart(3, '0')}`;

    return formattedDate;
}

function FormatDateTimeWithTimeZone(_datetime, _timezone) {
    _datetime = (_datetime == undefined || _datetime == null ? "" : _datetime);
    if (_datetime == "") {
        return "";
    }
    var formattedDateTime = kendo.toString(_datetime, 'MM/dd/yyyy hh:mm:ss tt');
    var returndatetime = formattedDateTime;
    _timezone = (_timezone == undefined || _timezone == null ? "" : _timezone);
    if (_timezone != "") {
        returndatetime = formattedDateTime + " " + _timezone;
    }
    return returndatetime;
}

function formateKendoDate(inputDate) {
    var formatedDate = new Date(inputDate);
    var year = formatedDate.getFullYear();
    var month = ('0' + (formatedDate.getMonth() + 1)).slice(-2); // Adding 1 to month because it's zero-based
    var day = ('0' + formatedDate.getDate()).slice(-2);
    return year + '-' + month + '-' + day;
}

const KendoGridFilterType = {
    contains: "contains",
    notequal: "neq",
    equal: "eq",
    doesnotcontain: "doesnotcontain",
    startswith: "startswith",
    endswith: "endswith",
    isnull: "isnull",
    isnotnull: "isnotnull",
    orderno: "orderno",
    isempty: "isempty",
    isnotempty: "isnotempty",
    isequalorgreather: "gte",
    greather: "gt",
    isequalorless: "lte",
    less: "lt",
    isnullorempty: "isnullorempty",
    isnotnullorempty: "isnotnullorempty",
    inlistfilter: "inlistfilter",
    notinlistfilter: "notinlistfilter",
};

const SRVTypes = {
    String: "string",
    UpperString: "upstring",
    LowerString: "lwstring",
    Int: "int",
    Float: "float",
    Date: "date",
    Datetime: "datetime",
    Boolean: "boolean"
};

const KendoFilterTypes = {
    CustomListofStrings: "liststring",
    String: "string",
    Number: "number",
    Date: "date",
    Boolean: "boolean"
};

const ExcelColumnTypes = {
    General: "General",
    Date_mmddyyyy: "mm/dd/yyyy",
    Time_hhmmss: "hh:mm:ss",
    DateTime_mmddyyyyhhmmss: "mm/dd/yyyy hh:mm:ss",
    Accounting: "$ #,##0.00;[Red]($ #,##0.00)",
    Text_: "@",
    Number_: "0.00",
    Percentage: "0.00%",
    Scientific: "0.00E+00",
    Currency: "$ #,##0.00",
    Fraction: "# ?/?"
    //Custom: "0.0\" \"m/s";
};

function setFilterValue(gridid, filter) {
    // Get a reference to the Kendo Grid widget
    var grid = $("#" + gridid).data("kendoGrid");

    grid.dataSource.filter(filter);
    return true;
}

function setOptionDataFilter(gridid, obj) {
    // Get a reference to the Kendo Grid widget
    var grid = $("#" + gridid).data("kendoGrid");

    grid.dataSource.filter(obj);
    return true;
}

const KendoOperatorListOfString = {
    liststring: {
        inlistfilter: "In List",
        notinlistfilter: "Not In List"
    }
};

const KendoRowOperatorListOfString = {
    string: {
        inlistfilter: {
            text: "In List",
        },
        notinlistfilter: {
            text: "Not In List",
        },
    },
};

const KendoOperatorListOfStringUI = function (element) {
    $(element).replaceWith("<textarea row='3' style='width: 300px!important;height: 100px !important;' placeholder='enter list or comma separated' data-bind='value:filters[0].value' data-role='textbox'></textarea>");
};

function isDate(value) {
    switch (typeof value) {
        case 'number':
            return true;
        case 'string':
            return !isNaN(Date.parse(value));
        case 'object':
            if (value instanceof Date) {
                return !isNaN(value.getTime());
            }
        default:
            return false;
    }
}

function GetUSFormatNumber(value, roundto, currency) {
    return (currency != "" ? currency + " " : "") + value.toFixed(roundto).toLocaleString('en-US');
}

function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function isEven(value) {
    if (value % 2 == 0) {
        return true;
    }
    else {
        return false;
    }
}

Date.prototype.today = function () {
    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
}

// For the time now
Date.prototype.timeNow = function () {
    return ((this.getHours() < 10) ? "0" : "") + this.getHours() + ":" + ((this.getMinutes() < 10) ? "0" : "") + this.getMinutes() + ":" + ((this.getSeconds() < 10) ? "0" : "") + this.getSeconds();
}

String.prototype.left = function (n) {
    return this.substring(0, n);
}

function onclickDate(e) {
    var key = e.keyCode || e.charCode;
    if (key == 8 || key == 46) {
        return true;
    }
    else {
        return false;
    }
}
function onClickExportExcel(e) {
    var _kendogridid = e.id.replace('_exportExcel', '');
    var grid = $("#" + _kendogridid).data("kendoGrid");

    var _recordsLimit = -1;
    var _custompageoptions = new Object();
    var _pageloaderid = 'PageLoader';
    var _controllername = '';
    var _controllermethodname = '';
    var _iscustomfilterexists = false;
    var _isspecificfilterexists = false;

    if (customoptionslist.length > 0) {
        for (var i = 0; i <= customoptionslist.length - 1; i++) {
            if (customoptionslist[i].id == _kendogridid) {
                _custompageoptions = customoptionslist[i].option;
                break;
            }
        }
    }

    if (grid.dataSource != undefined && grid.dataSource != null) {
        _iscustomfilterexists = grid.dataSource.options.iscustomfilterexists;
        if (_iscustomfilterexists == undefined || _iscustomfilterexists == null) {
            _iscustomfilterexists = false;
        }
        _isspecificfilterexists = grid.dataSource.options.isspecificfilterexists;
        if (_isspecificfilterexists == undefined || _isspecificfilterexists == null) {
            _isspecificfilterexists = false;
        }
    }

    if (grid.options != undefined && grid.options != null) {
        _pageloaderid = grid.options.pageloaderid;
        if (_pageloaderid == undefined || _pageloaderid == null) {
            _pageloaderid = 'PageLoader';
        }
        _controllername = grid.options.controllername;
        if (_controllername == undefined || _controllername == null) {
            _controllername = '';
        }
        _controllermethodname = grid.options.controllermethodname;
        if (_controllermethodname == undefined || _controllermethodname == null) {
            _controllermethodname = '';
        }

        if (grid.options.recordsLimit != undefined || grid.options.recordsLimit != null) {
            if (grid.options.recordsLimit > 0) {
                _recordsLimit = grid.options.recordsLimit;
            }
        }
    }

    var pageSize = grid.dataSource.pageSize();
    var totalRecords = grid.dataSource.total();
    var totalPages = Math.ceil(grid.dataSource.total() / grid.dataSource.pageSize());

    if (_controllername == '' || _controllermethodname == '') {
        alert('Export To Excel Not Setup');
        return;
    }

    if (totalRecords > _recordsLimit && _recordsLimit > 0) {
        alert('Record Limit is ' + _recordsLimit.toLocaleString('en-US') + ', so cannot export ' + totalRecords.toLocaleString('en-US') + ' records.');
        return;
    }

    var confirmationvalue = undefined;
    if (totalRecords <= pageSize) {
        confirmationvalue = true;
    }

    onClickKendoExportExcel(e, _kendogridid, _custompageoptions, _pageloaderid, _controllername, _controllermethodname, _iscustomfilterexists, _isspecificfilterexists, confirmationvalue);
}
function onClickKendoExportExcel(e, id, options, overlayid, controller, method, isCustomFilterExists, isSpecificFilterExists, confirmationvalue) {
    var IsAllPages = true;
    if (confirmationvalue != true && confirmationvalue != false) {
        waitForConfirmation('Page Export Confirmation', "Please Select You You want Export Current Page or All Pages Data.", 'Current Page', 'All Pages', true,
            function () {
                onClickKendoExportExcel(e, id, options, overlayid, controller, method, isCustomFilterExists, isSpecificFilterExists, true);
            },
            function () {
                onClickKendoExportExcel(e, id, options, overlayid, controller, method, isCustomFilterExists, isSpecificFilterExists, false);
            }
        );
        return;
    }

    IsAllPages = confirmationvalue;

    $("#" + overlayid).show();
    var form = document.createElement("form");
    document.body.appendChild(form);
    form.target = "_blank";
    form.method = "POST";
    form.action = "/" + controller + "/" + method;
    var obj = new Object();
    var GridColumnsItems = [];
    var GridColumnsItem = new Object();

    //IsAllPages = confirm('Do You want to Get All Pages. If Yes Click on *OK* button else Click on *Cancel* button');

    var grid = $("#" + id).data("kendoGrid");
    var dataColumns = grid.columns;
    var columntitle = "";

    if (dataColumns != null && dataColumns != undefined) {
        if (dataColumns.length > 0) {
            for (var i = 0; i <= dataColumns.length - 1; i++) {
                if (dataColumns[i].field != undefined && dataColumns[i].field != null) {
                    GridColumnsItem = new Object();
                    GridColumnsItem.position = i + 1;
                    GridColumnsItem.field = ((dataColumns[i].originalfield == undefined || dataColumns[i].originalfield == null) ? dataColumns[i].field : (dataColumns[i].originalfield == '' ? dataColumns[i].field : dataColumns[i].originalfield));
                    GridColumnsItem.showinexcel = (!(dataColumns[i].showinexcel == undefined || dataColumns[i].showinexcel == null) ? dataColumns[i].showinexcel : (!(dataColumns[i].hidden == undefined || dataColumns[i].hidden == null) ? !dataColumns[i].hidden : (!(dataColumns[i].visible == undefined || dataColumns[i].visible == null) ? !dataColumns[i].visible : true)));
                    columntitle = (!(dataColumns[i].titlename == undefined || dataColumns[i].titlename == null) ? dataColumns[i].titlename : dataColumns[i].title);
                    GridColumnsItem.title = (!(columntitle == undefined || columntitle == null) ? columntitle : GridColumnsItem.field);
                    GridColumnsItem.excelcolumntype = (!(dataColumns[i].excelcolumntype == undefined || dataColumns[i].excelcolumntype == null) ? dataColumns[i].excelcolumntype : ExcelColumnTypes.General);
                    GridColumnsItems.push(GridColumnsItem);
                }
            }
        }
    }

    var fieldstype;
    if (grid.dataSource != undefined && fieldstype == undefined) {
        if (grid.dataSource.reader != undefined) {
            if (grid.dataSource.reader.model != undefined) {
                if (grid.dataSource.reader.model.fields != undefined) {
                    fieldstype = grid.dataSource.reader.model.fields;
                }
            }
        }
    }

    obj.reportParams = GetData(id, options, isCustomFilterExists, isSpecificFilterExists, fieldstype);
    obj.gridColumns = JSON.stringify(GridColumnsItems);
    obj.IsAllPages = IsAllPages;
    var dataObj = obj;
    for (var name in dataObj) {
        $('<input>').attr({
            type: 'hidden',
            value: dataObj[name],
            name: name
        }).appendTo(form);
    }
    form.submit();
    $("#" + overlayid).hide();
}

function onclickDate(e) {
    var key = e.keyCode || e.charCode;
    if (key == 8 || key == 46) {
        return true;
    }
    else {
        return false;
    }
}

function GetData(id, option, isCustomFilterExists, isSpecificFilterExists, _fieldstype) {
    var orderByDirection = "";
    var orderBy = "";
    isCustomFilterExists = (isCustomFilterExists == undefined ? false : isCustomFilterExists);
    isSpecificFilterExists = (isSpecificFilterExists == undefined ? false : isSpecificFilterExists);
    var customreportFilterObjectList = [];
    var resultjson = { issuccess: false, customfilterjson: customreportFilterObjectList };

    var specificreportFilterObjectList = [];
    var specificreportFilterObject = { code: "", name: "", isFilterApplied: false, reportFilterObjectArry: [] };
    var specificfilterobject = new Object();

    if (isCustomFilterExists) {
        resultjson = onCustomFilter(true, id);
        //if (resultjson.issuccess == false) {
        //    return;
        //}
    }

    var json = {
        pageIndex: 0,
        pageSize: 0,
        sortExpression: "",
        reportFilterObjectList: [],
        ReportColumnObjectList: []
    };
    var ReportColumnObjectList = [];
    var reportFilterObject = { code: "", name: "", isFilterApplied: false, reportFilterObjectArry: [] };
    var filterobject = new Object();

    try {
        GetColumnRequiredJson(id, function (data) {
            ReportColumnObjectList = data;
        });
        //ReportColumnObjectList = GetColumnRequiredJson(id);
    }
    catch (error) {
        ReportColumnObjectList = [];
    }
    if (typeof option.data.filter !== "undefined" && option.data.filter !== null) {
        var code = "";
        var reportFilterObjectListCount = -1;
        reportFilterObject = { code: "", name: "", isFilterApplied: false, reportFilterObjectArry: [] };
        for (var i = 0; i < option.data.filter.filters.length; i++) {
            var islogic1 = false;
            if (option.data.filter.filters[i].filters === undefined) {
                islogic1 = true;
            }
            else if (option.data.filter.filters[i].filters[0].field === undefined) {
                islogic1 = true;
            }

            var filterobject = new Object();
            //filterobject = { logic: "", value: "", type: "", isList: false, listType: 0 };
            if (islogic1 == true) {
                filterobject.logic = option.data.filter.logic;
                if (_fieldstype[option.data.filter.filters[i].field].srtype == SRVTypes.Date) {
                    filterobject.value = formatDateToDateTime(option.data.filter.filters[i].value);
                }
                else {
                    filterobject.value = option.data.filter.filters[i].value;
                }
                filterobject.type = option.data.filter.filters[i].operator;
                filterobject.fieldtype = _fieldstype[option.data.filter.filters[i].field].type;
                filterobject.srfieldtype = _fieldstype[option.data.filter.filters[i].field].srtype;
                filterobject.isList = false;
                filterobject.listType = 0;
                filterobject.code = option.data.filter.filters[i].field;
                if (code != option.data.filter.filters[i].field) {
                    reportFilterObjectListCount = reportFilterObjectListCount + 1;
                    reportFilterObject = new Object();
                    //reportFilterObject = { code: "", name: "", isFilterApplied: false, reportFilterObjectArry: [] };
                    reportFilterObject.code = option.data.filter.filters[i].field;
                    reportFilterObject.name = option.data.filter.filters[i].field;
                    reportFilterObject.isFilterApplied = true;
                    reportFilterObject.fieldtype = _fieldstype[option.data.filter.filters[i].field].type;
                    reportFilterObject.srfieldtype = _fieldstype[option.data.filter.filters[i].field].srtype;
                    reportFilterObject.reportFilterObjectArry = [];
                    json.reportFilterObjectList.push(reportFilterObject);
                    json.reportFilterObjectList[reportFilterObjectListCount].reportFilterObjectArry = [];
                }
                if (isSpecificFilterExists) {
                    onSpecificFilter(id, specificreportFilterObjectList, specificreportFilterObject, specificfilterobject, filterobject.logic, filterobject.value
                        , filterobject.type, filterobject.fieldtype, filterobject.srfieldtype, filterobject.isList, filterobject.listType, reportFilterObject.code
                        , reportFilterObject.name, (code != option.data.filter.filters[i].field ? false : true), true);
                }
                code = option.data.filter.filters[i].field;
                json.reportFilterObjectList[reportFilterObjectListCount].reportFilterObjectArry.push(filterobject);
            }
            else {
                for (var ii = 0; ii < option.data.filter.filters[i].filters.length; ii++) {
                    filterobject = new Object();
                    filterobject.logic = option.data.filter.filters[i].logic;
                    if (_fieldstype[option.data.filter.filters[i].field].srtype == SRVTypes.Date) {
                        filterobject.value = formatDateToDateTime(filterobject.value = option.data.filter.filters[i].filters[ii].value);
                    }
                    else {
                        filterobject.value = option.data.filter.filters[i].filters[ii].value;
                    }
                    filterobject.type = option.data.filter.filters[i].filters[ii].operator;
                    filterobject.fieldtype = _fieldstype[option.data.filter.filters[i].filters[ii].field].type;
                    filterobject.srfieldtype = _fieldstype[option.data.filter.filters[i].filters[ii].field].srtype;
                    filterobject.isList = false;
                    filterobject.listType = 0;
                    filterobject.code = option.data.filter.filters[i].field;
                    if (code != option.data.filter.filters[i].filters[ii].field) {
                        reportFilterObjectListCount = reportFilterObjectListCount + 1;
                        reportFilterObject = new Object();
                        //reportFilterObject = { code: "", name: "", isFilterApplied: false, reportFilterObjectArry: [] };
                        reportFilterObject.code = option.data.filter.filters[i].filters[ii].field;
                        reportFilterObject.name = option.data.filter.filters[i].filters[ii].field;
                        reportFilterObject.isFilterApplied = true;
                        reportFilterObject.fieldtype = _fieldstype[option.data.filter.filters[i].filters[ii].field].type;
                        reportFilterObject.srfieldtype = _fieldstype[option.data.filter.filters[i].filters[ii].field].srtype;
                        reportFilterObject.reportFilterObjectArry = [];
                        json.reportFilterObjectList.push(reportFilterObject);
                        json.reportFilterObjectList[reportFilterObjectListCount].reportFilterObjectArry = [];
                    }
                    if (isSpecificFilterExists) {
                        onSpecificFilter(id, specificreportFilterObjectList, specificreportFilterObject, specificfilterobject, filterobject.logic, filterobject.value
                            , filterobject.type, filterobject.fieldtype, filterobject.srfieldtype, filterobject.isList, filterobject.listType, reportFilterObject.code
                            , reportFilterObject.name, (code != option.data.filter.filters[i].field ? false : true), true);
                    }
                    code = option.data.filter.filters[i].filters[ii].field;
                    json.reportFilterObjectList[reportFilterObjectListCount].reportFilterObjectArry.push(filterobject);
                }
            }
        }
    }

    if (isCustomFilterExists) {
        if (resultjson.customfilterjson.length > 0) {
            for (var i = 0; i < resultjson.customfilterjson.length; i++) {
                json.reportFilterObjectList.push(resultjson.customfilterjson[i]);
            }
        }
    }

    if (isSpecificFilterExists) {
        if (specificreportFilterObjectList.length > 0) {
            for (var i = 0; i < specificreportFilterObjectList.length; i++) {
                json.reportFilterObjectList.push(specificreportFilterObjectList[i]);
            }
        }
    }

    try {
        ReportColumnObjectList = onColumnShowHideObject(id);
    }
    catch (error) {
    }

    if (ReportColumnObjectList.length > 0) {
        json.ReportColumnObjectList = ReportColumnObjectList;
    }

    if (typeof option.data.sort !== "undefined" && option.data.sort !== null) {
        for (var i = 0; i < option.data.sort.length; i++) {
            orderByDirection = option.data.sort[i].dir == 'asc' ? "asc" : "desc";
            orderBy = option.data.sort[i].field;
            json.sortExpression = orderBy + ' ' + orderByDirection;
        }
    }
    json.pageIndex = option.data.page - 1
    if (isNumeric(option.data.pageSize) == true) {
        json.pageSize = option.data.pageSize;
    }
    else {
        json.pageSize = -1;
    }

    return JSON.stringify(json);
}

function HeaderTemplateString(headertitle, headertext) {
    return '<span title="' + headertitle + '" style="white-space: pre-wrap;">' + headertext + '</span>';
}

function GetAutoCompleteFilter(list) {
    return function autocompleteFilter(element) {
        element.kendoAutoComplete({
            dataSource: list  //auto complete variable
        });
    }
}

function GetAutoCompleteFilter(list) {
    return function dropdownlistFilter(element) {
        element.kendoDropDownList({
            dataSource: list, //drop down list
            optionLabel: "--Select Value--"
        });
    }
}

function MainFilterNumberEditor(container, options) {
    $('<input data-bind="value: value" name="' + options.field + '"/>')
        .appendTo(container)
        .kendoNumericTextBox();
}

//function MainFilterDropdownList(container, options) {
//    $('<input data-bind="value: value" name="' + options.field + '"/>')
//        .appendTo(container)
//        .kendoDropDownList({
//            dataTextField: "CategoryName",
//            dataValueField: "CategoryID",
//            dataSource: {
//                type: "odata",
//                transport: {
//                    read: "https://demos.telerik.com/kendo-ui/service/Northwind.svc/Categories"
//                }
//            }
//        });
//}

//function ListStringFilter(element) {
//    element.kendoAutoComplete({
//        dataSource: dataSource,
//        filter: "liststring"
//    });
//}

function ShowHideKendoHierarchyCell(gridid) {
    //return;

    var grid = $("#" + gridid).data("kendoGrid");
    if (grid == undefined) {
        return;
    }

    var isdetailtemplateexists = false;
    if (grid.options.isdetailtemplateexists != undefined && grid.options.isdetailtemplateexists != null) {
        isdetailtemplateexists = grid.options.isdetailtemplateexists;
    }

    //var detailtemplate = new Object();
    //detailtemplate.divid = gridid;
    //detailtemplate.column = 0;

    //if (detailtemplateList.length > 0) {
    //    for (var i = 0; i < detailtemplateList.length; i++) {
    //        if (detailtemplateList[i] == gridid) {
    //            detailtemplate = detailtemplateList[i];
    //            break;
    //        }
    //    }
    //}

    if (isdetailtemplateexists == false) {
        $("#" + gridid + " col.k-hierarchy-col").addClass("hidecolumn");
        $("#" + gridid + " th.k-hierarchy-cell").addClass("hidecolumn");
        $("#" + gridid + " td.k-hierarchy-cell").addClass("hidecolumn");
    }
    //else {
    //    $("#" + gridid + " col.k-hierarchy-col").removeClass("hidecolumn");
    //    $("#" + gridid + " th.k-hierarchy-cell").removeClass("hidecolumn");
    //    $("#" + gridid + " td.k-hierarchy-cell").removeClass("hidecolumn");
    //}
}

var detailtemplateList = [];
// Function to toggle the visibility of a column
function toggleColumnVisibility(columnField, gridid) {
    var grid = $("#" + gridid).data("kendoGrid");
    var column = grid.columns.find(col => col.field === columnField);

    var detailtemplate = new Object();
    detailtemplate.divid = gridid;
    detailtemplate.column = 0;

    if (detailtemplateList.length > 0) {
        for (var i = 0; i < detailtemplateList.length; i++) {
            if (detailtemplateList[i] == gridid) {
                detailtemplate = detailtemplateList[i];
                break;
            }
        }
    }

    if (column) {
        if (column.hidden) {
            // Unhide the column
            grid.showColumn(column);
            detailtemplate.column = detailtemplate.column - 1;
            grid.options.detailTemplate = grid.options.detailTemplate.replace("<strong>#: data." + column.field + " #</strong>", "");
        } else {
            // Hide the column and move it to the detail template
            //grid.options.detailTemplate += "#: data." + column.field + " #";

            detailtemplate.column = detailtemplate.column + 1;
            grid.hideColumn(column);
        }

        // Update the detail template dynamically
        var detailTemplate = "# if (data." + column.field + " !== undefined) { #";
        detailTemplate += "Details for: #: data." + column.field + " #";
        detailTemplate += "# } else { #";
        detailTemplate += "No details available.";
        detailTemplate += "# } #";

        grid.setOptions({ detailTemplate: kendo.template(detailTemplate) });

        if (detailtemplate.column <= 0) {
            $("#" + gridid + " td.k-hierarchy-cell").addClass("hidecolumn");
        }
        else {
            $("#" + gridid + " td.k-hierarchy-cell").removeClass("hidecolumn");
        }

        var isfound = false;
        if (detailtemplateList.length > 0) {
            for (var i = 0; i < detailtemplateList.length; i++) {
                if (detailtemplateList[i] == gridid) {
                    detailtemplateList[i] = detailtemplate;
                    isfound = true;
                    break;
                }
            }
        }

        if (isfound == false) {
            detailtemplateList.push(detailtemplate);
        }

        // Re-render the grid
        grid.refresh();
    } else {
        alert("Column not found!");
    }
}

function toggleVisibilityButtonclicked(this_, gridid) {
    var columnFieldToToggle = this_.val(); // Get the column field from user input
    toggleColumnVisibility(columnFieldToToggle, gridid);
}

const columnMenuInit = function (e) {
    // Add a custom menu item for moving the column to the detail template
    e.container.find(".k-menu-column-remove").before('<li class="k-item k-state-default" data-command="move-to-detail-template"><span class="k-link">Move to Detail Template</span></li>');
};

const columnMenuClick = function (e) {
    if (e.item.attr("data-command") === "move-to-detail-template") {
        var columnField = e.target.closest("li").data("field");
        toggleColumn(columnField);
    }
};

function GetOrderString(OrderNo) {
    OrderNo = (OrderNo == undefined ? "" : OrderNo);
    OrderNo = (OrderNo == null ? "" : OrderNo);
    if (OrderNo.length > 0) {
        return '<a onclick="GETCryptoURLSearchOrder(\'' + OrderNo + '\')" style="cursor:pointer;color:#428bca" title="View Order Detail"> ' + OrderNo + '</a>';
    }
    else {
        return "";
    }
}

function GetOrderStringFromCommaSeparatedstring(OrderNoString) {
    var returnstring = "";
    OrderNoString = (OrderNoString == undefined ? "" : OrderNoString);
    OrderNoString = (OrderNoString == null ? "" : OrderNoString);
    if (OrderNoString.length > 0) {
        var orderslist = OrderNoString.split(',');
        for (var i = 0; i < orderslist.length; i++) {
            if (orderslist[i] != "" && returnstring == "") {
                returnstring = '<a onclick="GETCryptoURLSearchOrder(\'' + orderslist[i] + '\')" style="cursor:pointer;color:#428bca" title="View Order Detail ' + orderslist[i] + '">' + orderslist[i] + '</a>';
            }
            else if (orderslist[i] != "") {
                returnstring += ', <a onclick="GETCryptoURLSearchOrder(\'' + orderslist[i] + '\')" style="cursor:pointer;color:#428bca" title="View Order Detail ' + orderslist[i] + '">' + orderslist[i] + '</a>';
            }
        }
        if (returnstring != "") {
            returnstring = '<span>' + returnstring + '</span>';
        }
        return returnstring;
    }
    else {
        return returnstring;
    }
    return returnstring;
}

function GETCryptoURLSearchOrder(OrderID) {
    $.ajax({
        url: "/Order/GetEncryptOrderId",
        dataType: 'json',
        type: 'Get',
        data: { "OrderID": OrderID },
        cache: false,
        contentType: "application/json",
        success: function (result) {
            if (result.URL != null && result.URL != undefined)
                window.open("/Order/OrderDetail" + result.URL);
        },
        error: function (result) {
        }
    });
}

function GetValuesWithSignalQuote(value_) {
    var returnstring = ""
    value_ = (value_ == undefined ? "" : value_);
    value_ = (value_ == null ? "" : value_);
    var list = value_.split(',');
    for (var i = 0; i < list.length; i++) {
        returnstring += (returnstring == "" ? "" : ",") + "'" + list[i] + "'";
    }
    return returnstring;
}

function SetCustomFilterValue(customreportFilterObjectList, reportFilterObject, filterobject, logic, value, filtertype, fieldtype, srvfieldtype, islist, listtype, code, name, isprevioussamecode) {
    var filterobject = new Object();
    filterobject.logic = logic;
    filterobject.value = value;
    filterobject.type = filtertype;
    filterobject.fieldtype = fieldtype;
    filterobject.srfieldtype = srvfieldtype;
    filterobject.isList = islist;
    filterobject.listType = listtype;
    filterobject.code = code;

    if (isprevioussamecode == false) {
        reportFilterObject = new Object();
        reportFilterObject.code = code;
        reportFilterObject.name = name;
        reportFilterObject.isFilterApplied = true;
        reportFilterObject.fieldtype = fieldtype;
        reportFilterObject.srfieldtype = srvfieldtype;
        reportFilterObject.reportFilterObjectArry = [];
        customreportFilterObjectList.push(reportFilterObject);
        customreportFilterObjectList[customreportFilterObjectList.length - 1].reportFilterObjectArry = [];
    }
    customreportFilterObjectList[customreportFilterObjectList.length - 1].reportFilterObjectArry.push(filterobject);
}

function RefreshGridData(divId) {
    if (divId != undefined && divId != null) {
        if (divId != '') {
            $("#PageLoader").show();
            var grid = $("#" + divId).data("kendoGrid");
            if (grid == undefined) {
                $("#PageLoader").hide();
                return;
            }
            grid.dataSource.read();
        }
    }
}

function ResetGridFilter(divId) {
    if (divId != undefined && divId != null) {
        if (divId != '') {
            var grid = $("#" + divId).data("kendoGrid");
            if (grid == undefined) {
                $("#PageLoader").hide();
                return;
            }
            //var _dataSource = GetDataSource(grid.dataSource.pageSize());
            grid.dataSource.filter(null);
            grid.dataSource.read();
            //grid.refresh();
            //grid.setDataSource(_dataSource);
        }
    }
}

function GetString(value_) {
    value_ = (value_ == undefined ? "" : value_);
    value_ = (value_ == null ? "" : value_);
    return value_;
}

function updateHeaderTooltips(divid, isnotmatchonly = true, hasclasstooltip = false) {
    // Iterate through each grid cell containing the class "k-grid-content"
    $("#" + divid + " .k-table-thead").find("th .k-column-title").each(function () {
        if ((!$(this).closest('th').hasClass('notooltip')) || (hasclasstooltip && $(this).closest('th').hasClass('tooltip'))) {
            var isaddtooltip = true;
            if (isnotmatchonly) {
                if (this.offsetWidth > this.scrollWidth) {
                    isaddtooltip = false;
                }
            }
            if (isaddtooltip) {
                // Get the cell content
                var cellContent = $(this).text();
                // Set the title attribute to display the tooltip
                $(this).closest('th').attr("title", cellContent);
            }
        }
    });
}

function updateContentTooltips(divid, isnotmatchonly = true, hasclasstooltip = false) {
    // Iterate through each grid cell containing the class "k-grid-content"
    $("#" + divid + " .k-table-tbody").find("td.k-table-td").each(function () {
        if ((!$(this).closest('td').hasClass('notooltip')) || (hasclasstooltip && $(this).closest('td').hasClass('tooltip'))) {
            var isaddtooltip = true;
            if (isnotmatchonly) {
                if (this.offsetWidth > this.scrollWidth) {
                    isaddtooltip = false;
                }
            }
            if (isaddtooltip) {
                // Get the cell content
                var cellContent = $(this).text();
                // Set the title attribute to display the tooltip
                $(this).closest('td').attr("title", cellContent);
            }
        }
    });
}

// Kendo Grid Scripts onKendoDataBound, onCustomFilterValidate, onClickExportExcel, onCustomFilter, onSpecificFilter, customreportFilterObjectList, onColumnShowHideObject, onReset
function onKendoDataBound() {
    var customfixheader = false
    if (this.options.customfixheader != undefined) {
        customfixheader = this.options.customfixheader;
    }

    if (customfixheader) {
        $('#' + this.wrapper[0].id + ' .k-grid-header').addClass('fixed-header');
    }

    ShowHideKendoHierarchyCell(this.wrapper[0].id);
    updateHeaderTooltips(this.wrapper[0].id, false, false);
    updateContentTooltips(this.wrapper[0].id, true, false);
    InitializeHeaderSelectCheckBox();
    var pageloaderid = 'PageLoader';
    if (this.options.pageloaderid != undefined) {
        pageloaderid = this.options.pageloaderid;
    }

    $("#" + pageloaderid).hide();
}
function onKendoDataBind(this_) {
    var customreorderColumns = false;
    if (this_.options.customreorderColumns != undefined) {
        customreorderColumns = this_.options.customreorderColumns;
    }

    if (customreorderColumns) {
        reorderColumns(this_.wrapper[0].id);
    }

    var pageloaderid = 'PageLoader';
    if (this_.options.pageloaderid != undefined) {
        pageloaderid = this_.options.pageloaderid;
    }
    $("#" + pageloaderid).hide();
}
function reorderColumns(gridid) {
    var grid = $("#" + gridid).data("kendoGrid");
    
    var currentorderIndex = 0;
    for (var i = 0; i < grid.columns.length; i++) {
        var columnIndex = grid.columns[i].orderIndex;
        if (columnIndex == currentorderIndex) {
            grid.reorderColumn(columnIndex, grid.columns[i]);
            currentorderIndex += 1;
            i = 0;
        }
    }
}
function SetLoadingOnRefreshButton(this_, pageloaderid = 'PageLoader') {
    var grid = this_;

    // Once the grid is data-bound, bind to the dataBound event
    grid.bind("dataBound", function () {
        // Find the refresh button element within the grid
        var refreshButton = grid.wrapper.find(".k-pager-refresh");

        // Attach a click event listener to the refresh button
        refreshButton.click(function () {
            // Show the loader or perform any other actions you want
            $("#" + pageloaderid).show();
        });
    });
}

function GetCheckboxState(className) {
    var checkboxes = $("." + className);
    var checkedCount = 0;
    var uncheckedCount = 0;

    checkboxes.each(function () {
        if ($(this).prop("checked")) {
            checkedCount++;
        } else {
            uncheckedCount++;
        }
    });

    if (checkedCount === checkboxes.length) {
        return "allChecked";
    } else if (uncheckedCount === checkboxes.length) {
        return "allUnchecked";
    } else {
        return "partial";
    }
}

function IsAllUncheckOrChecked(className) {
    var checkboxes = $("." + className);
    var checkedCount = 0;
    var uncheckedCount = 0;

    checkboxes.each(function () {
        if ($(this).prop("checked")) {
            checkedCount++;
        } else {
            uncheckedCount++;
        }
    });

    if (checkedCount === checkboxes.length) {
        return true;
    } else if (uncheckedCount === checkboxes.length) {
        return true;
    } else {
        return false;
    }
}
function CheckUnCheckAllColumns(this_, setchecked, callback) {
    var classname = $(this_).attr("checkboxclass");
    var setvalue = (setchecked == undefined ? $(this_).attr("setvalue") : setchecked);
    if (setvalue == 'true') {
        //$("." + classname).prop('checked', true);
        if (setchecked == undefined) {
            $("." + classname).each(function () {
                $(this).prop('checked', true);
                //ShowHideColumnsInGrid(this, false);
            });
        }
        // Invoke the callback function
        if (typeof callback === 'function') {
            callback();
        }
        $("#" + this_.id).text('Uncheck All');
        $("#" + this_.id).attr('setvalue', "false");
    }
    else {
        //$("." + classname).prop('checked', false);
        if (setchecked == undefined) {
            $("." + classname).each(function () {
                $(this).prop('checked', false);
                //ShowHideColumnsInGrid(this, false);
            });
        }
        // Invoke the callback function
        if (typeof callback === 'function') {
            callback();
        }
        $("#" + this_.id).text('Check All');
        $("#" + this_.id).attr('setvalue', "true");
    }
}

function ShowHideColumnsDiv(this_, type) {
    if ($(this_).attr("alt") == 'collapse') {
        $("#" + $(this_).attr("divid")).hide();
        $("#" + $(this_).attr("checkid")).hide();
        if (type == 'column') {
            $("#" + $(this_).attr("nameid")).text('Show Columns');
        }
        else if (type == 'filter') {
            $("#" + $(this_).attr("nameid")).text('Show Filter By');
        }
        $(this_).attr('alt', "expand");
        $(this_).attr('title', "Expand Columns");
        $(this_).attr('src', "/img/expand.png");
    }
    else {
        $("#" + $(this_).attr("divid")).show();
        $("#" + $(this_).attr("checkid")).show();
        if (type == 'column') {
            $("#" + $(this_).attr("nameid")).text('Hide Columns');
        }
        else if (type == 'filter') {
            $("#" + $(this_).attr("nameid")).text('Hide Filter By');
        }
        $(this_).attr('alt', "collapse");
        $(this_).attr('title', "Collapse Columns");
        $(this_).attr('src', "/img/collapse.png");
    }
}

function GetColumnRequiredJson(divid, callback) {
    var checkboxData = [];
    var checkboxInfo = new Object();
    // Iterate over each checkbox with the specified class
    $('#div_' + divid + '_columnhideshowexpandcollaspe input[type="checkbox"]').each(function () {
        var checkbox = $(this);
        var checkboxCode = checkbox.val();
        var checkboxName = checkbox.attr('name');
        var IsChecked = checkbox.prop('checked');

        // Create an object with checkbox attributes
        checkboxInfo = new Object();
        checkboxInfo.Code = checkboxCode;
        checkboxInfo.Name = checkboxName;
        checkboxInfo.IsColumnRequired = IsChecked;

        // Add checkboxInfo object to the checkboxData array
        checkboxData.push(checkboxInfo);
    });

    // Invoke the callback function and pass the checkbox data
    if (typeof callback === 'function') {
        callback(checkboxData);
    }

    //return checkboxData;
}
function ShowHideColumnsInGridFromLabel(this_, ischeckall, callback) {
    var IsChecked = $(this_).prop('checked');
    if (IsChecked) {
        $(this_).prop('checked', false);
        ShowHideColumnsInGrid(this_, ischeckall, callback);
    }
    else {
        $(this_).prop('checked', true);
        ShowHideColumnsInGrid(this_, ischeckall, callback);
    }
}
function CallFunction(callback) {
    if (typeof callback === 'function') {
        callback();
    }
}
function ShowHideColumnsInGrid(this_, ischeckall, callback) {
    ischeckall = (ischeckall == undefined ? true : false);
    var grid = $("#" + $(this_).attr('gridid')).data("kendoGrid");
    if (grid != undefined) {
        $("#PageLoader").show();
        var columnTitle = $(this_).attr('name');
        var checkbox = $(this_);
        var IsChecked = checkbox.prop('checked');
        var columnIndex = -1;

        if (IsChecked) {
            var columns = grid.columns;
            var gridcolumntitle;
            for (var i = 0; i < columns.length; i++) {
                gridcolumntitle = (columns[i].titlename === undefined || columns[i].titlename === null) ? columns[i].title : columns[i].titlename;
                gridcolumntitle = (gridcolumntitle === undefined || gridcolumntitle === null) ? columns[i].field : gridcolumntitle;
                if (gridcolumntitle === columnTitle) {
                    columnIndex = i;
                    grid.showColumn(i);
                    break;
                }
            }
        }
        else if (IsChecked == false) {
            var columns = grid.columns;
            var gridcolumntitle;
            for (var i = 0; i < columns.length; i++) {
                gridcolumntitle = (columns[i].titlename === undefined || columns[i].titlename === null) ? columns[i].title : columns[i].titlename;
                gridcolumntitle = (gridcolumntitle === undefined || gridcolumntitle === null) ? columns[i].field : gridcolumntitle;
                if (gridcolumntitle === columnTitle) {
                    columnIndex = i;
                    grid.hideColumn(i);
                    break;
                }
            }
        }

        $("#PageLoader").hide();

        if (columnIndex !== -1) {
            // Invoke the callback function
            if (typeof callback === 'function' && IsChecked) {
                callback();
            }
            else {
                // Adjust the column widths
                adjustColumnWidths();
            }
        }

        function adjustColumnWidths() {
            grid.dataSource.read();
            return;

            $("#PageLoader").show();
            var visibleColumns = grid.columns.filter(function (column) {
                return !column.hidden;
            });

            var totalWidth = grid.wrapper.width();
            var totalPercentage = 0;

            // Calculate total percentage of visible columns
            visibleColumns.forEach(function (column) {
                totalPercentage += column.width;
            });

            // Adjust widths of visible columns based on total width and percentage
            visibleColumns.forEach(function (column) {
                var newWidth = (column.width / totalPercentage) * totalWidth;
                column.width = Math.floor(newWidth);
            });

            // Refresh the grid to apply the new widths
            if (IsChecked) {
                grid.dataSource.read();
            } else {
                grid.refresh();
            }
            //$("#PageLoader").hide();
        }
    }

    if (ischeckall == true) {
        if (IsAllUncheckOrChecked($(this_).attr("classname"))) {
            CheckUnCheckAllColumns($('#' + $(this_).attr("gridid") + '_columnhideshow')[0], IsChecked.toString());
        }
    }
}

function GetCheckboxValueFromClassAndAttribute(id, attributeValue, attributeName) {
    var checkboxValue = false;
    $("#" + id + " input[type='checkbox']").each(function () {
        // Check if the checkbox has the specified attribute with the given value
        if ($(this).attr('value') === attributeValue && $(this).attr('name') === attributeName) {
            // If the checkbox matches both class and attribute criteria, get its value
            checkboxValue = !$(this).prop('checked');
            // Exit the loop once a matching checkbox is found
            return checkboxValue;
        }
    });
    return checkboxValue;
}

function GetOrderIndexFromClassAndAttribute(id, attributeValue, attributeName) {
    var getorderindex = 9999;
    $("#" + id + " input[type='checkbox']").each(function () {
        // Check if the checkbox has the specified attribute with the given value
        if ($(this).attr('value') === attributeValue && $(this).attr('name') === attributeName) {
            // If the checkbox matches both class and attribute criteria, get its value
            getorderindex = $(this).attr('orderindex');
            // Exit the loop once a matching checkbox is found
            getorderindex = ((getorderindex == undefined || getorderindex == null || getorderindex == "") ? 9999 : parseInt(getorderindex));
            if (getorderindex == 9999) {
                alert('Column Order Index is Not Set. Field is ' + attributeValue + ' & Title is ' + attributeName);
            }

            return getorderindex;
        }
    });
    if (getorderindex == 9999) {
        alert('Column Order Index is Not Set. Field is ' + attributeValue + ' & Title is ' + attributeName);
    }
    return getorderindex;
}

function SetGridColumnPosition(id, columntitle, orderindex) {
    var grid = $("#" + id).data("kendoGrid");
    if (grid != undefined) {
        var isdetailtemplateexists = false;
        if (grid.options != undefined && grid.options != null) {
            if (grid.options.isdetailtemplateexists != undefined && grid.options.isdetailtemplateexists != null) {
                isdetailtemplateexists = grid.options.isdetailtemplateexists;
            }
        }
        var columns = grid.columns;
        var gridcolumntitle;
        var gridColumn;
        for (var i = 0; i < columns.length; i++) {
            gridcolumntitle = (columns[i].titlename === undefined || columns[i].titlename === null) ? columns[i].title : columns[i].titlename;
            gridcolumntitle = (gridcolumntitle === undefined || gridcolumntitle === null) ? columns[i].field : gridcolumntitle;
            if (gridcolumntitle === columntitle) {
                gridColumn = columns[i];
                break;
            }
        }

        if (gridColumn) {
            grid.reorderColumn(orderindex, gridColumn);
            if (isdetailtemplateexists == false) {
                ShowHideKendoHierarchyCell(id);
            }
        }
    }
}

const HeaderSelectAllCheckBox = "<input type='checkbox' id='SellectALL' class='SellectALL' value='true'>";
function InitializeHeaderSelectCheckBox() {
    $(function () {

        //// add multiple select / deselect functionality
        $("#SellectALL").click(function () {
            $('.Sellectone').prop('checked', this.checked);
        });

        // if all checkbox are selected, check the selectall checkbox
        // and viceversa
        $(".Sellectone").click(function () {
            if ($(".Sellectone").length == $(".Sellectone:checked").length) {
                $("#SellectALL").prop("checked", true);
            }
            else {
                $("#SellectALL").prop("checked", false);
            }
        });

    });
}
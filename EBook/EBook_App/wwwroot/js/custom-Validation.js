class CustomValidator {
    static checkboxrequired(value) {
        return value !== false;
    }

    static none(value) {
        return true; // No validation for "none"
    }

    static requiredvalue(value) {
        return value !== "";
    }

    static numbernotempty(value) {
        return !isNaN(value);
    }

    static positivenumber(value) {
        return !isNaN(value) && parseFloat(value) > 0;
    }

    static negativenumber(value) {
        return !isNaN(value) && parseFloat(value) < 0;
    }

    static withoutzeronumber(value) {
        return !isNaN(value) && parseFloat(value) !== 0;
    }

    static textwithempty(value) {
        return typeof value === "string";
    }

    static textnotempty(value) {
        return typeof value === "string" && value.trim() !== "";
    }

    static datewithempty(value) {
        return value instanceof Date;
    }

    static datenotempty(value) {
        return value instanceof Date && !isNaN(value.getTime());
    }
}
var requiredFields;

function KendoDateInitial(id = 'kendoDatePicker', isclass = true, _animation = false, _format = 'MM/dd/yyyy', _addclearbutton = true) {
    $((isclass ? '.' : '#') + id).kendoDatePicker({
        animation: _animation,
        format: _format,
        open: function (e) {
            if (_addclearbutton) {
                var clearbuttonContainer = e.sender.dateView.calendar.element.find(".clear-button-container");

                if (!clearbuttonContainer.length) {
                    // Create a container for custom buttons
                    clearbuttonContainer = $('<div class="k-footer clear-button-container"></div>');

                    // Create custom button (Clear Date) and append it to the container
                    var clearbutton = $('<button tabindex="-1" class="k-button custom-clear-button k-flex k-button-md k-button-flat k-button-flat-primary k-rounded-md" title="Clear Date"><span style="color:red" class="k-button-text">Clear Date</span></button>');
                    clearbuttonContainer.append(clearbutton);

                    // Append the custom buttons container to the DatePicker popup
                    e.sender.dateView.calendar.element.append(clearbuttonContainer);

                    // Handle click events for the custom button
                    clearbutton.on("click", function () {
                        // Clear the selected date
                        e.sender.value(new Date());
                        e.sender.value(null);
                        // Close the DatePicker
                        e.sender.close();
                    });
                }
            }
        }
    });
}
function CKEDITORInitial(id) {
    CKEDITOR.replace(id, {
        height: 150,
        extraPlugins: 'colorbutton',
        colorButton_colors: 'FF0000,00FF00,0000FF,FFFF00,FF00FF,00FFFF,000000,FFFFFF,808080,C0C0C0,800000,008000,000080,FFFF80,FF80FF,80FFFF,800080,008080,808000,FF8080'
    });
}
function Select2Initial(id = 'select2', isclass = true) {
    $((isclass ? '.' : '#') + id).select2();
}
function customValidation(value, validationType, element) {
    //if (validationType === 'checkboxrequired') {
    //    return element.checked;
    //}

    if (typeof CustomValidator[validationType] === "function") {
        return CustomValidator[validationType](value);
    } else {
        console.error("Unknown validation type:", validationType);
        return false;
    }
}

function getValue(element) {
    if (element.type === 'checkbox') {
        return element.checked;
    } else if (element.type === 'radio') {
        const group = document.getElementsByName(element.name);
        const selectedRadio = [...group].find(radio => radio.checked);
        return selectedRadio ? selectedRadio.value : null;
    } else {
        return element.value;
    }
}

function validateForm(id) {
    const modal = document.getElementById(id);
    const elements = modal.querySelectorAll('.custom-validation');
    const validationErrors = modal.querySelectorAll('.validationError');
    let allValid = true;

    elements.forEach((element, index) => {
        const validationError = validationErrors[index];
        const validationType = element.getAttribute('data-validation-types');
        const value = getValue(element);

        if (customValidation(value, validationType, element)) {
            validationError.textContent = ""; // Clear any previous error message
        } else {
            validationError.textContent = "Validation failed!";
            allValid = false;
        }
    });

    if (allValid) {
        alert("Form is valid!");
    } else {
        alert("Form validation failed!");
    }
}

function CallbackValue(_callback) {
    // do some asynchronous work
    // and when the asynchronous stuff is complete
    _callback();
}

function resetmodal(id) {
    if (id == undefined) {
        id = "dynamic-modal1";
    }

    $('#' + id).hide();
    $('#' + id).html('');
}
function waitForConfirmation(title, msg, nobutton, yesbutton, issamebothbutton, yesCallback, noCallback) {
    return new Promise(function (resolve, reject) {
        // Display confirmation dialog
        Confirmation(title, '<h5>' + msg + '</h5>', true, '', '', nobutton, yesbutton, true, true, '');
        if (issamebothbutton) {
            $('#modal-confirmation-no').removeClass('text-danger');
            $('#modal-confirmation-no').removeClass('btn-light-danger');
            $('#modal-confirmation-no').addClass('Theme-button');
        }
        // Define a function to handle button click events
        function handleClick(event) {
            if (event.target.id === 'modal-confirmation-yes') {
                resolve(true); // Resolve the promise with true when Yes is clicked
                Confirmation('', '', false, '', '', 'No', 'Yes', true);
                if (yesCallback) yesCallback();
            } else if (event.target.id === 'modal-confirmation-no') {
                resolve(false); // Resolve the promise with false when No is clicked
                Confirmation('', '', false, '', '', 'No', 'Yes', true);
                if (noCallback) noCallback();
            }
            // Remove event listeners to avoid memory leaks
            $("#modal-confirmation-yes").off("click", handleClick);
            $("#modal-confirmation-no").off("click", handleClick);
        }

        // Set up event listeners for the Yes and No buttons
        $("#modal-confirmation-yes").on("click", handleClick);
        $("#modal-confirmation-no").on("click", handleClick);
    });
}

function Confirmation(title, msg, isshow, onclickevent, onclickname, nobutton, yesbutton, IsResetParaAdd, IsResetModal, modalid,) {
    if (isshow == true) {
        $("#modal-confirmation-yes").removeAttr("disabled");
        $("#modal-confirmation-div").attr("style", "display:block");
        if (onclickevent !== '') {
            $("#modal-confirmation-yes").attr(onclickevent, onclickname);
        }
        $("#modal-confirmation-div").addClass("show");
        $("#modal-confirmation-div").attr("aria-modal", "true");
        $("#modal-confirmation-div").removeAttr("aria-hidden");
    }
    else {
        $("#modal-confirmation-yes").attr("disabled", "disabled");
        $("#modal-confirmation-div").removeAttr("style");
        $("#modal-confirmation-div").removeClass("show");
        if (onclickevent !== '') {
            $("#modal-confirmation-yes").removeAttr(onclickevent);
        }
        $("#modal-confirmation-div").removeAttr("aria-modal");
        $("#modal-confirmation-div").attr("aria-hidden", "true");
    }
    $("#modal-confirmation-title").html(title);
    $("#modal-confirmation-message").html(msg);
    $("#modal-confirmation-no").text(nobutton)
    $("#modal-confirmation-yes").text(yesbutton)
    if (IsResetParaAdd == true) {
        $("#modal-confirmation-no").attr("onclick", "Confirmation('','',false,'','','No','Yes',true);")
        $('#modal-confirmation-div').removeClass('blurbackground')
        $('#modal-confirmation-no').removeClass('btn-light-secondary');
        $('#modal-confirmation-yes').removeClass('btn-light-secondary');
        $('#modal-confirmation-no').addClass('btn-light-danger');
        $('#modal-confirmation-no').addClass('text-danger');
        $('#modal-confirmation-yes').addClass('Theme-button');
        $('#modal-confirmation-no').removeClass('Theme-button');
        $('#modal-confirmation-no').removeClass('text-black');
    }
    if (IsResetModal == true) {
        resetmodal(modalid);
        $("#modal-confirmation-no").removeAttr('onclick')
        $("#modal-confirmation-no").attr("onclick", "Confirmation('','',false,'','','No','Yes',true);")
    }
}

function VerifySessionStatus(this_) {
    if ($(this_).attr("disabled") == "disabled") {
        return;
    }
    $(this_).attr("disabled", "disabled");
    $("#pageoverlay").show();

    location.reload();

    $(this_).removeAttr("disabled")
    SessionMessage(false);
    $("#pageoverlay").hide();
}

function SessionMessage(isshow, showopenpagebutton = true) {
    if (isshow == true) {
        $("#modal-session-div").attr("style", "display:block");
        $("#modal-session-div").addClass("show");
        $("#modal-session-div").attr("aria-modal", "true");
        $("#modal-session-div").removeAttr("aria-hidden");
    }
    else {
        $("#modal-session-div").removeAttr("style");
        $("#modal-session-div").removeClass("show");
        $("#modal-session-div").removeAttr("aria-modal");
        $("#modal-session-div").attr("aria-hidden", "true");
    }
    if (showopenpagebutton == true) {
        $("#modal-session-openpage").show();
        $("#loginopenpage_msg").show();
    }
    else {
        $("#modal-session-openpage").hide();
        $("#loginopenpage_msg").hide();
    }
}

function WarningMessage(title, msg, isshow, okbutton) {
    if (isshow == true) {
        $("#modal-message-div").attr("style", "display:block");
        $("#modal-message-div").addClass("show");
        $("#modal-message-div").attr("aria-modal", "true");
        $("#modal-message-div").removeAttr("aria-hidden");
    }
    else {
        $("#modal-message-div").removeAttr("style");
        $("#modal-message-div").removeClass("show");
        $("#modal-message-div").removeAttr("aria-modal");
        $("#modal-message-div").attr("aria-hidden", "true");
    }
    $("#modal-message-title").html(title);
    $("#modal-warning-message").html(msg);
    $("#modal-message-ok").text(okbutton)
}

function GetValidEmail(email) {
    var RetObj;
    var newemail = ""
    var retemailresult = false;
    if (email != "") {
        var a;
        a = email.split(";");
        for (i = 0; i <= a.length - 1; i++) {
            if (a[i].replace(' ', '') != "") {
                retemailresult = validateEmail(a[i].replace(' ', ''));
                if (newemail == "") {
                    newemail = a[i].replace(' ', '');
                }
                else {
                    newemail = newemail + ';' + a[i].replace(' ', '');
                }
                if (retemailresult == false) {
                    break;
                }
            }
        }
    }
    else {
        retemailresult = true;
    }
    RetObj = { email: newemail, retemailresult: retemailresult };
    return RetObj;
}

function validateEmail(email) {
    const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
}

function setSelectedValue(selectObj, valueToSet) {
    for (var i = 0; i < selectObj.options.length; i++) {
        if (selectObj.options[i].value == valueToSet) {
            selectObj.options[i].selected = true;
            return;
        }
        else {
            selectObj.options[i].selected = false;
        }
    }
}

function CheckBoxCheckUnCheck(id, value) {
    $("#" + id).prop("checked", value);
    document.getElementById(id).checked = value;
    if (value == true) {
        $("#" + id).attr("checked", "checked");
    }
    else {
        $("#" + id).removeAttr("checked");
    }
}

(function ($) {
    $.fn.focusTextToEnd = function () {
        this.focus();
        var $thisVal = this.val();
        this.val('').val($thisVal);
        return this;
    }
}(jQuery));

function maxLengthCheck(this_) {
    var isfocusendof = false;
    if (parseFloat(this_.value) > parseFloat(this_.max)) {
        this_.value = this_.attributes.oldinputval.value;
        isfocusendof = true;
    }
    else {
        this_.setAttribute('oldinputval', this_.value.toString());
    }
    var isstep = false;
    var step;
    var steps = 0;
    if (this_.hasAttribute("step") == true) {
        if (isNumeric(this_.attributes.step.value)) {
            isstep = true;
            step = parseInt(this_.attributes.step.value);
        }
    }
    if (this_.value.indexOf('.') > -1) {
        steps = this_.value.substring(this_.value.indexOf('.') + 1, this_.value.length).length;
        if (this_.hasAttribute("step") == true) {
            if (isNumeric(this_.attributes.step.value)) {
                isstep = true;
                step = parseInt(this_.attributes.step.value);
                step = (steps < step ? steps : step);
                this_.value = parseFloat(this_.value).toFixed(step);
            }
        }
    }
    if (step == 0) {
        this_.value = parseInt(this_.value);
        isfocusendof = true;
    }
    if (this_.value.length > this_.maxLength)
        this_.value = this_.value.slice(0, this_.maxLength);
    if (isfocusendof == true) {
        $(this_).focusTextToEnd();
    }
}

function InitializeOptions(modalid, type, date, select2, IsHideClearDate, IsHideCurrentDate) {
    if ($('#' + modalid).html() != "") {
        $("#" + modalid).focus();
    }
    if (type == 1) {
        if (select2 == 1) {
            $(".select2").select2();
        }
        if (date == 1) {
            if (IsHideClearDate == true && IsHideCurrentDate == true) {
                $(".datepicker").datepicker({
                    changeMonth: true,
                    changeYear: true,
                    altFormat: "mm/dd/yyyy",
                    numberOfMonths: 2,
                });
            }
            else if (IsHideCurrentDate == true) {
                $(".datepicker").datepicker({
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true,
                    showCurrentButtonPanel: false,
                    altFormat: "mm/dd/yyyy",
                    numberOfMonths: 2,
                });
            }
            else if (IsHideClearDate == true) {
                $(".datepicker").datepicker({
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true,
                    showClearButtonPanel: false,
                    altFormat: "mm/dd/yyyy",
                    currentText: "Current Date",
                    numberOfMonths: 2,
                });
            }
            else {
                $(".datepicker").datepicker({
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true,
                    altFormat: "mm/dd/yyyy",
                    currentText: "Current Date",
                    numberOfMonths: 2,
                });
            }
        }
    }
}

// Validation Function Start
function validate(element) {
    var id = '#' + element.id;
    var txt = $(id).val();
    if (txt.length > 0) {
        $(id).removeClass('is-invalid');
    }
    else {
        $(id).addClass('is-invalid');
    }
}
function validateRequiredFields(ObjJson, requiredFields) {
    var returnValue = true;
    for (const field of requiredFields) {
        if (!ObjJson[field]) {
            toastr.error(`Please fill in ${field.replace(/_/g, ' ')}.`);
            return false;
        }
    }
    return returnValue;
}
function convertDateFormat(dateString) {
    const months = {
        Jan: '01', Feb: '02', Mar: '03', Apr: '04', May: '05', Jun: '06',
        Jul: '07', Aug: '08', Sep: '09', Oct: '10', Nov: '11', Dec: '12'
    };
    const [day, monthAbbr, year] = dateString.split('-');
    const month = months[monthAbbr];
    return `${year}-${month}-${day.padStart(2, '0')}`;
}
function formatDate(inputDate) {
    const date = new Date(inputDate);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}
function maxLengthCheck(this_) {
    var isfocusendof = false;
    if (parseFloat(this_.value) > parseFloat(this_.max)) {
        this_.value = this_.attributes.oldinputval.value;
        isfocusendof = true;
    }
    else {
        this_.setAttribute('oldinputval', this_.value.toString());
    }
    var isstep = false;
    var step;
    var steps = 0;
    if (this_.hasAttribute("step") == true) {
        if (isNumeric(this_.attributes.step.value)) {
            isstep = true;
            step = parseInt(this_.attributes.step.value);
        }
    }
    if (this_.value.indexOf('.') > -1) {
        steps = this_.value.substring(this_.value.indexOf('.') + 1, this_.value.length).length;
        if (this_.hasAttribute("step") == true) {
            if (isNumeric(this_.attributes.step.value)) {
                isstep = true;
                step = parseInt(this_.attributes.step.value);
                step = (steps < step ? steps : step);
                this_.value = parseFloat(this_.value).toFixed(step);
            }
        }
    }
    if (step == 0) {
        this_.value = parseInt(this_.value);
        isfocusendof = true;
    }
    if (this_.value.length > this_.maxLength)
        this_.value = this_.value.slice(0, this_.maxLength);
    if (isfocusendof == true) {
        $(this_).focusTextToEnd();
    }
}
// Validation Function End
// Sorting Function Start
let isUpMethodsExecuted = false;
let isDownMethodsExecuted = false;
function upClickMove() {
    if (!isUpMethodsExecuted) {
        $('.Sort_List').on('click', '.up', function () {
            const index = $(this).index('.up');
            if (index !== -1) {
                moveUp.apply(this, arguments);
            }
        });
        isUpMethodsExecuted = true;
    }
}
function downClickMove() {
    if (!isDownMethodsExecuted) {
        $('.Sort_List').on('click', '.down', function () {
            const index = $(this).index('.down');
            if (index !== -1) {
                moveDown.apply(this, arguments);
            }
        });
        isDownMethodsExecuted = true;
    }
}
function updateSortValues() {
    const listItems = $('.Sort_List tbody tr');
    listItems.each(function (index) {
        const sortValue = $(this).find('#New_Sort_Value');
        sortValue.text(index + 1);
    });
}
function checkButtonVisibility() {
    if ($('.Sort_List tbody .up:not(:first)').is(':hidden')) {
        $('.Sort_List tbody .up:first').hide();
        $('.Sort_List tbody .up:not(:first)').show();
    }
    else {
        $('.Sort_List tbody .up:first').hide();
        $('.Sort_List tbody .up:not(:first)').show();
    }
    if ($('.Sort_List tbody .down:not(:last)').is(':hidden')) {
        $('.Sort_List tbody .down:last').hide();
        $('.Sort_List tbody .down:not(:last)').show();
    }
    else {
        $('.Sort_List tbody .down:last').hide();
        $('.Sort_List tbody .down:not(:last)').show();
    }
}
function moveUp(e) {
    const currentItem = $(e.target).closest('tr');
    const currentIndex = currentItem.index();

    if (currentIndex > 0) {
        const targetIndex = currentIndex - 1;
        const prevItem = currentItem.parent().children().eq(targetIndex);

        currentItem.insertBefore(prevItem);
        updateSortValues();
        checkButtonVisibility();
    }
}
function moveDown(e) {
    const currentItem = $(e.target).closest('tr');
    const currentIndex = currentItem.index();
    const totalItems = currentItem.parent().children().length;

    if (currentIndex >= 0 && currentIndex < totalItems - 1) {
        const targetIndex = currentIndex + 1;
        const nextItem = currentItem.parent().children().eq(targetIndex);

        currentItem.insertAfter(nextItem);
        updateSortValues();
        checkButtonVisibility();
    }
}
function moveToPosition(input) {
    const $input = $(input);
    const currentItem = $input.closest('tr');
    const currentSortValue = $input.val();
    const $tbody = currentItem.parent();

    if (!isNaN(currentSortValue)) {
        const currentIndex = currentItem.index();
        const targetIndex = currentSortValue - 1;
        const totalItems = $tbody.children().length;

        if (targetIndex !== currentIndex) {
            let newIndex = targetIndex;

            if (targetIndex < currentIndex) {
                newIndex++; // Adjusting the new index if moving up
            }

            const $existingRow = $tbody.children().eq(newIndex);
            if ($existingRow.length) {
                if (targetIndex < currentIndex) {
                    currentItem.insertBefore($existingRow);
                } else {
                    currentItem.insertAfter($existingRow);
                }
            } else {
                currentItem.appendTo($tbody);
            }

            updateSortValues();
            checkButtonVisibility();
        }
    }
}
function GetSortingAjaxCommon(json, url, func) {
    $("#PageLoader").show();
    $(".Sort_List tbody").empty();
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify(json),
        dataType: "text",
        success: function (response) {
            if (response == "Session is Expired") {
                SessionMessage(true);
                $("#PageLoader").hide();
                return;
            }
            if (response !== "") {
                $(".Sort_List tbody").html(response);
                if ($(".btnSortSaveChanges").attr("onclick")) {
                    $(".btnSortSaveChanges").removeAttr("onclick");
                }
                $(".btnSortSaveChanges").attr("onclick", func);
                updateSortValues();
                checkButtonVisibility();
                upClickMove();
                downClickMove();
            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            $("#PageLoader").hide();
        },
        error: function (response) {
            $("#PageLoader").hide();
        }
    });
}
function getSortingValues() {
    const sortingValues = [];
    $('.Sort_List tbody tr').each(function () {
        const New_Sort_Value = $(this).find('#New_Sort_Value').text();
        const Sort_ID = $(this).find('#Sort_ID').text();
        const Sort_Text = $(this).find('#Sort_Text').text();
        const Old_Sort_Value = $(this).find('#Old_Sort_Value').text();
        sortingValues.push({ New_Sort_Value, Sort_ID, Sort_Text, Old_Sort_Value });
    });
    return sortingValues;
}
// Sorting Function End
// Ajax Function Start
function GetResponseAjaxCommon(ObjJson, url, callback) {
    var JsonData = JSON.stringify(ObjJson);
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=utf-8",
        data: JsonData,
        dataType: "text",
        success: function (response) {
            if (response !== "") {
                callback(JSON.parse(response));
            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            $(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        },
        error: function (response) {
            $(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        }
    });
}

function AddEditRemoveAjaxCommon(JsonData, url, successCallback, acceptJson = false, refreshgridid = undefined, callbackParams = []) {
    $.ajax({
        url: url,
        type: 'POST',
        contentType: (acceptJson ? 'application/json' : "application/json; charset=utf-8"),
        data: (acceptJson ? JSON.stringify(JsonData) : JsonData),
        dataType: (acceptJson ? "json" : "text"),
        success: function (response) {

            var res = (acceptJson ? response : JSON.parse(response));
            if (response == "Session is Expired") {
                SessionMessage(true);
                $("#PageLoader").hide();
                return;
            }
            if (res.ReturnCode === true) {
                if (successCallback && typeof successCallback === 'function') {
                    resetmodal('dynamic-modal1');

                    if (callbackParams && callbackParams.length > 0) {
                        successCallback.apply(null, callbackParams);
                        toastr.success(res.ReturnText);
                    } else {
                        successCallback();
                        toastr.success(res.ReturnText);
                    }
                }
                else {
                    resetmodal('dynamic-modal1');
                    RefreshGridData(refreshgridid);
                    toastr.success(res.ReturnText);
                }
            } else {
                toastr.error(res.ReturnText);
            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            $("#PageLoader").hide();
        },
        error: function (response) {
            $("#PageLoader").hide();
        }
    });
}
function GetAddEditModalAjaxCommon(json, url, successCallback) {
    $("#PageLoader").show();
    $('#dynamic-modal1').html('');
    var JsonData = JSON.stringify(json);
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=utf-8",
        data: JsonData,
        dataType: "text",
        success: function (response) {
            if (response == "Session is Expired") {
                SessionMessage(true);
                $("#PageLoader").hide();
                return;
            }
            if (response == "No Rights") {
                WarningMessage('No Rights', "You Don't Have Rights To Access.", true, "Ok");
                $("#PageLoader").hide();
                return;
            }
            if (response !== "") {
                $("#dynamic-modal1").html(response);
                $("#dynamic-modal1").show();
                $("button").click(function (event) {
                    event.preventDefault();
                });

                if (successCallback && typeof successCallback === 'function') {
                    successCallback();
                }

            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            //$(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        },
        error: function (response) {
            //$(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        }
    });
}
function IsActiveEditCommon(ObjJson, url, grid, ID, IsActive, txt, gridid) {
    $('#modal-confirmation-message').html('');
    var active
    if (IsActive == false) {
        active = "Active"
    }
    else {
        active = "In-Active"
    }
    var message = "<h3 class='text-center'>Are you sure you want to " + active + " this " + txt + " " + ID + " ?</h3>";
    $('#modal-confirmation-message').append(message);
    $('#modal-confirmation-div').modal({
        backdrop: false
    });
    $('#modal-confirmation-yes').removeAttr('disabled');
    $('#modal-confirmation-div').modal('show');
    $('#modal-confirmation-yes').off('click').on('click', function () {
        var JsonData = JSON.stringify(ObjJson);
        AddEditRemoveAjaxCommon(JsonData, url, grid, false, gridid);
    });
}
function GetDropDownListCommonAjax(ObjJson, url, DropDown_ID) {
    $("#" + DropDown_ID).empty();
    $("#" + DropDown_ID).append($('<option></option>').attr('value', "").text("[Select Option]"));
    var JsonData = JSON.stringify(ObjJson);
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=utf-8",
        data: JsonData,
        dataType: "text",
        success: function (response) {
            if (response !== "") {
                const Objres = JSON.parse(response);
                $.each(Objres, function (index, option) {
                    $("#" + DropDown_ID).append($('<option></option>').attr('value', option.code).text(option.name));
                });
            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            $(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        },
        error: function (response) {
            $(this_).removeAttr("disabled")
            $("#PageLoader").hide();
        }
    });
}
function GetTreeViewAjaxCommon(json, url, htmlFunc, onclickFunc, modelID, buttonID, isCompare = false) {
    $("#PageLoader").show();
    $("." + modelID).empty();
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify(json),
        dataType: "text",
        success: function (response) {
            if (response == "Session is Expired") {
                SessionMessage(true);
                $("#PageLoader").hide();
                return;
            }
            if (response !== "") {
                var result = JSON.parse(response);
                $("#" + modelID).html(htmlFunc(result, isCompare));
                $("#" + buttonID).attr("onclick", onclickFunc);
            }
            $("#PageLoader").hide();
        },
        failure: function (response) {
            $("#PageLoader").hide();
        },
        error: function (response) {
            $("#PageLoader").hide();
        }
    });
}
var customoptionslist = [];
function GetGridDataSourceAjaxCommon(id, pageSize, url, serverFiltering, serverSorting, serverPaging, fieldstype, isCustomFilterExists, isSpecificFilterExists, pageloaderid = 'PageLoader', detailTemplateId = 0, successCallback = undefined) {
    $("#" + pageloaderid).show();
    var _griddatasource = new kendo.data.DataSource({
        transport: {
            read: function (option) {
                var customoptions = new Object();
                var isexistscustomoptions = false;
                if (customoptionslist.length > 0) {
                    for (var i = 0; i <= customoptionslist.length - 1; i++) {
                        if (customoptionslist[i].id == id) {
                            customoptions.id = id;
                            customoptions.option = option;
                            customoptionslist[i] = customoptions;
                            isexistscustomoptions = true;
                            break;
                        }
                    }
                }
                if (isexistscustomoptions == false) {
                    customoptions.id = id;
                    customoptions.option = option;
                    customoptionslist.push(customoptions);
                }

                try {
                    SetGlobalOption(id, option);
                    $("#SellectALL").prop('checked', false);
                }
                catch {

                }
                
                var getData = GetData(id, option, isCustomFilterExists, isSpecificFilterExists, fieldstype);
                var requestDataForDetailsTemplate = null; // Define requestDataForDetailsTemplate outside of the if block

                if (detailTemplateId > 0) {
                    requestDataForDetailsTemplate = {
                        id: detailTemplateId,
                        ReportParams: JSON.parse(getData)
                    };
                }
                $.ajax({
                    url: url,
                    dataType: 'json',
                    type: 'POST',
                    data: requestDataForDetailsTemplate !== null ? JSON.stringify(requestDataForDetailsTemplate) : getData,
                    cache: true,
                    contentType: "application/json",
                    success: function (result) {
                        if (successCallback && typeof successCallback === 'function') {
                            successCallback(result);
                        }
                        option.success(result);
                    },
                    error: function (result) {

                    },
                    complete: function (result) {

                    }
                });
            }
        },
        serverFiltering: serverFiltering,
        serverSorting: serverSorting,
        serverPaging: serverPaging,
        pageSize: pageSize,
        schema: {
            data: "ResultData",
            total: "TotalRowCount",
            model: {
                fields: fieldstype
            }
        },
        iscustomfilterexists: isCustomFilterExists,
        isspecificfilterexists: isSpecificFilterExists,
    });
    return _griddatasource
}
function KendoGridLoadCommon(pageSize, grid, url, columns, fieldstype, serverFiltering, serverSorting, serverPaging) {
    $("#PageLoader").show();
    $("#" + grid).empty();
    var _griddatasource = GetGridDataSourceAjaxCommon(pageSize, url, serverFiltering, serverSorting, serverPaging, fieldstype);
    dataSource = _griddatasource
    $("#" + grid).kendoGrid({
        dataSource: dataSource,
        responsive: true,
        pageable: {
            alwaysVisible: true,
            refresh: true,
            pageSizes: [30, 50, 100, 500, 1000, 5000],
            messages: {
                empty: "No data found",
            }
        },
        sortable: true,
        resizable: false,
        reorderable: false,
        noRecords: true,
        filterable: {
            extra: true,
        },
        dataBound: onDataBound,
        dataBinding: function (e) {
            $("#PageLoader").show();
        },
        columns: columns,
        //columnfields
        // showinexcel: true, //optional default is based on hidden or visible true or false
        // originalfield: "", //optional default is based on field
        // excelcolumntype: ExcelColumnTypes.General, //optional default value is General
        detailInit: function (e) {
            $("#PageLoader").hide();
        }
    });
}
// Ajax Function End

const accordionItemHeaders = document.querySelectorAll(".accordion-item-header");
accordionItemHeaders.forEach(accordionItemHeader => {
    accordionItemHeader.addEventListener("click", event => {
        // Uncomment in case you only want to allow for the display of only one collapsed item at a time!

        //     const currentlyActiveAccordionItemHeader = document.querySelector(".accordion-item-header.active");
        //     if(currentlyActiveAccordionItemHeader && currentlyActiveAccordionItemHeader!==accordionItemHeader) {
        //        currentlyActiveAccordionItemHeader.classList.toggle("active");
        //        currentlyActiveAccordionItemHeader.nextElementSibling.style.maxHeight = 0;
        //      }

        accordionItemHeader.classList.toggle("active");
        const accordionItemBody = accordionItemHeader.nextElementSibling;
        if (accordionItemHeader.classList.contains("active")) {
            accordionItemBody.style.maxHeight = accordionItemBody.scrollHeight + "px";
        }
        else {
            accordionItemBody.style.maxHeight = 0;
        }
    });
});


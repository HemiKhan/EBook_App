function AddEditReportTemplateModal(GRGUID, UGRCGUID, this_) {
    $("#PageLoader").show();
    $("#dynamic-modal1").html('');

    var gridid = this_.id.split('_')[0];

    if (UGRCGUID == 'get') {
        UGRCGUID = $('#' + gridid + '_ReportTemplate').val();
    }

    var formData = new FormData();
    formData.append('GRGUID', GRGUID);
    formData.append('UGRCGUID', UGRCGUID);

    $.ajax({
        url: '/Report/GetReportTemplateModal',
        contentType: 'application/json',
        type: 'POST',
        //data: '{"GRGUID": "' + GRGUID + '", "UGRCGUID": "' + UGRCGUID + '"}',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: (function (response) {
            if (response.Value.result != "") {
                $("#dynamic-modal1").html(response.Value.result);
                $("#dynamic-modal1").show();

                $("button").click(function (event) {
                    event.preventDefault();
                });
            }
            $('#PageLoader').hide();
        }),
        error: (function (response) {
            $('#PageLoader').hide();
            alert('Error');
        })
    });
}
function DeleteReportTemplate(this_) {
    var result = confirm('Are you sure you want to delete this template?');
    if (result) {
        var gridid = this_.id.split('_')[0];
        var UGRCGUID = $('#' + gridid + '_ReportTemplate').val();

        var formData = new FormData();
        formData.append('UGRCGUID', UGRCGUID);

        $.ajax({
            url: '/Report/DeleteReportTemplate',
            contentType: 'application/json; charset=utf-8',
            type: 'POST',
            //data: '{"UGRCGUID": "' + UGRCGUID + '"}',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',
            success: (function (response) {
                alert(response.Value.ReturnText);
                if (response.Value.ReturnCode == true) {
                    window.location = window.location.pathname;
                }
                $('#PageLoader').hide();
            }),
            error: (function (response) {
                $('#PageLoader').hide();
                alert('Error');
            })
        });
    }
}
function AddUpdateReportTemplate(this_, GRL_ID, UGRTL_ID, Method = '') {
    var Name = $('#ReportName').val();
    if (Name == '') {
        return alert('Report Name is Required');
    }

    var ReportColumns = [];
    var ReportColumnsInfo = new Object();

    var listoptions = $('#ddl_sel_coulmn')[0].options;

    if (listoptions == undefined) {
        return alert('Columns Required');
    }
    else if (listoptions.length == 0) {
        return alert('Columns Required');
    }
    else {
        $("#PageLoader").show();

        var SortPosition = 1;
        for (var i = 0; i <= listoptions.length - 1; i++) {
            ReportColumnsInfo = new Object();
            ReportColumnsInfo.GRC_ID = parseInt(listoptions[i].value);
            ReportColumnsInfo.SortPosition = SortPosition;
            ReportColumns.push(ReportColumnsInfo);
            SortPosition += 1;
        }
    }

    var formData = new FormData();
    formData.append('GRL_ID', GRL_ID);
    formData.append('UGRTL_ID', UGRTL_ID);
    formData.append('Name', Name);
    formData.append('pJson', JSON.stringify(ReportColumns));

    $.ajax({
        url: '/Report/AddUpdateReportTemplate',
        contentType: 'application/json; charset=utf-8',
        type: 'POST',
        //data: '{"GRL_ID": "' + GRL_ID + '", "UGRTL_ID": "' + UGRTL_ID + '", "Name": "' + Name + '", "pJson": ' + JSON.stringify(ReportColumns) + '}',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: (function (response) {
            if (response.Value.ReturnCode == false) {
                alert(response.Value.ReturnText);
            }
            else {
                window.location = window.location.pathname + '?ID=' + response.Value.GUID_ + (Method == '' ? "" : "Method=" + Method);
            }
            resetmodal('dynamic-modal1');
            $('#PageLoader').hide();
        }),
        error: (function (response) {
            $('#PageLoader').hide();
            alert('Error');
        })
    });
}

function SelectReportTemplate(this_) {
    $("#PageLoader").show();
    if ($('#' + this_.id).val() == "") {
        window.location = window.location.pathname;
    }
    else {
        window.location = window.location.pathname + '?ID=' + $('#' + this_.id).val();
    }
}

function AddColumn() {
    var totalselected = $("#ddl_a_coulmn option:selected").length;
    for (i = 0; i <= totalselected - 1; i++) {
        var val = $("#ddl_a_coulmn option:selected")[0].value;
        var text = $("#ddl_a_coulmn option:selected")[0].label;
        if (val != undefined) {
            var newOption = $('<option value="' + val + '">' + text + '</option>');
            $('#ddl_sel_coulmn').append(newOption);
            $("#ddl_a_coulmn option[value='" + val + "']").remove();
        }
    }
}

function RemoveColumn() {
    var totalselected = $("#ddl_sel_coulmn option:selected").length;
    for (i = 0; i <= totalselected - 1; i++) {
        var val = $("#ddl_sel_coulmn option:selected")[0].value;
        var text = $("#ddl_sel_coulmn option:selected")[0].label;
        if (val != undefined) {
            var canremoved = $("#ddl_sel_coulmn option[value='" + val + "']").attr("canremoved");
            canremoved = (canremoved == undefined ? "true" : canremoved).toString().toLowerCase();
            canremoved = (canremoved == "true" ? true : false);
            if (canremoved == false) {
                alert('Can not Removed this Column ' + '*' + text + '*')
            }
            else {
                var newOption = $('<option value="' + val + '">' + text + '</option>');
                $('#ddl_a_coulmn').append(newOption);
                $("#ddl_sel_coulmn option[value='" + val + "']").remove();
            }
        }
    }
}

function ColumnUp() {
    $('#ddl_sel_coulmn option:selected').each(function () {
        $(this).insertBefore($(this).prev());
    });
}

function ColumnDown() {
    var selectedOptions = $('#ddl_sel_coulmn option:selected').get().reverse();
    $.each(selectedOptions, function (index, option) {
        $(option).insertAfter($(option).next());
    });
}
var sessionconnection;
var srUserName = document.getElementById('hiddenusername').getAttribute('data-viewbag-value');
var srId = document.getElementById('hiddensid').getAttribute('data-viewbag-value');
var srLastIsSessionExpired = undefined;

function startConnection() {
    sessionconnection = new signalR.HubConnectionBuilder()
        .withUrl("/sessionHub")
        .build();

    sessionconnection.start().then(function () {
        console.log("Connection established.");
    }).catch(function (err) {
        return console.error(err.toString());
    });

    sessionconnection.on("SessionExpired" + srUserName + srId, function (IsSessionExpired) {
        srLastIsSessionExpired = IsSessionExpired;
    });

}

function stopConnection() {
    if (sessionconnection) {
        sessionconnection.stop().then(function () {
            console.log("Connection stopped.");
        }).catch(function (err) {
            return console.error(err.toString());
        });
    }
}

// Function to handle visibility change
function handleVisibilityChange() {
    if (document.visibilityState === "hidden") {
        // Document is hidden (user switched tabs or minimized window)
        //stopConnection();
    } else {
        // Document is visible (user returned to the tab)
        //startConnection();
        if (srLastIsSessionExpired) {
            SessionMessage(true);
            return;
            //stopConnection();
            //window.location = '/Account/Login?RedirectURL=' + window.location.pathname;
        }
    }
}

function OpenLoginPage(this_) {
    window.open('/Account/Login', '_blank');
    sessionconnection.on("ReLogin" + srUserName + srId, function (IsSessionExpired) {
        srLastIsSessionExpired = IsSessionExpired;
        SessionMessage(false);
    });
}

// Listen for visibility change events
document.addEventListener("visibilitychange", handleVisibilityChange);

// Start the connection when the page is loaded
startConnection();

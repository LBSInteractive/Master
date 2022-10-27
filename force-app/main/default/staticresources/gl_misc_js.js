// Define currying function
//var bind = Function.prototype.call.bind(Function.prototype.bind); Causes problems with IE8

//EASFP-46: Add logging+
var _log = Log ? Log.log : console.log; 

function getURLParam(strParamName, strDefault) {
    var strReturn = strDefault;
    //var strHref = document.referrer;
    var strHref = sessionStorage.getItem('refUrl')  

    //EASFP-46: Fix exception if redirectPage is not invoked+ 
	if (strHref !== null) {
        if (strHref.indexOf("?") > -1) {
            var strQueryString = strHref.substr(strHref.indexOf("?")).toLowerCase();
            var aQueryString = strQueryString.split("&");
            for (var iParam = 0; iParam < aQueryString.length; iParam++) {
                if (aQueryString[iParam].indexOf(strParamName + "=") > -1) {
                    var aParam = aQueryString[iParam].split("=");
                    strReturn = aParam[1];
                    break;
                }
            }
        }
    //EASFP-46: Fix exception if redirectPage is not invoked+ +
    } else {
        _log("getURLParam: Salesforce not initialized via Genesys redirect page, URL query string parameters are not available");
    }
    //EASFP-46: Fix exception if redirectPage is not invoked-- 
    return strReturn;
}


////////////////////////////////////////////////////////////////////////////////////////
// Cookie Operations
////////////////////////////////////////////////////////////////////////////////////////

/* Commented the cookies part as it is not used anywhere and it raises a Unprotected cookie vulnerabilty issue in checkmarx -- on 15/04/20
function createCookie(name, value, days) {
    if (days) {
        var date  = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    }
    else var expires = "";
    document. cookie = name + "=" + value + expires + "; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    //return null;
    return 0;
}

function eraseCookie(name) {
    createCookie(name, "", -1);
}
*/
function applyZoom() {
    var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');
    meta.setAttribute('content', 'width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no');
    document.getElementsByTagName('head')[0].appendChild(meta);
}

function applyWikiStyle() {
    var styleTag = document.createElement('style');
    styleTag.textContent = 'div#content {border-top:0px} \
                            div.header {display:none} \
                            ul#page-actions.hlist {display:none} \
                            a.new {pointer-events:none} \
                            div.toc-mobile.view-border-box {display:none} \
                            a.mw-ui-icon.mw-ui-icon-element.mw-ui-icon-edit-enabled.edit-page.icon-32px {display:none} \
                            div#page-secondary-actions {display:none} \
                            div#footer {display:none}';
    document.documentElement.appendChild(styleTag);
}

function applyOfflineStyle() {
    var styleTag = document.createElement('style');
    styleTag.textContent = 'html {-webkit-text-size-adjust:100%;overflow-x:hidden} \
                            body {font-family:Helvetica Neue;padding-right:10px;padding-left:10px;line-height:1.65em;overflow-x:hidden} \
                            table.metadata {display:none} \
                            table#climate_table {border-collapse:collapse;float:none !important;margin-left:0 !important;margin-right:0 !important;overflow-y:hidden;overflow-x:auto;display:block;width:100% !important} \
                            div.thumb {display:none} \
                            span.mw-mf-image-replacement {display:none} \
                            span.mw-editsection {display:none}';
    document.documentElement.appendChild(styleTag);
    
    var a = document.getElementsByTagName('a');
    for (var i = 0; i < a.length; i++) {
        a[i].removeAttribute('href');
    }
}

function getHeaders() {
    var h2 = document.getElementsByTagName('h2');
    var headers = [];
    
    for (var i = 0; i < h2.length; i++) {
        var headline = h2[i].querySelector('span.mw-headline');
        if (headline) {
            var id = headline.id;
            var title = headline.textContent;
            if (id && title) {
                headers.push({'id': id, 'title': title});
            }
        }
    }
    
    return headers;
}

function getIsWikiHost() {
    var org = 'org';
    var domains = ['wikivoyage', 'wikipedia', 'wikimedia', 'wikimediafoundation'];
    
    var hostnameComponents = window.location.hostname.split('.');
    var length = hostnameComponents.length;
    var last = length - 1;
    var secondToLast = length - 2;
    
    if (last >= 0 && secondToLast >= 0) {
        var hostnameOrg = hostnameComponents[last].toLowerCase();
        var hostnameDomain = hostnameComponents[secondToLast].toLowerCase();
        
        if (hostnameOrg === org && domains.indexOf(hostnameDomain) >= 0) {
            return true
        }
    }
    
    return false;
}

function postHeaders() {
    var headers = getHeaders();
    webkit.messageHandlers.didGetHeaders.postMessage(headers);
}

function postIsWikiHost() {
    var isWikiHost = getIsWikiHost();
    webkit.messageHandlers.didGetIsWikiHost.postMessage(isWikiHost);
}

// Everytime the page is shown post headers and host status
window.onpageshow = function() {
    postIsWikiHost();
    postHeaders();
};
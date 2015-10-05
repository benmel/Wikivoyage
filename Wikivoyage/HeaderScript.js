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
    var domains = ['wikivoyage', 'wikipedia', 'wikimedia'];
    
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
    webkit.messageHandlers.didIsWikiHost.postMessage(isWikiHost);
}

window.onpageshow = function() {
    postHeaders();
    postIsWikiHost();
}
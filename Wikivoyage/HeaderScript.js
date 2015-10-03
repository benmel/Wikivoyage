var h2 = document.getElementsByTagName('h2');
var headings = []

for (var i = 0; i < h2.length; i++) {
    var headline = h2[i].querySelector('span.mw-headline');
    if (headline) {
        var id = headline.id
        var title = headline.textContent;
        if (id && title) {
            headings.push({"id": id, "title": title});
        }
    }
}

webkit.messageHandlers.didGetHeadings.postMessage(headings);
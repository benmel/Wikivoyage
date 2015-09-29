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
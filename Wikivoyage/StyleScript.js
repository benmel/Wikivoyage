var styleTag = document.createElement('style');
styleTag.textContent = 'div#content {border-top:0px;} \
                        div.header {display:none;} \
                        div.last-modified-bar.view-border-box.pre-content.post-content {display:none;} \
                        ul#page-actions.hlist {display:none;} \
                        a.new {pointer-events:none;} \
                        div.toc-mobile.view-border-box {display:none;} \
                        a.mw-ui-icon.mw-ui-icon-element.mw-ui-icon-edit-enabled.edit-page.icon-32px {display:none;} \
                        table.article-status {display: none !important} \
                        div#page-secondary-actions {display:none} \
                        div#footer {display:none';
document.documentElement.appendChild(styleTag);
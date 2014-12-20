import bb.cascades 1.2
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart
import "global.js" as Global

NavigationPane {
    id: tabNav
    property alias busy: showPage.busy
    property alias whichPage: showPage.whichPage
    property variant theModel: showPage.theModel

    
    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }
    
    onPushTransitionEnded: {
        if (page.objectName == 'commentPage') {
            Tart.send('requestPage', {
                    source: page.commentLink,
                    sentBy: 'commentPage',
                    askPost: page.isAsk,
                    deleteComments: "False"
            });
        }
    }
    Page {
        id: show
        titleBar: HNTitleBar {
            //            visibility: ChromeVisibility.Hidden
            id: titleBar
            text: "Reader YC - Show"
            listName: showPage.theList
            onRefreshPage: {
                if (showPage.busy != true) {
                    showPage.loading.visible = true;
                    showPage.busy = true;
                    Tart.send('requestPage', {
                            source: 'show',
                            sentBy: 'show'
                    });
                console.log("pressed")
                showPage.theModel.clear();
                refreshEnabled = ! showPage.busy;
                }
            }
        }
        
        HNTab {
            id: showPage
            onCreationCompleted: {
                Tart.register(showPage);
                titleBar.refreshEnabled = false;
            }
            
            function onAddshowStories(data) {
                
                morePage = data.moreLink;
                showPage.errorLabel.visible = false;
                var lastItem = theModel.size() - 1
                //console.log("LAST ITEM: " + lastItemType);
                if (lastItemType == 'error' || lastItemType == 'load') {
                    theModel.removeAt(lastItem)
                }
                lastItemType = 'item'
                theModel.append({
                        type: 'item',
                        title: data.story['title'],
                        domain: data.story['domain'],
                        points: data.story['score'],
                        poster: data.story['author'],
                        timePosted: data.story['time'],
                        commentCount: data.story['commentCount'],
                        articleURL: data.story['link'],
                        commentsURL: data.story['commentURL'],
                        hnid: data.story['hnid'],
                        isAsk: data.story['askPost']
                });
            showPage.busy = false;
            loading.visible = false;
            titleBar.refreshEnabled = ! showPage.busy;
            }
            
            function onShowListError(data) {
                if (theModel.isEmpty() != true) {
                    var lastItem = theModel.size() - 1
                    //console.log(lastItemType);
                    if (lastItemType == 'error' || lastItemType == 'load') {
                        theModel.removeAt(lastItem)
                    }
                    theModel.append({
                            type: 'error',
                            title: data.text
                    });
                } else {
                    errorLabel.text = data.text
                    errorLabel.visible = true;
                }
                lastItemType = 'error'
                showPage.busy = false;
                loading.visible = false;
                titleBar.refreshEnabled = ! showPage.busy;
            }
        }
    }
}
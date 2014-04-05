import bb.cascades 1.2
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart
import "global.js" as Global

NavigationPane {
    id: tabNav
    property alias whichPage: askPage.whichPage
    property alias busy: askPage.busy
    property variant theModel:askPage.theModel
    
    
    
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
        id: ask
        titleBar: HNTitleBar {
            id: titleBar
            text: "Reader YC - Ask HN"
            listName: askPage.theList
            onRefreshPage: {
                console.log("We are busy: " + busy)
                if (busy != true) {
                    askPage.loading.visible = true;
                    busy = true;
                    Tart.send('requestPage', {
                            source: 'ask',
                            sentBy: 'ask'
                        });
                    console.log("pressed")
                    askPage.theModel.clear();
                    refreshEnabled = ! askPage.busy;
                }
            }
        }
        HNTab {
            onCreationCompleted: {
                Tart.register(askPage);
                titleBar.refreshEnabled = false;
            }
            
            id: askPage
            
            function onAddaskStories(data) {
                morePage = data.moreLink;
                errorLabel.visible = false;
                var lastItem = theModel.size() - 1
                //console.log("LAST ITEM: " + lastItemType);
                if (lastItemType == 'error' || lastItemType == 'load') {
                    theModel.removeAt(lastItem)
                }
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
            lastItemType = 'item'
            busy = false;
            loading.visible = false;
            titleBar.refreshEnabled = ! busy;
            }
            
            function onAskListError(data) {
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
                busy = false;
                loading.visible = false;
                titleBar.refreshEnabled = ! busy;
            }

        }
    }
}
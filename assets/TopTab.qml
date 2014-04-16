import bb.cascades 1.2
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart
import "global.js" as Global

NavigationPane {
    id: tabNav
    property alias busy: topPage.busy
    property alias whichPage: topPage.whichPage

    
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
        id: top
        titleBar: HNTitleBar {
            //            visibility: ChromeVisibility.Hidden
            id: titleBar
            text: "Reader YC - Top Posts"
            listName: topPage.theList
            onRefreshPage: {
                if (topPage.busy != true) {
                    topPage.loading.visible = true;
                    topPage.busy = true;
                    Tart.send('requestPage', {
                            source: 'news',
                            sentBy: 'news'
                        });
                    console.log("pressed")
                    topPage.theModel.clear();
                    refreshEnabled = ! topPage.busy;
                }
            }
        }

        HNTab {
            id: topPage
            onCreationCompleted: {
                Tart.register(topPage);
                titleBar.refreshEnabled = false;
            }

            function onAddnewsStories(data) {

                morePage = data.moreLink;
                topPage.errorLabel.visible = false;
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
                topPage.busy = false;
                loading.visible = false;
                titleBar.refreshEnabled = ! topPage.busy;
            }

            function onNewsListError(data) {
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
                topPage.busy = false;
                loading.visible = false;
                titleBar.refreshEnabled = ! topPage.busy;
            }
        }
    }
}
import bb.cascades 1.2
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

NavigationPane {
    id: tabNav
    property alias whichPage: newPage.whichPage
    property alias busy: newPage.busy
    property variant theModel: newPage.theModel

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
        id: newest
        attachedObjects: [
            PostSheet {
                id: postSheet
            },
            ComponentDefinition {
                id: postAction
                ActionItem {
                    title: "Post Story"
                    imageSource: "asset:///images/icons/ic_add_story.png"
                    ActionBar.placement: ActionBarPlacement.InOverflow
                    onTriggered: {
                        onTriggered:
                        {
                            postSheet.open();
                        }
                    }
                }
            }
        ]
        titleBar: HNTitleBar {
            id: titleBar
            text: "Reader YC - Newest"
            listName: newPage.theList
            onRefreshPage: {
                console.log("We are busy: " + newPage.busy)
                if (newPage.busy != true) {
                    newPage.loading.visible = true;
                    newPage.busy = true;
                    Tart.send('requestPage', {
                            source: 'newestPage',
                            sentBy: 'newestPage'
                        });
                    console.log("pressed")
                    newPage.theModel.clear();
                    refreshEnabled = ! newPage.busy;
                }
            }
        }
        HNTab {
            onCreationCompleted: {
                Tart.register(newPage);
                titleBar.refreshEnabled = false;

            }

            id: newPage
            function onAddnewStories(data) {
                if (Global.username != "" && theModel.size() == 0) {
                    var item = postAction.createObject();
                    newest.addAction(item);
                }
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

            function onNewListError(data) {
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
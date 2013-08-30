import bb.cascades 1.0
import "tart.js" as Tart

NavigationPane {
    id: searchPage
    property string search: ""
    property string errorText: ""
    property string lastItemType: ""
    property bool busy: false
    property int start: 0

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

    function onAddSearchStories(data) {
        loading.visible = false;
        searchField.enabled = true;
        errorLabel.visible = false;
        var story = data.story;
        searchModel.append({
                type: 'item',
                title: story[0],
                poster: story[1],
                points: story[2],
                commentCount: story[3],
                timePosted: story[4],
                hnid: story[5],
                domain: story[6],
                articleURL: story[7],
                commentsURL: story[8],
                isAsk: story[9]
            });
        console.log(story[9])
        searchField.visible = true;
    }

    function onSearchError(data) {
        if (searchModel.isEmpty() != true) {
            var lastItem = searchModel.size() - 1
            console.log(lastItemType);
            if (lastItemType == 'error') {
                searchModel.removeAt(lastItem)
            }
            searchModel.append({
                    type: 'error',
                    title: data.text
                });
        } else {
            if (data.text == "<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!") {           
                errorLabel.visible = true;
            } else {
                errorLabel.visible = true;
            }
        }
        errorLabel.text = data.text
        searchField.visible = true;
        searchField.enabled = true;
        loading.visible = false;

    }
    
    function showSpacer() {
        if (errorLabel.visible == true || loading.visible == true){
            return true;
        }
        else {
            return false;
        }
    }
    
    Page {
        Container {
            HNTitleBar {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
                showButton: false
                id: titleBar
                text: "Reader|YC - Search HN"
            }
            TextField {
                topPadding: 10
                leftPadding: 19
                rightPadding: 19
                visible: true
                objectName: "searchField"
                enabled: true
                textStyle.color: Color.create("#262626")
                textStyle.fontSize: FontSize.Medium
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                input {
                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                }
                hintText: qsTr("Search Posts on HN")
                id: searchField
                input.onSubmitted: {
                    start = 0;
                    search = searchField.text;
                    searchModel.clear();
                    Tart.send('requestPage', {
                            source: searchField.text,
                            sentBy: 'searchPage',
                            startIndex: start
                        });
                    start = start + 30;
                    loading.visible = true;
                    searchField.visible = false;
                }
            }

            Container {
                id: spacer
                visible: showSpacer();
                minHeight: 200
                maxHeight: 200
            }
            Container {
                visible: errorLabel.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: errorLabel
                    text: "<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    visible: false
                }
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Container {
                    visible: loading.visible
                    ActivityIndicator {
                        id: loading
                        minHeight: 300
                        minWidth: 300
                        running: true
                        visible: false
                    }
                }
            }
            
            Container {
                Container {
                    ListView {
                        id: searchList
                        dataModel: ArrayDataModel {
                            id: searchModel
                        }
                        shortcuts: [
                            Shortcut {
                                key: "T"
                                onTriggered: {
                                    theList.scrollToPosition(0, 0x2)
                                }
                            },
                            Shortcut {
                                key: "B"
                                onTriggered: {
                                    theList.scrollToPosition(0, 0x2)
                                }
                            }
                        ]
                        function itemType(data, indexPath) {
                            if (data.type != 'error') {
                                lastItemType = 'item';
                                return 'item';
                            } else {
                                lastItemType = 'error';
                                return 'error';
                            }
                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: 'item'
                                HNPage {
                                    id: hnItem
                                    property string type: ListItemData.type
                                    postComments: ListItemData.commentCount
                                    postTitle: ListItemData.title
                                    postDomain: ListItemData.domain
                                    postUsername: ListItemData.poster
                                    postTime: ListItemData.timePosted + "| " + ListItemData.points
                                    postArticle: ListItemData.articleURL
                                    askPost: ListItemData.isAsk
                                    commentSource: ListItemData.commentsURL
                                    commentID: ListItemData.hnid
                                }
                            },
                            ListItemComponent {
                                type: 'error'
                                ErrorItem {
                                    id: errorItem
                                }
                            }
                        ]
                        onTriggered: {
                            var selectedItem = dataModel.data(indexPath);
                            console.log(selectedItem.isAsk);
                            if (selectedItem.isAsk == "true") {
                                console.log("Ask post");
                                var page = commentPage.createObject();
                                searchPage.push(page);
                                console.log(selectedItem.commentsURL)
                                page.commentLink = selectedItem.hnid;
                                page.title = selectedItem.title;
                                page.titlePoster = selectedItem.poster;
                                page.titleTime = selectedItem.timePosted + "| " + selectedItem.points
                                page.titleDomain = selectedItem.domain
                                page.isAsk = selectedItem.isAsk;
                                Tart.send('requestPage', {
                                        source: selectedItem.hnid,
                                        sentBy: 'commentPage',
                                        askPost: selectedItem.isAsk,
                                        deleteComments: "false"
                                    });
                            } else {
                                console.log('Item triggered. ' + selectedItem.articleURL);
                                var page = webPage.createObject();
                                searchPage.push(page);
                                page.htmlContent = selectedItem.articleURL;
                                page.text = selectedItem.title;
                            }
                        }
                        function pushPage(pageToPush) {
                            console.log(pageToPush)
                            var page = eval(pageToPush).createObject();
                            searchPage.push(page);
                            return page;
                        }
                        attachedObjects: [
                            ListScrollStateHandler {
                                onAtEndChanged: {
                                    if (atEnd == true && searchModel.isEmpty() == false && busy == false) {
                                        console.log('end reached!')
                                        Tart.send('requestPage', {
                                                source: search,
                                                sentBy: 'searchPage',
                                                startIndex: start
                                            });
                                        loading.visible = false;
                                        start = start + 30;
                                        searchField.enabled = false;
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
        onCreationCompleted: {
            Tart.register(searchPage)
        }
        attachedObjects: [
            ComponentDefinition {
                id: webPage
                source: "webArticle.qml"
            },
            ComponentDefinition {
                id: commentPage
                source: "CommentPage.qml"
            },
            ComponentDefinition {
                id: userPage
                source: "UserPage.qml"
            }
        ]
    }
}

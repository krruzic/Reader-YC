import bb.cascades 1.2
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

Container {
    id: hnTab
    property alias theList: theList
    property variant theModel: theModel
    property alias loading: loading
    property alias errorLabel: errorLabel
    property string whichPage: ""
    property string morePage: ""
    property string errorText: ""
    property string lastItemType: ""
    property string readerURL: "http://www.readability.com/m?url="
    property bool busy: false

    onCreationCompleted: {
        ActionBarAutoHideBehavior = ActionBarAutoHideBehavior.HideOnScroll;
        Tart.register(hnTab);
    }

    layout: DockLayout {
    }
    background: Color.White
    horizontalAlignment: HorizontalAlignment.Center
    verticalAlignment: VerticalAlignment.Center
    Container {
        visible: errorLabel.visible
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        Label {
            id: errorLabel
            text: "<b><span style='color:#ff8e00'>Error getting stories</span></b>\nCheck your connection and try again!"
            textStyle.fontSize: FontSize.PointValue
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSizeValue: 9
            textStyle.color: Color.DarkGray
            textFormat: TextFormat.Html
            multiline: true
            visible: false
            textStyle.base: lightStyle.style
        }
    }
    Container {
        visible: loading.visible
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        ActivityIndicator {
            id: loading
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            minHeight: 300
            minWidth: 300
            running: true
            visible: true
        }
    }
    Container {
        ListView {
            scrollRole: ScrollRole.Main
            id: theList
            dataModel: ArrayDataModel {
                id: theModel
            }
            function itemType(data, indexPath) {
                return data.type
            }
            listItemComponents: [
                ListItemComponent {
                    type: 'item'
                    HNItem {
                        id: hnItem
                        property string type: ListItemData.type
                        postComments: ListItemData.commentCount
                        postTitle: ListItemData.title
                        postDomain: ListItemData.domain
                        postUsername: ListItemData.poster
                        postArticle: ListItemData.articleURL
                        askPost: ListItemData.isAsk
                        commentSource: ListItemData.commentsURL
                        commentID: ListItemData.hnid
                    }
                    function openComments(ListItemData) {
                        var page = commentPage.createObject();
                        page.commentLink = ListItemData.hnid;
                        page.title = ListItemData.title;
                        page.titlePoster = ListItemData.poster;
                        page.titleTime = ListItemData.timePosted;
                        page.titleDomain = ListItemData.domain;
                        page.isAsk = ListItemData.isAsk;
                        page.articleLink = ListItemData.articleURL;
                        page.titleComments = ListItemData.commentCount;
                        page.titlePoints = ListItemData.points;
                        tabNav.push(page);
                    }
                    function openArticle(ListItemData) {
                        var page = webPage.createObject();
                        page.htmlContent = ListItemData.articleURL;
                        if (settings.readerMode == true && ListItemData.isAsk != "true")
                            page.htmlContent = readerURL + ListItemData.articleURL;
                        page.text = ListItemData.title;
                        tabNav.push(page);
                    }

                },
                ListItemComponent {
                    type: 'error'
                    Container {
                        layout: DockLayout {

                        }
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        ErrorItem {
                            id: errorItem
                            title: ListItemData.title
                        }
                    }
                },
                ListItemComponent {
                    type: 'load'
                    LoadItem {
                        id: loadItem
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        property string type: ListItemData.type
                    }
                }
            ]
            onTriggered: {
                if (dataModel.data(indexPath).type != 'item') {
                    return;
                }

                var selectedItem = dataModel.data(indexPath);
                if (settings.openInBrowser == true) {
                    // will auto-invoke after re-arming
                    console.log("OPENING IN BROWSER");
                    linkInvocation.query.uri = "";
                    linkInvocation.query.uri = selectedItem.articleURL;
                    return;
                }
                if (settings.readerMode == true && selectedItem.isAsk != "true") {
                    selectedItem.articleURL = readerURL + selectedItem.articleURL;
                    console.log('Item triggered. ' + selectedItem.articleURL);
                    var page = webPage.createObject();
                    page.htmlContent = selectedItem.articleURL;
                    page.text = selectedItem.title;
                    tabNav.push(page);
                }
                console.log(selectedItem.isAsk);
                if (selectedItem.isAsk == "true") {
                    console.log("Ask post");
                    var page = commentPage.createObject();
                    console.log(selectedItem.commentsURL)
                    page.commentLink = selectedItem.hnid;
                    page.title = selectedItem.title;
                    page.titlePoster = selectedItem.poster;
                    page.titleTime = selectedItem.timePosted;
                    page.titleDomain = selectedItem.domain;
                    page.isAsk = selectedItem.isAsk;
                    page.articleLink = selectedItem.articleURL;
                    page.titleComments = selectedItem.commentCount;
                    page.titlePoints = selectedItem.points
                    tabNav.push(page);
                } else {
                    console.log('Item triggered. ' + selectedItem.articleURL);
                    var page = webPage.createObject();
                    page.htmlContent = selectedItem.articleURL;
                    page.text = selectedItem.title;
                    tabNav.push(page);
                }
                return;
            }
            attachedObjects: [
                ListScrollStateHandler {
                    onAtEndChanged: {
                        if (atEnd == true && theModel.isEmpty() == false && morePage != "" && busy == false) {
                            console.log('end reached!');
                            var lastItem = theModel.size() - 1;
                            if (lastItemType == 'error') { // Remove an error item
                                theModel.removeAt(lastItem);
                            }
                            theModel.append({
                                    type: 'load'
                                });
                            //theList.scrollToItem('load', ScrollAnimation..Smooth);
                            lastItemType = 'load';
                            Tart.send('requestPage', {
                                    source: morePage,
                                    sentBy: whichPage
                                });
                            busy = true;
                        }
                    }
                }
            ]
        }
    }
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W300
        },
        Invocation {
            id: linkInvocation
            property bool auto_trigger: false
            query {
                uri: "http://peterhansen.ca"
                invokeTargetId: "sys.browser"
                onUriChanged: {
                    if (uri != "") {
                        linkInvocation.query.updateQuery();
                    }
                }
            }

            onArmed: {
                // don't auto-trigger on initial setup
                if (auto_trigger)
                    trigger("bb.action.OPEN");
                auto_trigger = true; // allow re-arming to auto-trigger
            }
        },
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
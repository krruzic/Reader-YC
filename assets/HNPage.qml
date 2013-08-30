import bb.cascades 1.0
import bb.system 1.0
import "tart.js" as Tart

Container {
    id: hnPage
    property string postArticle: ''
    property string askPost: ''
    property string commentSource: ''
    property string postComments: ''
    property string commentID: ''
    property alias postTitle: labelPostTitle.text
    property alias postDomain: labelPostDomain.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text
    property variant selectedItem: hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath)
    //property variant backgroundVar: unreadBackground.imagePaint
        
    onCreationCompleted: {
        Tart.register(hnPage)
    }
    contextActions: [
        ActionSet {
            title: ListItemData.title
            subtitle: ListItemData.poster + " | " + ListItemData.points
            ActionItem {
                imageSource: "asset:///images/icons/ic_comments.png"
                title: "Open Comments"
                enabled: if (hnPage.selectedItem.hnid != '-1') {
                    true
                }
                onTriggered: {
                    console.log("Pushing comments page");
                    var page = hnItem.ListItem.view.pushPage('commentPage');
                    page.title = hnPage.selectedItem.title;
                    page.titlePoster = hnPage.selectedItem.poster;
                    page.titleTime = hnPage.selectedItem.timePosted + "| " + hnPage.selectedItem.points;
                    page.titleDomain = hnPage.selectedItem.domain;
                    page.commentLink = hnPage.selectedItem.hnid;
                    page.articleLink = hnPage.selectedItem.articleURL;
                    page.isAsk = hnPage.selectedItem.isAsk;
//                    Tart.send('requestPage', {
//                            source: hnPage.selectedItem.hnid,
//                            sentBy: 'commentPage',
//                            askPost: hnPage.selectedItem.isAsk,
//                            deleteComments: "False"
//                        });
                }
            }
            ActionItem {
                title: "View Article"
                imageSource: "asset:///images/icons/ic_article.png"
                enabled: if (hnPage.selectedItem.articleURL != '') {
                    true
                }
                onTriggered: {
                    console.log("Pushing Article page");
                    console.log(selectedItem.title);
                    var page = hnItem.ListItem.view.pushPage('webPage');
                    page.text = hnPage.selectedItem.title;
                    page.htmlContent = selectedItem.articleURL;
                }
            }
            InvokeActionItem {
                ActionBar.placement: ActionBarPlacement.OnBar
                title: "Share"
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                onTriggered: {
                    data = hnPage.selectedItem.title + "\n" + hnPage.selectedItem.articleURL + "\nShared using Reader|YC "
                }
            }
            ActionItem {
                title: "Favourite Article"
                imageSource: "asset:///images/icons/ic_star_add.png"
                onTriggered: {
                    var date = new Date();
                    var formattedDate = Qt.formatDateTime(date, "dd-MM-yyyy"); //to format date
                    var articleDetails = [ hnPage.selectedItem.title, hnPage.selectedItem.articleURL, String(formattedDate),
                        hnPage.selectedItem.poster, hnPage.selectedItem.commentCount, hnPage.selectedItem.isAsk,
                        hnPage.selectedItem.domain, hnPage.selectedItem.points, hnPage.selectedItem.hnid ];

                    Tart.send('saveArticle', {
                            article: articleDetails
                        });
                }
            }
            ActionItem {
                title: "Copy Article Link"
                imageSource: "asset:///images/icons/ic_copy_link.png"
                onTriggered: {
                    Tart.send('copyLink', {
                            articleLink: hnPage.selectedItem.articleURL
                        });
                }
            }
        }
    ]
    layout: DockLayout {

    }

    property int padding: 19
    topPadding: 5
    bottomPadding: 0
    leftPadding: padding
    rightPadding: padding

    function setHighlight(highlighted) {
        if (highlighted) {
            highlightContainer.opacity = 0.9;
        } else {
            highlightContainer.opacity = 0.0;
        }
    }
    function onSaveResult(data) {
        saveResultToast.body = data.text;
        saveResultToast.cancel();
        saveResultToast.show();
    }

    function onCopyResult(data) {
        copyResultToast.body = data.text;
        copyResultToast.cancel();
        copyResultToast.show();
    }

    function onReadState(data) {
        if (data.state == "unread") { 	
            console.log("UNREAD");
            mainContainer.background = unreadBackground.imagePaint
        } else {
            console.log("READ");
            mainContainer.background = readBackground.imagePaint
        }
    }
    // Highlight function for the highlight Container

    // Connect the onActivedChanged signal to the highlight function
    ListItem.onActivationChanged: {
        setHighlight(ListItem.active);
    }

    // Connect the onSelectedChanged signal to the highlight function
    ListItem.onSelectionChanged: {
        setHighlight(ListItem.selected);
    }

    Container {
        visible: true
        id: mainContainer
        preferredWidth: 730
        preferredHeight: 155
        //maxHeight: 155
        maxWidth: 730
        background: unreadBackground.imagePaint
        Container {
            topPadding: 5
            leftPadding: 10
            rightPadding: 0
            rightMargin: 0
            bottomMargin: 0
            bottomPadding: 20

            Label {
                id: labelPostTitle
                preferredWidth: 680
                text: "Billing Incident Update, from the makers of cheese, testing this out"
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 7
                bottomMargin: 1
                multiline: true
                textStyle.color: Color.Black
                autoSize.maxLineCount: 2
                textFormat: TextFormat.Html
            }
            Container {
                topMargin: 0
                leftMargin: 1
                rightPadding: 15
                clipContentToBounds: false
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: labelPostDomain
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    topMargin: 1
                    bottomMargin: 1
                    translationX: 2
                    minWidth: 400
                    maxWidth: 440
                    text: "http://www.dailymail.com/"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.create("#ff69696c")
                    textStyle.fontStyle: FontStyle.Italic
                }

                Label {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    text: postComments + " comments"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
            Container {
                topMargin: 10
                leftMargin: 1
                rightPadding: 15
                translationY: -10
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: labelUsername
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    text: "username"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.create("#fe8515")
                    horizontalAlignment: HorizontalAlignment.Left
                    textStyle.textAlign: TextAlign.Left
                }

                Label {
                    id: labelTimePosted
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 2
                    }
                    text: "some comments | some points"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
        }
    }
    ImageView {
        id: highlightContainer
        imageSource: "asset:///images/listHighlight.amd"
        preferredWidth: 730
        preferredHeight: 155
        maxHeight: 155
        maxWidth: 730
        opacity: 0
    }
    attachedObjects: [
        ImagePaintDefinition {
            id: unreadBackground
            imageSource: "asset:///images/unread.amd"
        },
        ImagePaintDefinition {
            id: readBackground
            imageSource: "asset:///images/read.amd"
        },
        SystemToast {
            id: saveResultToast
            body: ""
        },
        SystemToast {
            id: copyResultToast
            body: ""
        }
    ]
}
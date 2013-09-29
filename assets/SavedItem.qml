import bb.cascades 1.0
import bb.system 1.0
//import "tart.js" as Tart

Container {
    id: saveItem
    property string postArticle: ''
    property string askPost: ''
    property string commentSource: ''
    property string postComments: ''
    property string commentID: ''
    property alias postTitle: labelPostTitle.text
    property alias postDomain: labelPostDomain.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text

    onCreationCompleted: {
        Tart.register(saveItem)
    }
    contextActions: [
        ActionSet {
            title: ListItemData.title
            subtitle: ListItemData.poster + " | " + ListItemData.points
            ActionItem {
                imageSource: "asset:///images/icons/ic_comments.png"
                title: "Open Comments"
                enabled: if (saveItem.selectedItem.hnid != '-1') {
                    true
                }
                onTriggered: {
                    console.log("Pushing comments page");
                    saveItem.ListItem.component.openComments(ListItemData);
                }
            }
            ActionItem {
                title: "View Article"
                imageSource: "asset:///images/icons/ic_article.png"
                enabled: if (saveItem.ListItemData.articleURL != '') {
                    true
                }
                onTriggered: {
                    console.log("Pushing Article page");
                    saveItem.ListItem.component.openArticle(ListItemData);
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
                    data = ListItemData.title + "\n" + ListItemData.articleURL + "\nShared using Reader|YC "
                }
            }
            InvokeActionItem {
                title: "Open in Browser"
                imageSource: "asset:///images/icons/ic_open_link.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                id: browserQuery
                //query.mimeType: "text/plain"
                query.invokeActionId: "bb.action.OPEN"
                query.uri: ListItemData.articleURL
                query.invokeTargetId: "sys.browser"
                query.onQueryChanged: {
                    browserQuery.query.updateQuery();
                }
            }
            ActionItem {
                title: "Copy Article Link"
                imageSource: "asset:///images/icons/ic_copy_link.png"
                onTriggered: {
                    Tart.send('copyLink', {
                            articleLink: ListItemData.articleURL
                        });
                }
            }
            DeleteActionItem {
                title: "Remove from Favourites"
                onTriggered: {
                    Tart.send('deleteArticle', {
                            hnid: ListItemData.hnid,
                            selected: saveItem.ListItem.indexInSection
                        });
                }
            }
        }
    ]
    layout: DockLayout {

    }

    property int padding: 10
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

    function onCopyResult(data) {
        copyResultToast.body = data.text;
        copyResultToast.show();
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
    attachedObjects: [
        ImagePaintDefinition {
            id: unreadBackground
            imageSource: "asset:///images/unread.amd"
        },
        SystemToast {
            id: copyResultToast
            body: ""
        }
    ]
    Container {
        visible: true
        id: mainContainer
        background: unreadBackground.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        attachedObjects: [
            LayoutUpdateHandler {
                id: mainDimensions
            }
        ]
        Container {
            topPadding: 5
            leftPadding: 10
            rightPadding: 10
            rightMargin: 0
            bottomMargin: 0
            bottomPadding: 20
            horizontalAlignment: HorizontalAlignment.Fill
            Label {
                id: labelPostTitle
                verticalAlignment: VerticalAlignment.Top
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
                verticalAlignment: VerticalAlignment.Center
                bottomMargin: 0
                topMargin: 0
                //minWidth: mainDimensions.layoutFrame.width
                //horizontalAlignment: HorizontalAlignment.Fill
                clipContentToBounds: false
                layout: DockLayout {
                }
                Label {
                    id: labelPostDomain
                    horizontalAlignment: HorizontalAlignment.Left
                    text: "http://www.dailymail.com/"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    textStyle.color: Color.create("#ff69696c")
                    textStyle.fontStyle: FontStyle.Italic
                }
                Divider {
                    opacity: 0
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Label {
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
                bottomMargin: 0
                topMargin: 0
                verticalAlignment: VerticalAlignment.Bottom
                //horizontalAlignment: HorizontalAlignment.Fill
                layout: DockLayout {
                }
                Label {
                    id: labelUsername
                    text: "username"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.create("#fe8515")
                    horizontalAlignment: HorizontalAlignment.Left
                    textStyle.textAlign: TextAlign.Left
                }
                Divider {
                    opacity: 0
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Label {
                    id: labelTimePosted
                    text: "some comments | some points"
                    multiline: false
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
            Container {
                minHeight: 10
            }
        }
    }
    ImageView {
        id: highlightContainer
        imageSource: "asset:///images/listHighlight.amd"
        preferredWidth: mainDimensions.layoutFrame.width
        preferredHeight: mainDimensions.layoutFrame.height
        opacity: 0
    }
}
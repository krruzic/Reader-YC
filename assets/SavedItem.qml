import bb.cascades 1.0
import bb.system 1.0
import "tart.js" as Tart

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
    property variant selectedItem: hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath)

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
                    console.log(saveItem.selectedItem.title);
                    var page = hnItem.ListItem.view.pushPage('commentPage');
                    page.title = saveItem.selectedItem.title;
                    page.titlePoster = saveItem.selectedItem.poster;
                    page.titleTime = "Saved on: " + saveItem.selectedItem.timePosted
                    page.titleDomain = saveItem.selectedItem.domain;
                    page.commentLink = saveItem.selectedItem.hnid;
                    page.articleLink = saveItem.selectedItem.articleURL;
                    page.isAsk = selectedItem.isAsk;
                    Tart.send('requestPage', {
                            source: saveItem.selectedItem.hnid,
                            sentBy: 'commentPage',
                            askPost: saveItem.selectedItem.isAsk,
                            deleteComments: "False"
                        });
                }
            }
            ActionItem {
                title: "View Article"
                imageSource: "asset:///images/icons/ic_article.png"
                enabled: if (saveItem.selectedItem.articleURL != '') {
                    true
                }
                onTriggered: {
                    console.log("Pushing Article page");
                    console.log(selectedItem.title);
                    var page = hnItem.ListItem.view.pushPage('webPage');
                    page.text = saveItem.selectedItem.title;
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
                    data = saveItem.selectedItem.title + "\n" + saveItem.selectedItem.articleURL + "\nShared using Reader|YC "
                }
            }
            ActionItem {
                title: "Copy Article Link"
                imageSource: "asset:///images/icons/ic_copy_link.png"
                onTriggered: {
                    Tart.send('copyLink', {
                            articleLink: saveItem.selectedItem.articleURL
                        });
                }
            }
            DeleteActionItem {
                title: "Un-favourite"
                onTriggered: {
                    Tart.send('deleteArticle', {
                            hnid: saveItem.selectedItem.hnid,
                            selected: hnItem.ListItem.indexInSection
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
            id: itemBackground
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
        preferredWidth: 730
        preferredHeight: 155
        maxHeight: 155
        maxWidth: 730
        background: itemBackground.imagePaint
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Container {
            topPadding: 5
            leftPadding: 10
            rightPadding: 0
            rightMargin: 0
            bottomMargin: 0
            bottomPadding: 20

            Label {
                rightMargin: 42
                id: labelPostTitle
                preferredWidth: 680
                maxWidth: 680
                text: "Billing Incident Update, from the makers of cheese"
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 7
                textFormat: TextFormat.Html
                bottomMargin: 1
                textStyle.color: Color.Black
            }
            Container {
                translationY: -5
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
}
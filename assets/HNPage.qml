import bb.cascades 1.0
import "tart.js" as Tart

Container {
    id: hnPage
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
                onTriggered: {
                    console.log("Pushing comments page");
                    var selectedItem = hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath);
                    console.log(selectedItem.title);
                    var page = hnItem.ListItem.view.pushPage('commentPage');
                    page.title = selectedItem.title;
                    page.titlePoster = selectedItem.poster;
                    page.titleTime = selectedItem.timePosted + "| " + selectedItem.points;
                    page.titleDomain = selectedItem.domain;
                    page.commentLink = selectedItem.commentsURL;
                    page.articleLink = selectedItem.articleURL;

                    console.log(selectedItem.isAsk);
                    Tart.send('requestComments', {
                            source: selectedItem.hnid,
                            askPost: selectedItem.isAsk
                    });
                }
            }
            ActionItem {
                title: "View Article"
                imageSource: "asset:///images/icons/ic_article.png"
                onTriggered: {
                    console.log("Pushing Article page");
                    var selectedItem = hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath);
                    console.log(selectedItem.title);
                    var page = hnItem.ListItem.view.pushPage('webPage');
                    page.text = selectedItem.title;
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
                    var selectedItem = hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath);
                    data = selectedItem.title + "\n" + selectedItem.articleURL + "\n" + " Shared using Reader|YC "
                }
            }
            InvokeActionItem {
                title: "Open in Browser"
                imageSource: "asset:///images/icons/ic_open_link.png"
                id: browserQuery
                query {
                    invokeTargetId: "sys.browser"
                    invokeActionId: "bb.action.OPEN"
                    uri: ""
                }
                onTriggered: {
                    var selectedItem = hnItem.ListItem.view.dataModel.data(hnItem.ListItem.indexPath);
                    browserQuery.query.uri = selectedItem.articleURL;
                }
            }
        }
    ]
    layout: DockLayout {

    }
    property string postArticle: ''
    property string askPost: ''
    property string commentSource: ''
    property string postComments: ''
    property string commentID: ''
    property alias postTitle: labelPostTitle.text
    property alias postDomain: labelPostDomain.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text

    property int padding: 19
    topPadding: 2
    bottomPadding: 3
    leftPadding: padding
    rightPadding: padding

    signal commentsClicked()
    function setHighlight(highlighted) {
        if (highlighted) {
            highlightContainer.opacity = 0.9;
        } else {
            highlightContainer.opacity = 0.0;
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
    attachedObjects: [
        ImagePaintDefinition {
            id: itemBackground
            imageSource: "asset:///images/full.png.amd"
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
                textStyle.fontSize: FontSize.Small
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
                        spaceQuota: 2
                    }
                    translationX: 10
                    text: "http://dailymail.co.uk/"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Left
                    textStyle.textAlign: TextAlign.Left
                }

                Label {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    text: postComments + " comments"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
            Container {
                topMargin: 10
                leftMargin: 1
                rightPadding: 15
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
                    textStyle.fontSize: FontSize.Small
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
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
        }
        //        Label {
        //            translationX: -30
        //            text: "130"
        //            textStyle.fontSize: FontSize.XSmall
        //        }
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
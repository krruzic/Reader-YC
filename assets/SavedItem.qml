import bb.cascades 1.2
import bb.system 1.2
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
    horizontalAlignment: HorizontalAlignment.Fill
    onCreationCompleted: {
        Tart.register(saveItem);
    }

    contextActions: [
        ActionSet {
            title: ListItemData.title
            subtitle: ListItemData.poster + " | " + ListItemData.points
            ActionItem {
                imageSource: "asset:///images/icons/ic_comments.png"
                title: "Open Comments"
                enabled: if (ListItemData.hnid != '-1') {
                    true
                }
                onTriggered: {
                    console.log("Pushing comments page");
                    saveItem.ListItem.component.openComments(ListItemData);
                }
            }
            ActionItem {
                title: "View Article"
                imageSource: "asset:///images/icons/ic_story.png"
                enabled: if (ListItemData.articleURL != '') {
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
                    data = ListItemData.title + "\n" + ListItemData.articleURL + "\nShared using Reader YC "
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
                title: "Favourite Article"
                imageSource: "asset:///images/icons/ic_star_add.png"
                onTriggered: {
                    var date = new Date();
                    var formattedDate = Qt.formatDateTime(date, "dd-MM-yyyy"); //to format date
                    var articleDetails = [ ListItemData.title, ListItemData.articleURL, String(formattedDate), ListItemData.poster,
                        ListItemData.commentCount, ListItemData.isAsk, ListItemData.domain, ListItemData.points,
                        ListItemData.hnid ];

                    Tart.send('saveArticle', {
                            article: articleDetails
                        });
                }
            }
            ActionItem {
                title: "Copy Article Link"
                imageSource: "asset:///images/icons/ic_copy_link.png"
                onTriggered: {
                    Tart.send('copy', {
                            articleLink: ListItemData.articleURL
                        });
                }
            }
            DeleteActionItem {
                title: 'Remove from Favourites'
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

    function setHighlight(highlighted) {
        if (highlighted) {
            mainContainer.background = Color.create("#e0e0e0")
        } else {
            mainContainer.background = Color.White
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
        attachedObjects: [
            TextStyleDefinition {
                id: lightStyle
                base: SystemDefaults.TextStyles.BodyText
                fontSize: FontSize.PointValue
                fontSizeValue: 7
                fontWeight: FontWeight.W300
            },
            LayoutUpdateHandler {
                id: mainDimensions
            }
        ]
        visible: true
        id: mainContainer
        background: Color.White
        horizontalAlignment: HorizontalAlignment.Fill

        Container {
            topPadding: 5
            leftPadding: 10
            rightPadding: 10
            rightMargin: 0
            bottomMargin: 0
            bottomPadding: 0
            horizontalAlignment: HorizontalAlignment.Fill
            Label {
                id: labelPostTitle
                verticalAlignment: VerticalAlignment.Top
                text: ListItemData.title
                bottomMargin: 1
                multiline: true
                autoSize.maxLineCount: 2
                textStyle.fontSizeValue: 7
                textStyle.base: lightStyle.style
            }
            Container {
                layout: DockLayout {
                }
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    Label {
                        topMargin: 5
                        id: labelPostDomain
                        horizontalAlignment: HorizontalAlignment.Left
                        text: ListItemData.domain
                        multiline: false
                        textStyle.color: Color.create("#ff8e00")
                        textStyle.fontStyle: FontStyle.Italic
                        textStyle.base: lightStyle.style
                        bottomMargin: 0
                    }
                    Label {
                        topMargin: 5
                        text: ListItemData.timePosted
                        id: labelTimePosted
                        textStyle.fontSizeValue: 5
                        textStyle.base: lightStyle.style
                    }
                }
                Container {
                    id: storyinfo
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
                    //background: background.imagePaint
                    rightPadding: 10
                    Container {
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        leftPadding: 4
                        ImageView {
                            rightPadding: 0
                            leftMargin: 0
                            imageSource: "asset:///images/comment.png"
                            maxHeight: 26
                            maxWidth: 26
                            translationY: 2
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Right
                        }
                        Label {
                            leftMargin: 0
                            rightMargin: 0
                            text: "<html><i>" + ListItemData.commentCount + "</i></html>"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 5
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.color: Color.create("#7e7e7e")
                            textStyle.base: lightStyle.style
                            textFormat: TextFormat.Html
                        }
                        Label {
                            leftMargin: 0
                            text: "<html><i> | ▲ </i></html>" + ListItemData.points
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 5
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.color: Color.create("#7e7e7e")
                            textStyle.base: lightStyle.style
                            textFormat: TextFormat.Html
                        }
                    }
                    Label {
                        topMargin: 0
                        textStyle.fontSizeValue: 5
                        text: ListItemData.poster
                        id: labelUsername
                        textStyle.color: Color.create("#ff8e00")
                        textStyle.base: lightStyle.style
                        horizontalAlignment: HorizontalAlignment.Right
                    }
                }
            }
            Divider {
                bottomMargin: 0
                bottomPadding: 0
            }
        }
    }
    attachedObjects: [
        SystemToast {
            id: saveResultToast
            body: ""
        },
        SystemToast {
            id: copyResultToast
            body: ""
        },
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/commentBox.png.amd"
            repeatPattern: RepeatPattern.XY
        }
    ]
}
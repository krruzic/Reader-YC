import bb.cascades 1.0
import bb.data 1.0
import "../tart.js" as Tart

Page {
    id: articlePane
    onCreationCompleted: {
        Tart.register(articlePane)
    }
    property string morePage: ""
    property string urlToPass: ""

    Container {
        background: Color.create("#fff2f2f2")
        layout: StackLayout {
        }
        Container {
            layout: AbsoluteLayout {}
            ImageView {
                imageSource: "asset:///images/HN_title.png"
                visible: true
                onTouch: {
                    theList.scrollToPosition(0, 0x2)
                }
            }
            ImageButton {
                id: refreshButton
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 600.0
                    positionY: 20.0

                }
                defaultImageSource: "asset:///images/refresh.png"
                pressedImageSource: "asset:///images/refresh.png"
                onClicked: {
                    Tart.send('requestPage', {
                            source: 'news'
                        });
                }
            }
        }

        Label {
            id: errorLabel
            text: ""
            visible: false
            multiline: true
            autoSize.maxLineCount: 2
            textStyle.fontSize: FontSize.Medium
            textStyle.fontStyle: FontStyle.Italic
            textStyle.color: Color.DarkGray
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }

        ListView {
            id: theList

            dataModel: ArrayDataModel {
                id: theModel
            }
            maxHeight: 1167.0
            layoutProperties: AbsoluteLayoutProperties {
                positionY: 113.0
            }

            listItemComponents: [
                ListItemComponent {
                    type: ''
                    HNPage {
                        postTitle: ListItemData.title
                        postDomain: ListItemData.domain
                        postUsername: ListItemData.poster
                        postTime: ListItemData.timePosted + "| " + ListItemData.points
                        postComments: ListItemData.commentCount
                        postArticle: ListItemData.articleURL
                    }
                }
            ]
            onTriggered: {
                var selectedItem = dataModel.data(indexPath);
                urlToPass = selectedItem.articleURL;
                console.log('Item triggered. ' + selectedItem.articleURL);
                var page = webPage.createObject();
                nav.push(page);
                page.htmlContent = urlToPass;
            }
            attachedObjects: [
                ListScrollStateHandler {
                    onAtEndChanged: {
                        if (atEnd == true && theModel.isEmpty() == false) {
                            console.log('end reached!')
                            Tart.send('requestPage', {
                                    source: morePage
                                });
                        }
                    }
                }
            ]
        }
    }
    function onAddStories(data) {
        var stories = data.stories;
        morePage = data.moreLink;
        console.log("Next page: " + morePage);
        for (var i = 0; i < stories.length; i ++) {
            var story = stories[i];
            theModel.append({
                    title: story[1],
                    domain: story[2],
                    points: story[3],
                    poster: story[4],
                    timePosted: story[5],
                    commentCount: story[6],
                    articleURL: story[7]
                });
        }
    }
    function onUrlError(data) {
        errorLabel.visible = true;
        errorLabel.text = data.text;
    }
}

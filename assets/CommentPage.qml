import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: commentPane

    onCreationCompleted: {
        Tart.register(commentPane);
        Tart.send('requestComments', {
                source: commentLink
            });
    }
    property string moreComments: ""
    property string commentLink: ""
    property alias title: commentHeader.titleText
    property alias titlePoster: commentHeader.posterText
    property alias titleTime: commentHeader.articleTime

    function onCommentError(data) {
        console.log(data.text)
    }

    function onAddComments(data) {
        var comments = data.comments;
        moreComments = data.moreLink;
        //refreshEnabled = true;
        for (var i = 0; i < comments.length; i ++) {
            var comment = comments[i];
            commentModel.append({
                    poster: comment[1],
                    timePosted: comment[2],
                    indent: comment[3],
                    text: comment[4]
                });
        }
    }

    Container {
        CommentHeader {
            id: commentHeader
        }
        ListView {
            id: commentList
            dataModel: ArrayDataModel {
                id: commentModel
            }
            listItemComponents: [
                ListItemComponent {
                    type: ''
                    Comment {
                        poster: ListItemData.poster
                        time: ListItemData.timePosted
                        indent: ListItemData.indent
                        text: ListItemData.text
                    }
                }
            ]
            onTriggered: {
                console.log("Comment triggered!")
            }
            //            attachedObjects: [
            //                ListScrollStateHandler {
            //                    onAtEndChanged: {
            //                        if (atEnd == true && commentModel.isEmpty() == false && moreComments != "") {
            //                            console.log('end reached!')
            //                            Tart.send('requestComments', {
            //                                    source: moreComments
            //                                });
            //                            busy = true;
            //                        }
            //                    }
            //                }
            //            ]
        }
    }
}

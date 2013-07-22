// Tabbed Pane project template
import bb.cascades 1.0
import bb.data 1.0
import "../tart.js" as Tart

Page {
    id: page
    property string morePage: ""
    signal reloadList(string file, string moreLink)
    signal refreshTriggered()
    property bool showList: true
    property bool showLoading: false

    onReloadList: {
        console.log("Loading page from Python! " + file);
        pageSource.source = file;
        morePage = moreLink;
        console.log('moreLink: ' + morePage)
        console.log('File to load: ' + pageSource.source);
        pageSource.load();
        showLoading = false;
        showList = true;
        hnList.scrollToPosition(0, 0x2)
    }

    onRefreshTriggered: {
        showLoading = true;
        showList = false;
        console.log('loading requested page: ' + pageSelector.selectedOption.text);
        Tart.send('requestPage', {
                source: pageSelector.selectedOption.text,
                forceReload: 'True'
            });
        refreshButton.enabled = true;
    }

    Container {
        ActivityIndicator {
            running: true
            visible: page.showLoading
            preferredWidth: 350
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layoutProperties: AbsoluteLayoutProperties {
                positionX: 200.0
                positionY: 440.0
            }
        }

        background: Color.create("#fff2f2f2")
        layout: AbsoluteLayout {
        }
        ImageView {
            imageSource: "asset:///images/HN_title.png"
            visible: true
            onTouch: {
                hnList.scrollToPosition(0, 0x2)
            }
        }
        ImageButton {
            id: refreshButton
            layoutProperties: AbsoluteLayoutProperties {
                positionY: 14.0
                positionX: 660.0
            }
            defaultImageSource: "asset:///images/refresh.png"
            pressedImageSource: "asset:///images/refresh.png"
            onClicked: {
                enabled:
                false
                refreshTriggered();
            }
        }

        ListView {
            id: hnList
            onTriggered: {
                var urlToLoad = article.postArticle;
                var page = webPage.createObject();
                nav.push(page);
                loading.webDisplay.url = urlToLoad;
                console.log('Item triggered!');
                console.log(urlToLoad);
            }

            dataModel: pageModel
            maxHeight: 1167.0
            layoutProperties: AbsoluteLayoutProperties {
                positionY: 113.0
            }
            visible: page.showList

            listItemComponents: [
                ListItemComponent {
                    id: articleList
                    type: "item"
                    HNPage {
                        id: article
                        postTitle: ListItemData.title
                        postURL: ListItemData.domain
                        postUsername: ListItemData.poster
                        postTime: ListItemData.timePosted + "| " + ListItemData.points
                        postComments: ListItemData.commentCount
                        postArticle: ListItemData.articleURL
                        //                        onGoTocomments: {
                        //                            Tart.send('requestComments', {
                        //                                    source: ListItemData.commentsURL,
                        //                            });
                        //                        }
                    }
                }
            ]
            attachedObjects: [
                GroupDataModel {
                    id: pageModel
                    grouping: ItemGrouping.None
                    sortedAscending: true
                    sortingKeys: [ "postNumber" ]
                },
                DataSource {
                    id: pageSource
                    source: ""
                    query: "/articles/item"
                    onDataLoaded: {
                        pageModel.insertList(data);
                        console.log("List filled...")
                    }
                },
                ListScrollStateHandler {
                    onAtEndChanged: {
                        // Request more data (ie send a requestPage to Tart and pass moreLink as the source.
                        Tart.send('requestPage', {
                                source: morePage,
                                forceReload: 'False'
                        });
                    }
                }
            ]
            leadingVisual: DropDown {
                title: "Page:"
                id: pageSelector
                selectedOption: topPosts

                translationX: 20.0
                Option {
                    id: topPosts
                    text: "Top Posts"

                }
                Option {
                    id: askPosts
                    text: "Ask HN"

                }
                Option {
                    id: newestPosts
                    text: "Newest Posts"

                }
                onSelectedOptionChanged: {
                    showLoading = true;
                    showList = false;
                    pageModel.clear();
                    console.log('loading requested page: ' + selectedOption.text);
                    Tart.send('requestPage', {
                            source: selectedOption.text,
                            forceReload: 'False'
                        });
                }
            }
        }
    }
}

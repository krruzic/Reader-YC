// Tabbed Pane project template
import bb.cascades 1.0
import bb.data 1.0
import "../tart.js" as Tart


Page {
    id: page
    signal reloadList(string file)
    signal refreshTriggered()
    property bool showList: true
    property bool showLoading: false

    onReloadList: {
        console.log("Loading page from Python!  " + file);
        pageSource.source = file;
        pageModel.clear();
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
        Tart.send('requestPage',  {source: pageSelector.selectedOption.text, forceReload: 'True'});
        refreshButton.enabled = true;
    }

    content: Container {

        ActivityIndicator {
            running: true
            visible: page.showLoading
            preferredWidth: 350
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layoutProperties: AbsoluteLayoutProperties {
                positionX: 200.0
                positionY: 640.0
            }
        }

        background: Color.create("#f7fafa")
        layout: AbsoluteLayout {}
        ImageView {
            imageSource: "asset:///images/HN_title.png"
            visible: true
            onTouch: {
                hnList.scrollToPosition(0, 0x2)
            }
        }
        ImageButton  {
            id: refreshButton
            layoutProperties: AbsoluteLayoutProperties {
                positionY: 14.0
                positionX: 660.0
            }
            defaultImageSource: "asset:///images/refresh.png"
            pressedImageSource: "asset:///images/refresh.png"
            onClicked: {
                enabled: false
                refreshTriggered();
            }
        }


        ListView {
            id: hnList
            onTriggered: {
                console.log('Item triggered!')
            }
            dataModel: pageModel
            maxHeight: 1167.0
            layoutProperties: AbsoluteLayoutProperties {
                positionY: 113.0
            }
            visible: page.showList
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
                    console.log('loading requested page: ' + selectedOption.text);
                    Tart.send('requestPage',  {source: selectedOption.text, forceReload: 'False'});
                }
            }
///app/native/assets/MainPage.qml:69:
//Error: Invalid write to global property "file"


            listItemComponents: [
                ListItemComponent {
                    type: "item"
                    HNPage {
                        id: article
                        // REAL
                        postTitle: ListItemData.title
                        postURL: ListItemData.domain
                        postUsername: ListItemData.poster
                        postTime: ListItemData.timePosted + "| " + ListItemData.points
                        postComments: ListItemData.commentCount
                    }
                }
            ]
        }
        attachedObjects: [
            GroupDataModel {
                id: pageModel
                grouping: ItemGrouping.None
                sortedAscending: true
                sortingKeys: ["postNumber"]
            },
            DataSource {
                id: pageSource
                source: ""
                query: "/articles/item"
                onDataLoaded: {
                    pageModel.insertList(data);
                    console.log("List filled...")
                }
            }
        ]
//        onCreationCompleted: {
//            pageSource.load();
//       }
    }
}
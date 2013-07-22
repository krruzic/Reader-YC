import bb.cascades 1.0
import "../tart.js" as Tart

NavigationPane {
    id: nav

    signal reloadList(string file, string moreLink)
    signal loadComments(string file)
    MainPage {
        id: mainPage
    }

    attachedObjects: [
        ComponentDefinition {
            id: webPage
            source: "webArticle.qml"
        },
        ComponentDefinition {
        	id: commentPage
        	source: "CommentPage.qml"
        }
    ]

    onCreationCompleted: {
        Tart.init(_tart, Application);

        Tart.register(nav);
        Tart.send('uiReady');

        reloadList.connect(mainPage.reloadList);
        loadComments.connect(commentPage.loadComments);
    }

    onPopTransitionEnded: {
        page.destroy()
    }

    function onUpdateList(data) {
        reloadList(data.file, data.moreLink);
    }

    function onFillComments(data) {
        loadComments(data.file)
    }
}
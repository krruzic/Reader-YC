import bb.cascades 1.0
import "../tart.js" as Tart

NavigationPane {
    id: nav

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
    }

    onPopTransitionEnded: {
        page.destroy()
    }
}
import bb.cascades 1.0
import "../tart.js" as Tart


NavigationPane {
    id: nav
    
    signal reloadList(string file)
    MainPage { id: mainPage }
    
    attachedObjects: ComponentDefinition {
        id: highScoreScreen
        source: "webArticle.qml"
    }
    
    onCreationCompleted: {
        Tart.init(_tart, Application);
        
        Tart.register(nav);
        Tart.send('uiReady');
        
        reloadList.connect(mainPage.reloadList);
    }
    
    onPopTransitionEnded: {
        page.destroy()
    }
    
    function onUpdateList(data) {
        reloadList(data.file);
    }
}
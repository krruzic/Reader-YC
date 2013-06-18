import bb.cascades 1.0
import "../tart.js" as Tart

Page {
    id: root

    Container {
        layout: DockLayout {}

        Label {
            id: label
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }
    }

    function onMsgFromPython(data) {
        label.text = data.text;
    }

    onCreationCompleted: {
        Tart.init(_tart, Application);

        Tart.register(root);

        Tart.send('uiReady');
    }
}

import bb.cascades 1.0
import "../tart.js" as Tart

NavigationPane {
    id: root

    Page {
        id: page

        Container {
            Label {
                text: qsTr("BB-Tart OpenGL Sample")
            }

            OglWindow {

            }
        }// Container for Page
    }

    onCreationCompleted: {
        // OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;

        Tart.init(_tart, Application);

        Tart.register(root);

        Tart.send('uiReady');
    }


    //-----------------
    //
    // function onWindowStateChanged(data) {
    //     Tart.send('windowStateChanged', data);
    // }

}

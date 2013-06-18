import bb.cascades 1.0
import "../tart.js" as Tart

Container {
    topPadding: 0
    bottomPadding: 15

    background: Color.Grey

    Container {
        property int padding: 5
        background: Color.create("#dd0000")
        topPadding: padding
        bottomPadding: padding
        leftPadding: padding
        rightPadding: padding

        // The ForeignWindowControl will punch a hole in the Cascades frame buffer
        // allowing you to show whatever you like beneath it.
        ForeignWindowControl {
            id: fwc
            windowId: "fwc"

            property variant prev_size: [0, 0]

            preferredWidth: 800
            preferredHeight: 800

            implicitLayoutAnimationsEnabled: false

            // defaults:
            updatedProperties: WindowProperty.Position | WindowProperty.Size | WindowProperty.SourceSize
            onControlFrameChanged: {
                var w = Math.round(frame.width);
                var h = Math.round(frame.height);

                // report only when we see actual changes in integer values
                var rect = [w, h];
                var changed = false;
                for (var i = 0; i < rect.length; i++) {
                    if (rect[i] !== prev_size[i]) {
                        changed = true;
                        prev_size[i] = rect[i];
                    }
                }

                if (changed) {
                    prev_size = rect;

                    var data = {
                        group: windowGroup,
                        id: windowId,
                        width: w,
                        height: h
                    };

                    Tart.send('chartResized', data);
                }
            }

            onTouch: {
                var data = {action: event.touchType, x: event.localX, y: event.localY};

                if (event.touchType == 0) {
                    timer.start();
                    Tart.send('touch', data);
                    data.action = 1;
                    timer.data = data;

                } else if (event.touchType == 1) {
                    timer.data = data;

                } else {
                    data.action = 2;
                    Tart.send('touch', data);
                    timer.stop();
                }
            }

            attachedObjects: [
                QTimer {
                    id: timer
                    property variant data

                    interval: 1000 / 60
                    singleShot: false
                    onTimeout: {
                        Tart.send('touch', timer.data);
                    }
                }
            ]
        }// ForeignWindow
    }// Container
}// Container

import bb.cascades 1.0

Page {
    id: page
    property alias text: help.text

    Container {
        bottomPadding: 10

        ScrollView {
            id: scroller
            property bool was_scrolled: false
            property bool created: false

            Label {
                id: help
                multiline: true
                text: "Placeholder text"
            }

            // hack to detect when user has scrolled, so we can hide the
            // hint, without using the viewableArea property which is a QRectF
            // with no functions accessible from QML :-(
            onViewableAreaChanged: {
                if (!created) {
                    created = true;
                    return;
                }

                was_scrolled = true;
            }
        }

        Container {
            visible: !scroller.was_scrolled
            horizontalAlignment: HorizontalAlignment.Right
            leftPadding: 20
            rightPadding: 20
            bottomPadding: 7
            translationY: 10

            Label {
                text: "Scroll down for more"
                textStyle.fontStyle: FontStyle.Italic
                textStyle.color: Color.create("#8000b800")
            }
        }
    }

    actions: [
        InvokeActionItem {
            title: "Leave Review"
            ActionBar.placement: ActionBarPlacement.OnBar
            query {
                invokeTargetId: "sys.appworld"
                invokeActionId: "bb.action.OPEN"
                uri: "appworld://content/51274"
            }
        }
    ]
}

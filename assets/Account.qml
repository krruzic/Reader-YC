import bb.cascades 1.2
import "tart.js" as Tart
import "global.js" as Global
Container {
    property alias bioField: bioField
    property alias emailField: emailField

    background: Color.White
    id: account
    visible: true
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    leftPadding: 10
    rightPadding: 10
    onCreationCompleted: {
        Tart.register(account)
    }

    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W300
        },
        ImagePaintDefinition {
            imageSource: "asset:///images/text.amd"
            id: background
        }
    ]
    ScrollView {
        scrollViewProperties.scrollMode: ScrollMode.Vertical
        Container {
            bottomPadding: 10
            Label {
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.base: lightStyle.style
                id: userLabel
                text: "<span style='color:#ff8e00'>Logged in as:  </span>" + "deft"
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 7
                textStyle.color: Color.DarkGray
                textFormat: TextFormat.Html
                multiline: true
            }
            Container {
                bottomMargin: 10

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.base: lightStyle.style
                    text: "Edit your bio\n(email is private)"
                    textStyle.fontSize: FontSize.PointValue
                    //        textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 7
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    bottomMargin: 100

                }
                Container {
                    background: background.imagePaint
                    TextField {
                        enabled: false
                        backgroundVisible: false
                        verticalAlignment: VerticalAlignment.Center
                        id: emailField
                        hintText: "Email"
                        bottomMargin: 100
                    }
                }
            }
            Container {
                background: background.imagePaint
                TextArea {
                    autoSize.maxLineCount: 20
                    backgroundVisible: false
                    enabled: false
                    id: bioField
                    verticalAlignment: VerticalAlignment.Fill
                    minHeight: 400
                    hintText: "Bio"
                }
            }
            Label {
                text: "Text surrounded by asterisks is italicized, if the character after the first asterisk isn't whitespace."
                multiline: true
                textStyle.fontSizeValue: 5
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Button {
                    horizontalAlignment: HorizontalAlignment.Center
                    text: "Save"
                    onClicked: {
                        Tart.send('saveProfile', {
                            	username: settings.username,
                                email: emailField.text,
                                about: bioField.text
                            });
                    }
                }
                Button {
                    leftMargin: 150
                    horizontalAlignment: HorizontalAlignment.Center
                    text: "Logout"
                    onClicked: {
                        Tart.send('logout', {
                            });
                    }
                }
            }
        }
    }
}
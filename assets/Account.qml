import bb.cascades 1.2
import "tart.js" as Tart
import "global.js" as Global
Container {
    property variant baseColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ffdddddf") : Color.create("#434344")
    property variant secondaryColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "" : Color.create("#f99925")

    property alias bioField: bioField
    property alias emailField: emailField


    id: account
    visible: true
    horizontalAlignment: HorizontalAlignment.Center
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
    Container {
        Label {
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.base: lightStyle.style
            id: userLabel
            text: "<span style='color:#f99925'>Logged in as:  </span>" + settings.username
            textStyle.fontSize: FontSize.PointValue
            textStyle.fontSizeValue: 7
            textStyle.color: baseColour
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
                textStyle.fontSizeValue: 7
                textStyle.color: baseColour
                textFormat: TextFormat.Html
                multiline: true
                bottomMargin: 100

            }
            Container {
                TextField {
                    textStyle.color: Color.create("#262626")
                    enabled: false
                    backgroundVisible: true
                    verticalAlignment: VerticalAlignment.Center
                    id: emailField
                    hintText: "Email"
                }
            }
        }
        Container {
            TextArea {
                textStyle.color: Color.create("#262626")
                autoSize.maxLineCount: 20
                backgroundVisible: true
                enabled: false
                id: bioField
                verticalAlignment: VerticalAlignment.Fill
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
            horizontalAlignment: HorizontalAlignment.Center
            Button {
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
                text: "Logout"
                onClicked: {
                    Tart.send('logout', {
                        });
                }
            }
        }
    }
}
import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: userPage
    onCreationCompleted: {
        Tart.register(userPage);
    }
    property string username: ""
    property string created: ""
    property string karma: ""
    property string about: ""
    property string submitted: ""
    property string comments: ""
    function onUserInfoReceived(data) {
        console.log(data.details)
        var results = data.details
        searchIndicator.visible = false;
        userDetails.visible = true;
        username = results[0]
        created = results[1]
        karma = results[2]
        about = results[4]
        submitted = results[5]
        comments = results[6]
    }
    Container {

        HNTitleBar {
            id: titleBar
            text: "Reader|YC - User"
            showButton: false
        }
        Container {
            topPadding: 10
            leftPadding: 19
            rightPadding: 19
            TextField {
                visible: true
                objectName: "searchField"
                textStyle.color: Color.create("#262626")
                textStyle.fontSize: FontSize.Medium
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                input {
                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                }
                hintText: qsTr("Search users (case sensitive)")
                id: searchField
                input.onSubmitted: {
                    searchIndicator.visible = true
                    Tart.send('requestUserPage', {
                            source: text
                        });
                }
            }
            ActivityIndicator {
                topPadding: 80
                minHeight: 500
                minWidth: 500
                id: searchIndicator
                running: true
                visible: true
                horizontalAlignment: horizontalAlignment.Center
            }
            Container {
                id: userDetails
                visible: if (searchIndicator.visible == true) {
                    userDetails.visible = false;
                }
                Label {
                    visible: if (username != "")
                        true
                    text: username + "	            	" + karma + " points"
                    textFormat: TextFormat.Plain
                    textStyle.fontSize: FontSize.XLarge
                    textStyle.textAlign: TextAlign.Center
                    bottomMargin: 25
                }
                Container {
                    id: aboutText
                    visible: false
                    background: aboutImage.imagePaint
                    bottomMargin: 10
                    Label {
                        text: " About: "
                    }
                    Divider {
                    }
                    TextArea {
                        onTextChanged: {
                            if (text == "")
                                aboutText.visible = false;
                            else
                                aboutText.visible = true;
                        }
                        text: about
                        editable: false
                        focusHighlightEnabled: false
                        textFormat: TextFormat.Html
                        textStyle.fontSize: FontSize.Small
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Divider {
                            opacity: 0
                        }
                        Label {
                            translationX: -10
                            horizontalAlignment: horizontalAlignment.Right
                            textStyle.fontSize: FontSize.XSmall
                            text: " Created: " + created
                            textStyle.color: Color.DarkGray
                        }
                    }
                }
                Container {
                    visible: if (comments != "")
                        true
                    Label {
                        textFormat: textFormat.Html
                        text: " Submitted: " + submitted
                        textStyle.fontSize: FontSize.XSmall
                    }
                    Label {
                        textFormat: textFormat.Html
                        text: " Comments: " + comments
                        textStyle.fontSize: FontSize.XSmall

                    }
                }
                attachedObjects: [
                    ImagePaintDefinition {
                        id: aboutImage
                        imageSource: "asset:///images/text.amd"

                    }
                ]
            }
        }
    }
}
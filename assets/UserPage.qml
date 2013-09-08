import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: userPane
    titleBar: HNTitleBar {
        id: titleBar
        text: "Reader|YC - User"
        refreshEnabled: true
        buttonImage: "asset:///images/search.png"
        buttonPressedImage: "asset:///images/search.png"
    }
    onCreationCompleted: {
        Tart.register(userPane);
    }
    property alias searchVisible: searchField.visible
    property string username: ""
    property string created: ""
    property string karma: ""
    property string about: ""
    property string submitted: ""
    property string comments: ""
    property bool busy: false

    function onUserInfoReceived(data) {
        loading.visible = false;
        console.log("User info recieved!")
        var results = data.details;
        userDetails.visible = true;
        username = results[0];
        created = results[1];
        karma = results[2];
        about = results[4];
        submitted = results[5];
        comments = results[6];
    }

    function onUserError(data) {
        loading.visible = false;
        errorLabel.visible = true;
        errorLabel.text = data.text
    }

    Container {
        Container {
            topPadding: 10
            leftPadding: 19
            rightPadding: 19
            TextField {
                visible: true
                id: searchField
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
                validator: Validator {
                    state: ValidationState.Unknown
                    errorMessage: "Entry cannot have spaces"
                    validationRequested: true

                }
                hintText: qsTr("Search users (case sensitive)")
                input.onSubmitted: {
                    errorLabel.visible = false;
                    loading.visible = true;
                    userDetails.visible = false;
                    Tart.send('requestPage', {
                            source: text,
                            sentBy: 'userPage'
                        });
                }
            }

            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Container {
                    visible: loading.visible
                    ActivityIndicator {
                        id: loading
                        minHeight: 300
                        minWidth: 300
                        running: true
                        visible: true
                    }
                }
            }
            Container {
                visible: errorLabel.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: errorLabel
                    text: ""
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    visible: false
                }
            }

            Container {
                id: userDetails
                visible: false
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Label {
                        visible: userDetails.visible
                        text: username
                    }
                    Divider {
                        opacity: 0
                    }
                    Label {
                        visible: userDetails.visible
                        text: karma + " points"
                        textFormat: TextFormat.Plain
                        textStyle.textAlign: TextAlign.Center
                    }
                }
                Container {
                    id: aboutText
                    background: aboutImage.imagePaint
                    Label {
                        text: " About: "
                    }
                    Divider {
                        bottomMargin: 1
                        topMargin: 1
                    }
                    TextArea {
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
                    TextArea {
                        editable: false
                        textFormat: textFormat.Html
                        text: " Submitted: " + submitted
                        textStyle.fontSize: FontSize.XSmall
                    }
                    TextArea {
                        editable: false
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
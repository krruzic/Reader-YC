import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: userPage
    onCreationCompleted: {
        Tart.register(userPage);
    }
    property alias searchVisible: searchField.visible
    property string username: ""
    property string created: ""
    property string karma: ""
    property string about: ""
    property string submitted: ""
    property string comments: ""
    property int submitCount: 0
    property bool busy: false

    function onUserInfoReceived(data) {
        busy = false;
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
        busy = false;
        errorLabel.visible = true;
        errorLabel.text = data.text
    }

    Container {
        HNTitleBar {
            id: titleBar
            text: "Reader|YC - User"
            showButton: true
            buttonImage: "asset:///images/search.png"
            buttonPressedImage: "asset:///images/search.png"
            onRefreshPage: {
                searchField.visible = true;
                slideSearch.play();
            }
        }
        Container {
            topPadding: 10
            leftPadding: 19
            rightPadding: 19
            TextField {
                visible: false
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
                validator: Validator {
                    state: ValidationState.Unknown
                    errorMessage: "Entry cannot have spaces"
                    validationRequested: true

                }
                hintText: qsTr("Search users (case sensitive)")
                id: searchField
                input.onSubmitted: {
                    submitCount += 1;
                    errorLabel.visible = false;
                    busy = true;
                    userDetails.visible = false;
                    if (throttleTimer.running == false) {
                        Tart.send('requestUserPage', {
                                source: text
                            });
                    } else if (throttleTimer.running == true) {
                        busy = false
                        errorLabel.visible = true;
                        errorLabel.text = "You're doing that too often, try again in " + (timerStart);
                    }
                    if (submitCount >= 25) {
                        throttleTimer.start();
                        throttleTimer.running = true;
                    }
                }
                animations: [
                    TranslateTransition {
                        id: slideSearch
                        target: searchField
                        fromX: -600.0
                        toX: 0.0
                    }
                ]
            }

            Container {
                visible: busy
                rightPadding: 220
                leftPadding: 220
                topPadding: 80
                ActivityIndicator {
                    minHeight: 300
                    minWidth: 300
                    running: true
                    visible: busy
                }
            }
            Label {
                id: errorLabel
                multiline: true
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
                    },
                    QTimer {
                        id: throttleTimer
                        property bool running: false
                        interval: 600000 // 5 minute interval
                        onTimeout: {
                            throttleTimer.stop();
                            timerStart = 0;
                            throttleTimer.running = false;
                            submitCount = 0;
                        }
                    }
                ]
            }
        }
    }
}
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
    property int timerStart: 0

    function onUserInfoReceived(data) {
        searchIndicator.visible = false;
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
        searchIndicator.visible = false;
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
                timerStart = Date.now()
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
                    searchIndicator.visible = true;
                    userDetails.visible = false;
                    if (throttleTimer.running == false) {
                        Tart.send('requestUserPage', {
                                source: text
                            });
                    } else if (throttleTimer.running == true) {
                        searchIndicator.visible = false;
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

            ActivityIndicator {
                minHeight: 500
                minWidth: 500
                id: searchIndicator
                running: true
                visible: false
                horizontalAlignment: horizontalAlignment.Center
            }
            Label {
                id: errorLabel
                multiline: true

            }
            Container {
                id: userDetails
                visible: false
                Label {
                    text: username + karma + " points"
                    textFormat: TextFormat.Plain
                    textStyle.fontSize: FontSize.XLarge
                    textStyle.textAlign: TextAlign.Center
                    bottomMargin: 25
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
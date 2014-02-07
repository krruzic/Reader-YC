import bb.cascades 1.2
import "tart.js" as Tart
NavigationPane {
    property alias searchVisible: searchField.visible
    property alias searchText: searchField.text
    property string username: ""
    property string created: ""
    property string karma: ""
    property string about: ""
    property string submitted: ""
    property string comments: ""
    property bool busy: false

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }
    function playAnim() {
        console.log("trying to play....")
        searchField.visible = true;
        slideSearch.play();
    }

    Page {
        id: userPane
        titleBar: HNTitleBar {
            id: titleBar
            text: "Reader YC - User"
            showButton: false
            refreshEnabled: false
            //buttonPressedImage: "asset:///images/search.png"
            onRefreshPage: {
                searchField.visible = true;
                slideSearch.play();
            }
        }
        onCreationCompleted: {
            Tart.register(userPane);
        }

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
                    visible: false
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
                    animations: [
                        TranslateTransition {
                            id: slideSearch
                            target: searchField
                            fromX: -600.0
                            toX: 0.0
                        }
                    ]
                    input.submitKey: SubmitKey.Search
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
                            visible: false
                        }
                    }
                }
                Container {
                    visible: errorLabel.visible
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    Container {
                        minHeight: 50
                        maxHeight: 50
                    }
                    Label {
                        id: errorLabel
                        text: "<b><span style='color:#ff7900'>Try searching a user!</span></b>\n(Accounts are case sensitive)"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Center
                        textStyle.fontSizeValue: 9
                        textStyle.color: Color.DarkGray
                        textFormat: TextFormat.Html
                        multiline: true
                        visible: true
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
}
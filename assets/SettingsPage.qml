import bb.cascades 1.2
import bb.system 1.0
import "tart.js" as Tart
import bb.cascades 1.2

Page {
    id: settingsPage
    property bool loggedIn: false
    property string username: ""
    titleBar: HNTitleBar {
        refreshEnabled: false
        id: titleBar
        text: "Reader YC - Settings"

    }
    onCreationCompleted: {
        Tart.register(settingsPage);
        precheckValues(settings.openInBrowser ? true : false, settings.readerMode ? true : false, settings.user, settings.login ? true : false);
    }
    function onCacheDeleted(data) {
        cacheButton.enabled = true;
        cacheDeleteToast.body = data.text;
        cacheDeleteToast.cancel();
        cacheDeleteToast.show();
    }
    function precheckValues(browser, reader, user, login) {
        browserToggle.checked = browser
        readerToggle.checked = reader
        username = user
        loggedIn = login
    }

    function onLoginResult(data) {
        settings.username = data.user
        settings.login = data.login
        textBox.text = data.text;
        loading.visible = false;
        passwordField.enabled = true;
        usernameField.enabled = true;
    }
    function onLoginCheck(data) {
        if (data.state == "false") {
            console.log("Not logged in!")
        } else {
            console.log("Logged in!")
            settings.login = true;
        }
    }

    content: Container {
        topPadding: 10
        //        SegmentedControl {
        //            Option {
        //                id: option1
        //                text: "App Settings"
        //                value: "option1"
        //                selected: true
        //            }
        //            Option {
        //                id: option2
        //                text: "Account Settings"
        //                value: "option2"
        //            }
        //            onSelectedIndexChanged: {
        //                if (selectedIndex == 0) {
        //                    cnt1.opacity = 0;
        //                    cnt1.visible = true;
        //                    cnt2.visible = false;
        //                    fadein1.play();
        //                } else if (selectedIndex == 1) {
        ////                    if (loggedIn) {
        ////                        cnt3.opacity = 0;
        ////                        cnt3.visible = true;
        ////                        cnt1.visible = false;
        ////                        fadein3.play();
        ////                    } else {
        //                        cnt2.opacity = 0;
        //                        cnt2.visible = true;
        //                        cnt1.visible = false;
        //                        fadein2.play();
        //                    }
        //                }
        //                selectedOption: option1
        //            }
        Container {
            id: cnt1
            visible: true
            ScrollView {
                //preferredWidth: 768
                scrollViewProperties {
                    scrollMode: ScrollMode.Vertical
                }

                Container {
                    //preferredWidth: 768
                    topPadding: 10
                    leftPadding: 10
                    rightPadding: 10
                    Container {
                        layout: DockLayout {
                        }
                        horizontalAlignment: HorizontalAlignment.Fill // Make full width
                        Label {
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            text: "<b>Article Click Behaviour</b>"
                            textFormat: TextFormat.Html
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 7
                            textStyle.color: Color.create("#434344")
                        }
                        Label {
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Bottom
                            text: "Always open in browser"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: Color.create("#fe8a3e")
                        }

                        ToggleButton {
                            horizontalAlignment: HorizontalAlignment.Right

                            id: browserToggle
                            onCheckedChanged: {
                                if (checked == true) {
                                    settings.openInBrowser = true;
                                    console.log("Always open in browser..")
                                } else {
                                    settings.openInBrowser = false;
                                    console.log("Open in app")
                                }
                            }
                        }
                    }
                    Divider {

                    }
                    Container {
                        layout: DockLayout {
                        }
                        horizontalAlignment: HorizontalAlignment.Fill // Make full width
                        Label {
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            text: "<b>Reader Mode</b>"
                            textFormat: TextFormat.Html
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 7
                            textStyle.color: Color.create("#434344")
                        }

                        Label {
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Bottom
                            text: "Display URLs using Readability"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: Color.create("#fe8a3e")
                        }

                        ToggleButton {
                            horizontalAlignment: HorizontalAlignment.Right

                            id: readerToggle
                            onCheckedChanged: {
                                if (checked == true) {
                                    settings.readerMode = true;
                                    console.log("Reader mode on..")
                                } else {
                                    settings.readerMode = false;
                                    console.log("Reader mode off")
                                }
                            }
                        }
                    }
                    Divider {

                    }
                    Button {
                        verticalAlignment: VerticalAlignment.Top
                        horizontalAlignment: HorizontalAlignment.Center

                        id: cacheButton
                        text: "Clear cache"
                        onClicked: {
                            cacheButton.enabled = false;
                            Tart.send('deleteCache');
                        }
                    }
                    Label {
                        verticalAlignment: VerticalAlignment.Bottom
                        horizontalAlignment: HorizontalAlignment.Center
                        text: "This will delete all cached comments and favourited articles"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 5
                        multiline: true
                        //textStyle.textAlign: TextAlign.Center
                        //preferredWidth: 768
                    }
                    Divider {

                    }
                    Label {
                        text: "Reader YC - Copyright © 2013 Surge Co."
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 5
                        //preferredWidth: 768
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                    }
                }
            }
            animations: [
                FadeTransition {
                    id: fadein1
                    target: cnt1
                    fromOpacity: 0.0
                    toOpacity: 1.0
                    delay: 20
                    duration: 500
                }
            ]
        } // container

        //        Container {
        //            id: cnt2
        //            visible: false
        //            horizontalAlignment: HorizontalAlignment.Center
        //            verticalAlignment: VerticalAlignment.Center
        //            Label {
        //                id: hnLabel
        //                text: "<b><span style='color:#ff7900'>Login to your HN account</span></b>\nAccounts must be created <a href='https://news.ycombinator.com/newslogin?whence=news'>here </a>"
        //                horizontalAlignment: HorizontalAlignment.Center
        //                textStyle.fontSize: FontSize.PointValue
        //                textStyle.textAlign: TextAlign.Center
        //                textStyle.fontSizeValue: 7
        //                textStyle.color: Color.DarkGray
        //                textFormat: TextFormat.Html
        //                multiline: true
        //            }
        //            TextField {
        //                horizontalAlignment: HorizontalAlignment.Center
        //                maxWidth: 500
        //                id: usernameField
        //                hintText: "Username"
        //                input {
        //                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
        //                }
        //            }
        //            TextField {
        //                horizontalAlignment: HorizontalAlignment.Center
        //                maxWidth: 500
        //                id: passwordField
        //                hintText: "Password"
        //                input.masking: TextInputMasking.Masked
        //                inputMode: TextFieldInputMode.Password
        //                input {
        //                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
        //                }
        //            }
        //            Button {
        //                horizontalAlignment: HorizontalAlignment.Center
        //                verticalAlignment: VerticalAlignment.Center
        //                text: "Login"
        //                onClicked: {
        //                    passwordField.enabled = false;
        //                    usernameField.enabled = false;
        //                    Tart.send('requestLogin', {
        //                            username: usernameField.text,
        //                            password: passwordField.text
        //                        });
        //                    loading.visible = true
        //                }
        //            }
        //            Container {
        //                horizontalAlignment: HorizontalAlignment.Center
        //                verticalAlignment: VerticalAlignment.Center
        //                Container {
        //                    visible: loading.visible
        //                    ActivityIndicator {
        //                        id: loading
        //                        minHeight: 300
        //                        minWidth: 300
        //                        running: true
        //                        visible: false
        //                    }
        //                }
        //            }
        //            TextArea {
        //                id: textBox
        //                editable: false
        //                textFormat: TextFormat.Html
        //                maxWidth: 500
        //            }
        //            animations: [
        //                FadeTransition {
        //                    id: fadein2
        //                    target: cnt2
        //                    fromOpacity: 0.0
        //                    toOpacity: 1.0
        //                    delay: 20
        //                    duration: 500
        //
        //                }
        //            ]
        //        }
        //        Container {
        //            id: cnt3
        //            Label {
        //                text: "Logged in as: " + username
        //            }
        //        }
    }
    attachedObjects: [
        SystemToast {
            id: cacheDeleteToast
            //body: ""
        }
    ]
}// Page
import bb.cascades 1.4
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global

Page {
    id: settingsPage

    property variant baseColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ffdddddf") : Color.create("#434344")
    property variant secondaryColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "" : Color.create("#f99925")

    property bool loggedIn: false
    property string username: ""
    titleBar: HNTitleBar {
        refreshEnabled: false
        id: titleBar
        text: "Reader YC - Settings"

    }

    onCreationCompleted: {
        Tart.register(settingsPage);
        precheckValues(settings.openInBrowser ? true : false, settings.readerMode ? true : false, settings.loggedIn ? true : false, settings.username, settings.legacyFetch ? true : false, settings.darkTheme ? true : false);
    }
    function onCacheDeleted(data) {
        cacheButton.enabled = true;
        cacheDeleteToast.body = data.text;
        cacheDeleteToast.cancel();
        cacheDeleteToast.show();
    }
    function precheckValues(browser, reader, login, user, fetch, theme) {
        apiToggle.checked = fetch;
        browserToggle.checked = browser;
        readerToggle.checked = reader;
        loggedIn = login;
        username = user;
        darkThemeToggle.checked = theme;
        console.log(loggedIn);
    }
    onLoggedInChanged: {
        console.log("Logged in set to: " + loggedIn);
    }
    function onLoginResult(data) {
        if (data.result == true) {
            settings.username = username;
            settings.loggedIn = true;
            account.visible = true;
            cnt2.visible = false;
        } else {
            settings.loggedIn = false;
            cacheDeleteToast.body = "Incorrect username/password";
            settings.username = "";
            cacheDeleteToast.cancel();
            cacheDeleteToast.show();
            loginButton.enabled = true;
        }
        passwordField.enabled = true;
        passwordField.text = "";
        usernameField.enabled = true;
    }
    function onLogoutResult(data) {
        loginButton.enabled = true;
        settings.loggedIn = false;
        settings.username = "";
        cacheDeleteToast.body = data.text;
        cacheDeleteToast.cancel();
        cacheDeleteToast.show();
        account.visible = false;
        cnt2.visible = true;
    }

    function onProfileSaved(data) {
        cacheDeleteToast.body = data.text;
        cacheDeleteToast.cancel();
        cacheDeleteToast.show();
    }

    function onProfileRetrieved(data) {
        if (data.email == null) {
            cacheDeleteToast.body = "Error getting profile! Try logging out";
            cacheDeleteToast.cancel();
            cacheDeleteToast.show();
        }
        account.bioField.enabled = true;
        account.emailField.enabled = true;
        account.emailField.text = data.email;
        account.bioField.text = data.about;
    }
    ScrollView {

        scrollViewProperties.scrollMode: ScrollMode.Vertical
        horizontalAlignment: HorizontalAlignment.Fill
        content: Container {
            horizontalAlignment: HorizontalAlignment.Fill
            topPadding: 10
            layout: DockLayout {

            }
            attachedObjects: [
                TextStyleDefinition {
                    id: lightStyle
                    base: SystemDefaults.TextStyles.BodyText
                    fontSize: FontSize.PointValue
                    fontSizeValue: 7
                    fontWeight: FontWeight.W300
                },
                SystemToast {
                    id: cacheDeleteToast
                }
            ]
            Container {
                SegmentedControl {
                    verticalAlignment: VerticalAlignment.Top
                    Option {
                        id: option1
                        text: "App Settings"
                        value: "option1"
                        selected: true
                    }
                    Option {
                        id: option2
                        text: "Account Settings"
                        value: "option2"
                    }
                    onSelectedIndexChanged: {
                        if (selectedIndex == 0) {
                            cnt1.visible = true;
                            cnt2.visible = false;
                            account.visible = false;
                        } else if (selectedIndex == 1) {
                            if (loggedIn != "") {
                                cnt2.visible = false;
                                account.visible = true;
                            } else {
                                cnt2.visible = true;
                            }
                            cnt1.visible = false;
                        }
                    }
                    selectedOption: option1
                }
                Container {
                    id: cnt1
                    visible: true
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    Container {
                        //preferredWidth: 768
                        leftPadding: 10
                        rightPadding: 10
                        Container {
                            layout: DockLayout {
                            }
                            horizontalAlignment: HorizontalAlignment.Fill // Make full width
                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                text: "<b>Article Click Behaviour</b>"
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 7
                                textStyle.color: baseColour
                            }
                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Bottom
                                text: "Always open in browser"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#f99925")
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
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                text: "<b>Reader Mode</b>"
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 7
                                textStyle.color: baseColour
                            }

                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Bottom
                                text: "Display URLs using Readability"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#f99925")
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
                        Container {
                            layout: DockLayout {

                            }
                            rightPadding: 0
                            horizontalAlignment: HorizontalAlignment.Fill // Make full width
                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                text: "<b>Use Legacy Comment Fetching</b>"
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 7
                                textStyle.color: baseColour
                                bottomMargin: 0
                                topMargin: 0
                            }

                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Bottom
                                text: "Scrapes HN for comments"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#f99925")
                                bottomMargin: 0
                                topMargin: 0
                            }
                            ToggleButton {
                                horizontalAlignment: HorizontalAlignment.Right

                                id: apiToggle
                                onCheckedChanged: {
                                    if (checked == true) {
                                        settings.legacyFetch = true;
                                        console.log("Legacy Fetch on..")
                                    } else {
                                        settings.legacyFetch = false;
                                        console.log("Legacy Fetch off")
                                    }
                                }
                            }
                        }
                        Divider {

                        }
                        Container {
                            layout: DockLayout {

                            }
                            rightPadding: 0
                            horizontalAlignment: HorizontalAlignment.Fill // Make full width
                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                text: "<b>Dark Theme</b>"
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 7
                                textStyle.color: baseColour
                                bottomMargin: 0
                                topMargin: 0
                            }

                            Label {
                                textStyle.base: lightStyle.style
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Bottom
                                text: "Use a dark theme throughout the app"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#f99925")
                                bottomMargin: 0
                                topMargin: 0
                                autoSize.maxLineCount: -1
                            }
                            ToggleButton {
                                horizontalAlignment: HorizontalAlignment.Right

                                id: themeToggle
                                onCheckedChanged: {
                                    if (checked == true) {
                                        Application.themeSupport.setVisualStyle(VisualStyle.Dark);
                                        settings.darkTheme = true;
                                        console.log("Dark Theme on..")
                                    } else {
                                        Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                                        settings.darkTheme = false;
                                        console.log("Dark Theme off")
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
                            textStyle.base: lightStyle.style
                            verticalAlignment: VerticalAlignment.Bottom
                            horizontalAlignment: HorizontalAlignment.Center
                            text: "This will delete all favourited articles"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 5
                            multiline: true
                        }
                        Divider {

                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "Reader YC - Copyright © 2013 Surge Co."
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 5
                            horizontalAlignment: HorizontalAlignment.Center
                            textStyle.textAlign: TextAlign.Center
                        }
                    }
                } // container
                Container {

                    id: cnt2
                    visible: false
                    Label {
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.base: lightStyle.style
                        id: hnLabel
                        text: "<span style='color:#f99925'>Login to your HN account</span>\nAccounts must be created <a href='https://news.ycombinator.com/newslogin?whence=news'>here </a>"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Center
                        textStyle.fontSizeValue: 9
                        textStyle.color: baseColour
                        textFormat: TextFormat.Html
                        multiline: true
                    }
                    Container {
                        rightPadding: 100
                        leftPadding: 100
                        horizontalAlignment: HorizontalAlignment.Center
                        attachedObjects: [
                            ImagePaintDefinition {
                                imageSource: "asset:///images/text.amd"
                                id: background
                            }
                        ]
                        Container {
                            bottomMargin: 10
                            TextField {
                                backgroundVisible: true
                                horizontalAlignment: HorizontalAlignment.Center
                                id: usernameField
                                textStyle.color: Color.create("#262626")

                                hintText: "Username"
                                input {
                                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                                }
                            }
                        }
                        Container {
                            TextField {
                                backgroundVisible: true
                                horizontalAlignment: HorizontalAlignment.Center
                                id: passwordField
                                hintText: "Password"
                                input.masking: TextInputMasking.Masked
                                textStyle.color: Color.create("#262626")

                                inputMode: TextFieldInputMode.Password
                                input {
                                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                                }
                                input.onSubmitted: {
                                    loginButton.clicked();
                                }
                                input.submitKey: SubmitKey.Go

                            }
                        }
                        Button {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            text: "Login"
                            id: loginButton
                            onClicked: {
                                enabled = false;
                                passwordField.enabled = false;
                                usernameField.enabled = false;
                                username = usernameField.text;
                                Tart.send('requestLogin', {
                                        username: usernameField.text,
                                        password: passwordField.text
                                    });
                            }
                        }
                    }
                }
            }
            Container {
                id: account
                visible: false
                onVisibleChanged: {
                    if (visible) {
                        Tart.send('getProfile', {
                                username: username
                            });
                    }
                }
                property alias bioField: bioField
                property alias emailField: emailField
                leftPadding: 10
                rightPadding: 10
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
                                id: emailField
                                hintText: "Email"
                            }
                        }
                    }
                    Container {
                        TextArea {
                            textStyle.color: Color.create("#262626")
                            autoSize.maxLineCount: 8
                            backgroundVisible: true
                            enabled: false
                            id: bioField
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
        }

    }
} // Page

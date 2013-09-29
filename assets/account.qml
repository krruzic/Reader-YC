import bb.cascades 1.0

Container {
    id: cnt2
    opacity: 1

    Container {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        Label {
            id: hnLabel
            text: "<b><span style='color:#fe8515'>Login to your HN account</span></b>\nAccounts must be created <a href='https://news.ycombinator.com/newslogin?whence=news'>here </a>"
            horizontalAlignment: HorizontalAlignment.Center
            textStyle.fontSize: FontSize.PointValue
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSizeValue: 9
            textStyle.color: Color.DarkGray
            textFormat: TextFormat.Html
            multiline: true
        }
        TextField {
            horizontalAlignment: HorizontalAlignment.Center
            maxWidth: 500
            id: usernameField
            hintText: "Username"
            input {
                flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
            }
        }
        TextField {
            horizontalAlignment: HorizontalAlignment.Center
            maxWidth: 500
            id: passwordField
            hintText: "Password"
            input.masking: TextInputMasking.Masked
            inputMode: TextFieldInputMode.Password
            input {
                flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
            }
        }
        Button {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            text: "Login"
            onClicked: {
                passwordField.enabled = false;
                usernameField.enabled = false;
                Tart.send('requestLogin', {
                        username: usernameField.text,
                        password: passwordField.text
                    });
                loading.visible = true
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
                    visible: false
                }
            }
        }
        TextArea {
            id: textBox
            editable: false
            textFormat: TextFormat.Html
            maxWidth: 500
        }
    }

    animations: [
        FadeTransition {
            id: fadein2
            target: cnt2
            fromOpacity: 0.0
            toOpacity: 1.0
            delay: 100
            duration: 500

        }
    ]
}

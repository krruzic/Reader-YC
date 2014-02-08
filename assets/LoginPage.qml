import bb.cascades 1.2
import "tart.js" as Tart
Page {
    id: loginPage
    onCreationCompleted: {
        Tart.register(loginPage)
    }

    function onLoginResult(data) {
        textBox.text = data.text;
        loading.visible = false;
        passwordField.enabled = true;
        usernameField.enabled = true;

    }
    Container {
        layout: DockLayout {
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center

            TextField {
                maxWidth: 500
                id: usernameField
                hintText: "Username"
                input {
                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                }
            }
            TextField {
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
    }
}
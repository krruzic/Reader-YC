import bb.cascades 1.2
import bb.system 1.0
import "tart.js" as Tart

Sheet {
    id: sheet
    peekEnabled: false
    ActionBar.placement: ActionBarPlacement.Default
    Page {
        id: postPage
        onCreationCompleted: {
            Tart.register(postPage);
        }
        function onStoryPosted(data) {
            if (data.result == 'true') {
                resultToast.body = "Story successfully posted!"
                resultToast.cancel();
                resultToast.show();
                Application.menuEnabled = true;
                sheet.close();
            } else {
                resultToast.body = "Story could not be posted, try again!"
                resultToast.cancel();
                resultToast.show();
            }
        }
        titleBar: HNTitleBar {
            text: "Reader YC - Post a Story"
            refreshEnabled: false
        }
        attachedObjects: [
            SystemToast {
                id: resultToast
            }
        ]
        actionBarVisibility: ChromeVisibility.Visible
        ScrollView {
            scrollViewProperties.scrollMode: ScrollMode.Vertical
            Container {
                layout: DockLayout {
                }
                horizontalAlignment: HorizontalAlignment.Center
                leftPadding: 15
                rightPadding: 15
                topPadding: 20

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
                    Container {
                        background: background.imagePaint
                        TextField {
                            id: titleField
                            hintText: "Title"
                            backgroundVisible: false
                        }
                        bottomMargin: 20
                    }
                    Container {
                        background: background.imagePaint
                        TextField {
                            id: urlField
                            hintText: "Story URL"
                            backgroundVisible: ! enabled
                            onTextChanging: {
                                if (text != "") {
                                    bodyField.enabled = false;
                                }
                                if (text == "") {
                                    bodyField.enabled = true;
                                }
                                if (text != "" && titleField.text != "") {
                                    submitButton.enabled = true;
                                } else {
                                    submitButton.enabled = false;
                                }
                            }
                        }
                        bottomMargin: 20
                    }
                    Container {
                        background: background.imagePaint
                        TextArea {
                            id: bodyField
                            enabled: true
                            hintText: "Text body "
                            backgroundVisible: ! enabled
                            autoSize.maxLineCount: 10
                            minHeight: 200
                            onTextChanging: {
                                if (text != "") {
                                    urlField.enabled = false
                                }
                                if (text == "") {
                                    urlField.enabled = true
                                }
                                if (text != "" && titleField.text != "") {
                                    submitButton.enabled = true
                                } else {
                                    submitButton.enabled = false;
                                }
                            }
                        }
                        bottomMargin: 20
                    }
                    Container {
                        id: helpContainer
                        Label {
                            text: "Text surrounded by asterisks will be italicized"
                            bottomMargin: 0
                            topMargin: 0
                            textStyle.fontSizeValue: 5
                            textStyle.base: lightStyle.style
                            textStyle.fontStyle: FontStyle.Italic
                        }
                        Label {
                            text: "Lines starting with 4 spaces will be wrapped in code tags" 
                            bottomMargin: 0
                            topMargin: 0
                            textStyle.fontSizeValue: 5
                            textStyle.base: lightStyle.style
                            textStyle.fontStyle: FontStyle.Italic
                        }
                        Label {
                            text: "Posting as: " + "<span style='color:#ff8e00'>" + settings.username + "</span>"
                            bottomMargin: 0
                            textStyle.fontSizeValue: 6
                            topMargin: 0
                            textStyle.base: lightStyle.style
                            textFormat: TextFormat.Html
                            textStyle.fontStyle: FontStyle.Italic
                        }
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Button {
                            horizontalAlignment: HorizontalAlignment.Center
                            id: submitButton
                            enabled: false
                            text: "Submit"
                            onClicked: {
                                Tart.send('postStory', {
                                        title: titleField.text,
                                        url: urlField.text,
                                        text: bodyField.text
                                    });
                            }
                        }
                        Button {
                            leftMargin: 150
                            horizontalAlignment: HorizontalAlignment.Center
                            text: "Cancel"
                            onClicked: {
                                Application.menuEnabled = true;
                                sheet.close();
                            }
                        }
                    }
                }
            }

        }
    }
}
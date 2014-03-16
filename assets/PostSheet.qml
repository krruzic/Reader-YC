import bb.cascades 1.2
import bb.system 1.0
import "tart.js" as Tart

Sheet {
    id: sheet
    peekEnabled: false
    ActionBar.placement: ActionBarPlacement.Default
    Page {
        function onStoryPosted(data) {
        	if (data.result == 'true') {
        	    resultToast.body = "Story successfully posted!"
        	    resultToast.cancel();
        	    resultToast.show();
        	    sheet.close();
        	}
        	else {
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
                leftPadding: 10
                rightPadding: 10
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
                                    bodyField.enabled = false
                                }
                                if (text == "") {
                                    bodyField.enabled = true
                                }
                                if (text != "" && titleField.text != "") {
                                    submitButton.enabled = true
                                }
                            }
                        }
                        bottomMargin: 20
                    }
                    Container {
                        background: background.imagePaint
                        TextArea {
                            id: bodyField
                            enabled: false
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
                                }
                            }
                        }
                        bottomMargin: 20
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
                                sheet.close();
                            }
                        }
                    }
                }
            }

        }
    }
}
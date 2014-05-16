import bb.cascades 1.2
//import "tart.js" as Tart
Page {
    id: webPane
    property alias htmlContent: webDisplay.url
    property alias html: webDisplay.html
    property alias text: titleBar.text
    //    onCreationCompleted: {
    //        Tart.register(webPane);
    //    }

    onCreationCompleted: {
        TitleBarScrollBehavior = TitleBarScrollBehavior.NonSticky;
        actionBarAutoHideBehavior = actionBarAutoHideBehavior.HideOnScroll;
    }
    actions: [
        //        ActionItem {
        //            ActionBar.placement: ActionBarPlacement.OnBar
        //            imageSource: "asset:///images/icons/ic_comments.png"
        //            title: "View Comments"
        //            onTriggered: {
        //                var page = commentPage.createObject();
        //                page.htmlContent = articleLink;
        //                page.text = commentPane.title;
        //                root.activePane.push(page);
        //            }
        //        },
        InvokeActionItem {
            title: "Open in Browser"
            imageSource: "asset:///images/icons/ic_open_link.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            id: browserQuery
            //query.mimeType: "text/plain"
            query.invokeActionId: "bb.action.OPEN"
            query.uri: htmlContent
            query.invokeTargetId: "sys.browser"
            query.onQueryChanged: {
                browserQuery.query.updateQuery();
            }
        },
        InvokeActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "Share"
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                data = text + "\n" + htmlContent + "\n" + "Shared using Reader YC ";
            }
        },
        ActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///images/icons/ic_previous.png"
            title: "Go Back"
            enabled: webDisplay.canGoBack
            onTriggered: {
                webDisplay.goBack();
            }
        },
        ActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///images/icons/ic_next.png"
            title: "Go Forward"
            enabled: webDisplay.canGoForward
            onTriggered: {
                webDisplay.goForward();
            }
        }
    ]
    titleBar: HNTitleBar {
        id: titleBar
        listName: scrollView
        onRefreshPage: {
            console.log(listName);
            webDisplay.reload();
            refreshEnabled = false;
        }
        showButton: true
        refreshEnabled: true
    }
    Container {
        Container {
            layout: DockLayout {

            }

            // This recipe shows how the WebView can be used. The signal handlers of
            // the Control are used to show loading progress in a ProgressBar.

            // To enable scrolling in the WebView, it is put inside a ScrollView.
            ScrollView {
                id: scrollView
                // We let the scroll view scroll in both x and y and enable zooming,
                // max and min content zoom property is set in the WebViews onMinContentScaleChanged
                // and onMaxContentScaleChanged signal handlers.
                scrollRole: ScrollRole.Main
                scrollViewProperties {
                    scrollMode: ScrollMode.Both
                    pinchToZoomEnabled: true
                }
                WebView {
                    id: webDisplay

                    // WebView settings, initial scaling and width used by the WebView when displaying its content.
                    settings.viewport: {
                        "width": "device-width",
                        "initial-scale": 1.0
                    }

                    onLoadProgressChanged: {
                        // Update the ProgressBar while loading.
                        progressIndicator.value = loadProgress / 100.0
                    }

                    onMinContentScaleChanged: {
                        // Update the scroll view properties to match the content scale
                        // given by the WebView.
                        scrollView.scrollViewProperties.minContentScale = minContentScale;

                        // Let's show the entire page to start with.
                        scrollView.zoomToPoint(0, 0, minContentScale, ScrollAnimation.None)
                    }

                    onMaxContentScaleChanged: {
                        // Update the scroll view properties to match the content scale
                        // given by the WebView.
                        scrollView.scrollViewProperties.maxContentScale = maxContentScale;
                    }

                    onLoadingChanged: {

                        if (loadRequest.status == WebLoadStatus.Started) {
                            // Show the ProgressBar when loading started.
                            progressIndicator.opacity = 1.0
                        } else if (loadRequest.status == WebLoadStatus.Succeeded) {
                            // Hide the ProgressBar when loading is complete.
                            progressIndicator.opacity = 0.0
                            titleBar.refreshEnabled = true;
                        } else if (loadRequest.status == WebLoadStatus.Failed) {
                            // If loading failed, fallback a local html file which will also send a java script message
                            progressIndicator.opacity = 0.0
                        }
                    }
                }
            } // ScrollView

            // A progress indicator that is used to show the loading status
            Container {
                bottomPadding: 25
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Bottom

                ProgressIndicator {
                    id: progressIndicator
                    opacity: 0
                }
            }
        }
    }
}
import bb.cascades 1.0

NavigationPane {
    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }

    Page {
        Container {
            HNTitleBar {
                id: titleBar
                text: "Reader|YC - Favourites"
                showButton: false
            }
        }
    }
}

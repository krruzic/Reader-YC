import bb.cascades 1.0

Page {
    id: thisPage

    property bool populating: true

    titleBar: TitleBar {
        title: qsTr("Settings")
    }

    ScrollView {
        Container {
            horizontalAlignment: HorizontalAlignment.Fill

            DropDown {
                id: f_temp_units

                title: qsTr("Temperature")

                Option {
                    text: 'Celsius (\u00b0C)'
                    value: 'C'
                    selected : true
                }

                Option {
                    text: 'Fahrenheit (\u00b0F)'
                    value: 'F'
                }

                onSelectedValueChanged: {
                    if (!populating) {  // avoid spurious signal during setup
                        settings.metric = (selectedValue == 'C');
                    }
                }
            }

        }// Container
    }// ScrollView

    // preselect a DropDown to the Option with the given value
    function preselectDropDown(dropdown, value) {
        if (dropdown.selectedValue == value)  // skip if already selected
            return true;

        var count = dropdown.count();
        for (var i = 0; i < count; i++) {
            var option = dropdown.at(i);
            if (option.value == value) {
                dropdown.selectedIndex = i;
                return true;
            }
        }
        return false;
    }

    onCreationCompleted: {
        preselectDropDown(f_temp_units, settings.metric ? 'C' : 'F');

        populating = false;
    }

}// Page

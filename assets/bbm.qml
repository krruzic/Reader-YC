//
//
//Snippets for BBM invite to download in Tart:
//
//function onBbmAccess(data) {
//print('BBM: onBbmAccess', data.state, data.text);
//bbm_access = data.state;
//
//if (bbm_access == 0 && invite_pending) {
//print('invite is pending');
//Tart.send('bbmSendDownloadInvitation');
//}
//
//// auto-register if unregistered
//if (settings.bbmAllowed && bbm_access == 2) {
//print('auto-registering');
//Tart.send('bbmRegister');
//}
//}
//
//In a button onClicked:
//settings.bbmAllowed = !settings.bbmAllowed;
//
//if (settings.bbmAllowed && bbm_access != 0)
//Tart.send('bbmRegister');
//
//And a Button for the invite:
//Button {
//horizontalAlignment: HorizontalAlignment.Center
//
//text: qsTr("Invite to Download")
//
//onClicked: {
//if (bbm_access == 0)
//Tart.send('bbmSendDownloadInvitation');
//else {
//invite_pending = true;
//Tart.send('bbmRegister');
//cancelInviteTimer.start(5000);
//}
//}
//
//attachedObjects: [
//QTimer {
//id: cancelInviteTimer
//singleShot: true
//onTimeout: {
//print('cancel stale invite');
//invite_pending = false;
//}
//}
//]
//}
//

import QtQuick 2.14
import QtQuick.Window 2.2
import QtWayland.Compositor 1.14
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.1
import QtSensors 5.11
//import Process 1.0

WaylandOutput {
    id: compositor
    property variant formatDateTimeString: "HH:mm"
    property variant batteryPercentage: "56"
    property variant simPercentage: "27"
    property variant queue: []
    property bool batteryCharging: false

    property real pitch: 0.0
    property real roll: 0.0
    readonly property double radians_to_degrees: 180 / Math.PI
    property variant orientation: 0
    property variant sensorEnabled: true 

    property real unlockBrightness: 0.5

    property int drawerMargin: 5*shellScaleFactor
    property string nextAtmospherePath: "file://usr/share/atmospheres/city/"
    property color atmosphereForeground: "#ffffff"

    property XdgSurface keyboard: null
   scaleFactor: 2
    function handleShellSurface(shellSurface, toplevel) {
        shellSurfaces.insert(appScreen.shellSurfaceIdx + 1, {shellSurface: shellSurface});
        toplevel.sendResizing(Qt.size(view.width, view.height - content.keyboardHeight - 20 * shellScaleFactor));
        appScreen.shellSurface = shellSurface;
        appScreen.shellSurfaceIdx += 1;
        root.oldState = root.state;
        root.state = "appScreen";
    }

    function lock() {
        if (screenLockState.state == "closed") {
            screenLockState.state = "locked";
            settings.SetBrightness(settings.GetMaxBrightness() * unlockBrightness);
        } else {
            screenLockState.state = "closed";
            unlockBrightness = settings.GetBrightness() / settings.GetMaxBrightness();
            settings.SetBrightness(0);
        }
    }

    function addModem(n) {
        settingSheet.addModem(n);
    }

    function setCellularName(n, name) {
        settingSheet.setCellularName(n, name);
    }

    function setCellularStrength(n, strength) {
        settingSheet.setCellularStrength(n, strength);
        if (n == 1) { 
            setting.setCellularStrength(strength);
        }
    } 

    function setWifiName(name) {
        settingSheet.setWifiName(name);
    }

    function setWifiStrength(strength) {
        settingSheet.setWifiStrength(strength);
        setting.setWifiStrength(strength);
    }   

    Item {
        id: root
        property string oldState: "homeScreen"
        state: "homeScreen" 
        states: [
            State{
                name: "homeScreen"
                PropertyChanges { target: homeScreen; opacity: 1 }
                PropertyChanges { target: appScreen; opacity: 0 }
                PropertyChanges { target: notificationScreen; opacity: 0 }
            },
            State {
                name: "appScreen"
                PropertyChanges { target: homeScreen; opacity: 0 }
                PropertyChanges { target: appScreen; opacity: 1 }
                PropertyChanges { target: notificationScreen; opacity: 0 }
            },
            State {
                name: "notificationScreen"
                PropertyChanges { target: homeScreen; opacity: 0 }
                PropertyChanges { target: appScreen; opacity: 0 }
                PropertyChanges { target: notificationScreen; opacity: 1 }
            }
        ]

        transitions: [
           Transition {
                to: "*"
                NumberAnimation { target: notificationScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
                NumberAnimation { target: homeScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
                NumberAnimation { target: appScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
           }

        ]
    }

    Item {
        id: screenLockState
        state: "locked" 
        states: [
            State{
                name: "closed"
                PropertyChanges { target: lockscreen; opacity: 1; y: 0 }
            },
            State {
                name: "locked"
                PropertyChanges { target: lockscreen; opacity: 1; y: 0 }
            },
            State {
                name: "opened"
                PropertyChanges { target: lockscreen; opacity: 0; y: -view.height }
            }
        ]

        transitions: [
           Transition {
                to: "locked, opened"
                NumberAnimation { target: lockscreen; properties: "opacity"; duration: 200; easing.type: Easing.InOutQuad; }
           }

        ]
    }

    Item {
        id: launcherState
        state: "closed" 
        states: [
            State {
                name: "opened"
                PropertyChanges { target: launcherSheet; y: 0; opacity: 1 }
            },
            State {
                name: "closed"
                PropertyChanges { target: launcherSheet; y: view.height; opacity: 0 }
            },
            State {
                name: "opening"
                PropertyChanges { target: launcherSheet; y: 0 }
            },
            State {
                name: "closing"
                PropertyChanges { target: launcherSheet; y: 0 }
            }
        ]

        transitions: [
           Transition {
                to: "*"
                NumberAnimation { target: launcherSheet; properties: "opacity"; duration: 600; easing.type: Easing.InOutQuad; }
           }
        ]
    }

    Item {
        id: settingsState
        state: "closed" 
        states: [
            State {
                name: "opened"
                PropertyChanges { target: settingSheet; y: 0; opacity: 1 }
                PropertyChanges { target: setting; opacity: 1 }
            },
            State {
                name: "closed"
                PropertyChanges { target: settingSheet; y: -view.height; opacity: 0 }
                PropertyChanges { target: setting; opacity: 1 }
            },
            State {
                name: "opening"
                PropertyChanges { target: settingSheet; y: 0 }
                PropertyChanges { target: setting; opacity: 0 }
            },
            State {
                name: "closing"
                PropertyChanges { target: settingSheet; y: 0 }
                PropertyChanges { target: setting; opacity: 0 }
            }
        ]

        transitions: [
           Transition {
                to: "*"
                NumberAnimation { target: settingSheet; properties: "opacity"; duration: 800; easing.type: Easing.InOutQuad; }
           },
           Transition {
                to: "opening"
                ParallelAnimation {
                    NumberAnimation { target: setting; properties: "opacity"; duration: 800; easing.type: Easing.InOutQuad; }
                    SequentialAnimation {
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InOutQuad; to: 10 * shellScaleFactor }
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InOutQuad; to: -10 * shellScaleFactor }
                    }
                }
           },
           Transition {
                to: "closing"
                ParallelAnimation {
                    NumberAnimation { target: setting; properties: "opacity"; duration: 800; easing.type: Easing.InOutQuad; }
                    SequentialAnimation {
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InOutQuad; to: -10 * shellScaleFactor }
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 300; easing.type: Easing.InOutQuad; to: 10 * shellScaleFactor }
                    }
                }
           },
           Transition {
                to: "opened"
                ParallelAnimation {
                    NumberAnimation { target: setting; properties: "opacity"; duration: 800; easing.type: Easing.InOutQuad; }
                    SequentialAnimation {
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 0; easing.type: Easing.InOutQuad; to: -10 * shellScaleFactor }
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 600; easing.type: Easing.InOutQuad; to: 0 }
                    }
                }
           },
           Transition {
                to: "closed"
                ParallelAnimation {
                    NumberAnimation { target: setting; properties: "opacity"; duration: 800; easing.type: Easing.InOutQuad; }
                    SequentialAnimation {
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 0; easing.type: Easing.InOutQuad; to: 10 * shellScaleFactor }
                        NumberAnimation { target: setting; properties: "anchors.topMargin"; duration: 600; easing.type: Easing.InOutQuad; to: 0 }
                    }
                }
           }
        ]
    }

    sizeFollowsWindow: true
    window: Window {
        visible: true
        width: 222 * shellScaleFactor
        height: 370 * shellScaleFactor
        Rectangle {
            id: view 
            color: "#2E3440"
            anchors.fill: parent
            //rotation: orientation

            Rectangle { anchors.fill: parent; color: '#2E3440' }

           // Process { id: process }

            //Component {
              //  id: procComponent
                //Process {}
            //}

            FontLoader {
                id: icon
                source: "qrc:/fonts/Font Awesome 5 Free-Solid-900.otf"
            }

            Rectangle {
                id: content 
                anchors.fill: parent

                property real keyboardHeight: 0

                Item {
                    id: realWallpaper
                    anchors.fill: parent
                    z: 100
                    Image {
                        z: 100
                        id: wallpaper
                        anchors.fill: parent
                        source: atmospherePath + "wallpaper.jpg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    Image {
                        z: 101
                        id: nextWallpaper
                        anchors.fill: parent
                        source: nextAtmospherePath + "wallpaper.jpg"
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0
                        state: "normal"
                        states: [
                            State {
                                name: "changing"
                                PropertyChanges { target: nextWallpaper; opacity: 1 }
                            },
                            State {
                                name: "normal"
                                PropertyChanges { target: nextWallpaper; opacity: 0 }
                            }
                        ]

                        transitions: Transition {
                            to: "normal"

                            NumberAnimation {
                                target: nextWallpaper
                                properties: "opacity"
                                easing.type: Easing.InOutQuad
                                duration: 500
                            }
                        }
                    }
                }

                AppScreen { id: appScreen; focus: true }
                HomeScreen { id: homeScreen }
                NotificationScreen { id: notificationScreen }

                SettingSheet { id: settingSheet } 
                LauncherSheet { id: launcherSheet } 

                StatusArea { id: setting }
                LauncherSwipe { id: lSwipe }

                LockScreen { id: lockscreen }
            }
        }
        Loader {
            source: "Keyboard.qml"
        }
    }
}

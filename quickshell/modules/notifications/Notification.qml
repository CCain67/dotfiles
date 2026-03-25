pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../../components"
import "../../services"
import "../../config"
import "../../utils"

StyledRect {
    id: root

    required property NotifData modelData

    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property bool isCritical: modelData.urgency === NotificationUrgency.Critical
    readonly property int bodyTextFormat: /[<*_`#\[\]]/.test(modelData.body) ? Text.MarkdownText : Text.PlainText

    property bool expanded: Config.notifs.openExpanded

    // Content height including padding — drives the animated implicitHeight on inner
    readonly property real nonAnimHeight: Math.max(
        iconArea.height,
        actionsRow.y + actionsRow.height
    ) + Appearance.padding.normal *2

    color: root.isCritical ? Colors.palette.m3secondaryContainer : Colors.palette.m3surfaceContainerHigh
    radius: Appearance.rounding.normal
    implicitWidth: Config.notifs.width
    implicitHeight: inner.implicitHeight

    // Slide in from right on creation
    x: Config.notifs.width
    Component.onCompleted: {
        x = 0;
        modelData.lock(this);
    }
    Component.onDestruction: modelData.unlock(this)

    Behavior on x {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
        }
    }

    MouseArea {
        property int startY

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        drag.target: parent
        drag.axis: Drag.XAxis
        cursorShape: pressed ? Qt.ClosedHandCursor : undefined

        onEntered: root.modelData.timer.stop()
        onExited: { if (!pressed) root.modelData.timer.start(); }

        onPressed: event => {
            root.modelData.timer.stop();
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.close();
        }

        onReleased: {
            if (!containsMouse) root.modelData.timer.start();
            if (Math.abs(root.x) < Config.notifs.width * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }

        onPositionChanged: event => {
            if (pressed) {
                const dy = event.y - startY;
                if (Math.abs(dy) > Config.notifs.expandThreshold)
                    root.expanded = dy > 0;
            }
        }

        onClicked: event => {
            if (!Config.notifs.actionOnClick || event.button !== Qt.LeftButton) return;
            const acts = root.modelData.actions;
            if (acts.length === 1) acts[0].invoke();
        }

        Item {
            id: inner

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.padding.normal

            implicitHeight: root.nonAnimHeight

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            // Icon area (always allocated for anchor reference)
            Item {
                id: iconArea

                anchors.left: parent.left
                anchors.top: parent.top
                width: Config.notifs.sizes.image
                height: Config.notifs.sizes.image

                // Image (app-provided, e.g. album art)
                Loader {
                    id: imageLoader

                    asynchronous: true
                    active: root.hasImage
                    anchors.fill: parent

                    sourceComponent: StyledClippingRect {
                        radius: Appearance.rounding.full

                        Image {
                            anchors.fill: parent
                            source: Qt.resolvedUrl(root.modelData.image)
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: Config.notifs.sizes.image
                            sourceSize.height: Config.notifs.sizes.image
                            cache: false
                            asynchronous: true
                        }
                    }
                }

                // App icon — centered when no image, badge (bottom-right) when image present
                Loader {
                    id: appIconLoader

                    asynchronous: true
                    active: root.hasAppIcon || !root.hasImage

                    anchors.horizontalCenter: !root.hasImage ? parent.horizontalCenter : undefined
                    anchors.verticalCenter: !root.hasImage ? parent.verticalCenter : undefined
                    anchors.right: root.hasImage ? parent.right : undefined
                    anchors.bottom: root.hasImage ? parent.bottom : undefined

                    sourceComponent: StyledRect {
                        radius: Appearance.rounding.full
                        visible: !root.hasAppIcon
                        color: root.isCritical
                            ? Colors.palette.m3error
                            : root.modelData.urgency === NotificationUrgency.Low
                                ? Colors.palette.m3surfaceContainerHighest
                                : Colors.palette.m3secondaryContainer
                        implicitWidth: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image
                        implicitHeight: root.hasImage ? Config.notifs.sizes.badge : Config.notifs.sizes.image

                        MaterialIcon {
                            anchors.centerIn: parent
                            visible: !root.hasAppIcon
                            text: Icons.getNotifIcon(root.modelData.summary, root.modelData.urgency)
                            color: root.isCritical
                                ? Colors.palette.m3onError
                                : Colors.palette.m3onSecondaryContainer
                            font.pointSize: Appearance.font.size.large
                        }
                    }
                }
            }

            // App name — shown only when expanded, animates height
            StyledText {
                id: appName

                anchors.top: parent.top
                anchors.left: iconArea.right
                anchors.leftMargin: Appearance.spacing.smaller
                anchors.right: expandBtn.left
                anchors.rightMargin: Appearance.spacing.small

                text: root.modelData.appName
                maximumLineCount: 1
                elide: Text.ElideRight
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                height: root.expanded
                clip: true
                opacity: root.expanded ? 1 : 0

                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.standard
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: Appearance.anim.durations.normal }
                }
            }

            // Summary (always visible, sits just below appName)
            StyledText {
                id: summary

                anchors.top: appName.bottom
                anchors.left: iconArea.right
                anchors.leftMargin: Appearance.spacing.smaller
                anchors.right: time.left
                anchors.rightMargin: Appearance.spacing.small

                text: root.modelData.summary
                maximumLineCount: 1
                elide: Text.ElideRight
                height: implicitHeight
            }

            // Time separator + timestamp
            StyledText {
                id: timeSep
                anchors.top: parent.top
                anchors.right: time.left
                anchors.rightMargin: Appearance.spacing.small
                text: "•"
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                id: time
                anchors.top: parent.top
                anchors.right: expandBtn.left
                anchors.rightMargin: Appearance.spacing.small
                text: root.modelData.timeStr
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            // Expand / collapse button
            Item {
                id: expandBtn

                anchors.top: parent.top
                anchors.right: parent.right
                implicitWidth: expandIcon.implicitHeight
                implicitHeight: expandIcon.implicitHeight

                StateLayer {
                    function onClicked() { root.expanded = !root.expanded; }
                    radius: Appearance.rounding.full
                    color: Colors.palette.m3onSurface
                }

                MaterialIcon {
                    id: expandIcon
                    anchors.centerIn: parent
                    text: root.expanded ? "expand_less" : "expand_more"
                    font.pointSize: Appearance.font.size.normal
                }
            }

            // Body preview — one line when collapsed
            StyledText {
                id: bodyPreview

                anchors.top: summary.bottom
                anchors.left: summary.left
                anchors.right: expandBtn.left
                anchors.rightMargin: Appearance.spacing.small

                textFormat: root.bodyTextFormat
                text: root.modelData.body
                maximumLineCount: 1
                elide: Text.ElideRight
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                opacity: root.expanded ? 0 : 1

                Behavior on opacity {
                    NumberAnimation { duration: Appearance.anim.durations.normal }
                }
            }

            // Full body — shown when expanded
            StyledText {
                id: body

                anchors.top: summary.bottom
                anchors.left: summary.left
                anchors.right: expandBtn.left
                anchors.rightMargin: Appearance.spacing.small

                textFormat: root.bodyTextFormat
                text: root.modelData.body
                color: Colors.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                height: text.length > 0 ? implicitHeight : 0

                onLinkActivated: link => {
                    if (!root.expanded) return;
                    Qt.openUrlExternally(link);
                    root.modelData.popup = false;
                }

                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: Appearance.anim.durations.normal }
                }
            }

            // Action buttons — shown when expanded
            RowLayout {
                id: actionsRow

                anchors.top: body.bottom
                anchors.topMargin: Appearance.spacing.small
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: Appearance.spacing.smaller
                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: Appearance.anim.durations.normal }
                }

                ActionButton {
                    modelData: QtObject {
                        readonly property string text: qsTr("Got it")
                        function invoke(): void { root.modelData.close(); }
                    }
                }

                Repeater {
                    model: root.modelData.actions
                    delegate: Component { ActionButton {} }
                }
            }
        }
    }

    component ActionButton: StyledRect {
        id: actionBtn

        required property var modelData

        radius: Appearance.rounding.full
        color: root.isCritical
            ? Colors.palette.m3secondary
            : Colors.palette.m3surfaceContainerHighest

        implicitWidth: btnLabel.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: btnLabel.implicitHeight + Appearance.padding.small * 2

        StateLayer {
            function onClicked(): void { actionBtn.modelData.invoke(); }
            radius: Appearance.rounding.full
            color: Colors.palette.m3onSurface
        }

        StyledText {
            id: btnLabel
            anchors.centerIn: parent
            text: actionBtn.modelData.text
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 120)
            color: root.isCritical
                ? Colors.palette.m3onSecondary
                : Colors.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }
    }
}

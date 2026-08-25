pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// Now-playing card driven by the Player service. The reference design's
// visualiser is a plain seek bar here — no cava dependency.
Card {
    id: root

    RowLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.large

        // Album art, with a note-icon placeholder when there's no artwork
        StyledClippingRect {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 132
            implicitHeight: 132
            radius: Appearance.rounding.normal
            color: Colors.palette.m3surfaceContainerHighest
            border.width: 1
            border.color: Colors.palette.m3outlineVariant

            layer.enabled: !Theme.flat
            layer.effect: Elevation {
                level: "low"
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: "music_note"
                color: Colors.palette.m3outline
                font.pointSize: Appearance.font.size.extraLarge
                visible: art.status !== Image.Ready
            }

            Image {
                id: art

                anchors.fill: parent
                source: Player.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: status === Image.Ready
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.small

            Item {
                Layout.fillHeight: true
            }

            StyledText {
                Layout.fillWidth: true
                text: Player.title
                font.pointSize: Appearance.font.size.large
                font.weight: 500
                color: Colors.palette.m3onSurface
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: Player.artist || Player.identity
                font.pointSize: Appearance.font.size.normal
                color: Colors.palette.m3onSurfaceVariant
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Item {
                Layout.fillHeight: true
            }

            // Seek bar
            Item {
                Layout.fillWidth: true
                Layout.topMargin: Appearance.spacing.small
                implicitHeight: 8

                Rectangle {
                    id: seekTrack

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: 6
                    radius: Appearance.rounding.full
                    color: Colors.palette.m3surfaceContainerLowest

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Player.progress
                        radius: parent.radius
                        color: Colors.palette.m3primary

                        Behavior on width { Anim { duration: Appearance.anim.durations.small } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: Player.canSeek
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: event => Player.seekFraction(event.x / width)
                }
            }

            // Times + transport
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                StyledText {
                    text: Player.formatTime(Player.position)
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.mono
                    color: Colors.palette.m3outline
                }

                Item {
                    Layout.fillWidth: true
                }

                TransportButton {
                    icon: "skip_previous"
                    enabled: Player.canGoPrevious
                    onTriggered: Player.previous()
                }

                TransportButton {
                    icon: Player.isPlaying ? "pause" : "play_arrow"
                    primary: true
                    enabled: Player.hasPlayer
                    onTriggered: Player.togglePlaying()
                }

                TransportButton {
                    icon: "skip_next"
                    enabled: Player.canGoNext
                    onTriggered: Player.next()
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    text: Player.formatTime(Player.length)
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.mono
                    color: Colors.palette.m3outline
                }
            }
        }
    }

    component TransportButton: Rectangle {
        id: button

        required property string icon
        property bool primary: false

        signal triggered

        implicitWidth: primary ? 40 : 34
        implicitHeight: primary ? 40 : 34
        radius: Appearance.rounding.full
        color: primary ? Colors.palette.m3primary : Colors.palette.m3surfaceContainerHighest
        opacity: enabled ? 1 : 0.35

        Behavior on color { CAnim {} }
        Behavior on opacity { Anim { duration: Appearance.anim.durations.small } }

        StateLayer {
            disabled: !button.enabled
            radius: parent.radius
            color: button.primary ? Colors.palette.m3onPrimary : Colors.palette.m3onSurface

            function onClicked(): void {
                button.triggered();
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: button.icon
            color: button.primary ? Colors.palette.m3onPrimary : Colors.palette.m3onSurface
            font.pointSize: button.primary ? Appearance.font.size.larger : Appearance.font.size.normal
            fill: 1
        }
    }
}

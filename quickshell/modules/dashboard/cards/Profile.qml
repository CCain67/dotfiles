import QtQuick
import QtQuick.Layouts
import "../../../components"
import "../../../config"
import "../../../services"

// User identity card: avatar, username, user@host, and a session-status pill.
Card {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        // Avatar, falling back to a person glyph when no image is configured
        StyledClippingRect {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 68
            implicitHeight: 68
            radius: Appearance.rounding.full
            color: Colors.palette.m3surfaceContainerHighest

            MaterialIcon {
                anchors.centerIn: parent
                text: "person"
                color: Colors.palette.m3primary
                font.pointSize: Appearance.font.size.extraLarge
                fill: 1
                visible: avatar.status !== Image.Ready
            }

            Image {
                id: avatar

                anchors.fill: parent
                source: Config.dashboard.avatar
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.spacing.small
            text: SysInfo.user
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
            color: Colors.palette.m3onSurface
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: `${SysInfo.user}@${SysInfo.host}`
            font.pointSize: Appearance.font.size.small
            font.family: Appearance.font.family.mono
            color: Colors.palette.m3outline
        }

        // Status pill
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.spacing.small
            implicitWidth: statusRow.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: statusRow.implicitHeight + Appearance.padding.small * 2
            radius: Appearance.rounding.full
            color: Qt.alpha(Colors.green, 0.16)

            RowLayout {
                id: statusRow

                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                Rectangle {
                    implicitWidth: 7
                    implicitHeight: 7
                    radius: Appearance.rounding.full
                    color: Colors.green
                }

                StyledText {
                    text: "Alive (Probably)"
                    font.pointSize: Appearance.font.size.small
                    color: Colors.green
                }
            }
        }
    }
}

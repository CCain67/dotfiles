pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../components"
import "../../config"
import "../../services"

// Filtered list of desktop entries. Requires searchText and visibilities.
// launchCurrent() launches the highlighted entry and should be called on Enter.
ListView {
    id: root

    required property string searchText
    required property DrawerVisibilities visibilities

    function launchCurrent(): void {
        if (currentItem)
            currentItem.launchApp()
    }

    property var filteredApps: {
        const entries = DesktopEntries.applications.values
        const text = searchText.toLowerCase()
        const matched = text
            ? entries.filter(a =>
                a.name.toLowerCase().includes(text) ||
                (a.comment && a.comment.toLowerCase().includes(text)) ||
                (a.genericName && a.genericName.toLowerCase().includes(text)))
            : entries.slice().sort((a, b) => a.name.localeCompare(b.name))
        return matched.slice(0, Config.launcher.maxShown)
    }

    model: filteredApps
    onSearchTextChanged: currentIndex = 0

    implicitWidth: Config.launcher.itemWidth
    implicitHeight: (Config.launcher.itemHeight + spacing) * Math.min(count, Config.launcher.maxShown) - spacing

    spacing: Appearance.spacing.small
    clip: true

    highlight: Rectangle {
        width: root.width
        height: root.currentItem?.height ?? 0
        radius: Appearance.rounding.normal
        color: Colors.palette.m3onSurface
        opacity: 0.08
    }
    highlightFollowsCurrentItem: true
    highlightMoveDuration: Appearance.anim.durations.small

    delegate: Item {
        id: delegateItem

        required property var modelData
        required property int index

        function launchApp(): void {
            const entry = modelData
            const base = Array.from(entry.command)
            Quickshell.execDetached({
                command: entry.runInTerminal ? [Config.terminal, "-e", ...base] : base,
                workingDirectory: entry.workingDirectory || ""
            })
        }

        width: root.width
        implicitHeight: Config.launcher.itemHeight

        StateLayer {
            function onClicked(): void {
                delegateItem.launchApp()
                root.visibilities.launcher = false
            }
            radius: Appearance.rounding.normal
        }

        IconImage {
            id: appIcon
            asynchronous: true
            source: Quickshell.iconPath(delegateItem.modelData.icon ?? "", "image-missing")
            implicitSize: parent.height * 0.65
            anchors.left: parent.left
            anchors.leftMargin: Appearance.padding.larger
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: appIcon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.right: parent.right
            anchors.rightMargin: Appearance.padding.larger
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: appName.implicitHeight + appComment.implicitHeight

            StyledText {
                id: appName
                text: delegateItem.modelData.name ?? ""
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                id: appComment
                anchors.top: appName.bottom
                text: delegateItem.modelData.comment ?? delegateItem.modelData.genericName ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colors.palette.m3outline
                elide: Text.ElideRight
                width: parent.width
                visible: text.length > 0
            }
        }
    }
}

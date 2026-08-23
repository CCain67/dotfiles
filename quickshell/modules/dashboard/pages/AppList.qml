pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../../components"
import "../../../config"
import "../../../services"

// Filtered list of desktop entries. Requires searchText; emits launched() after
// starting an app so the host can dismiss itself.
//
// Unlike the old bar launcher this list is not capped — it fills whatever height
// the host gives it and scrolls, so selection moves must keep the highlight in
// view (see selectNext/selectPrev).
ListView {
    id: root

    required property string searchText

    signal launched

    function launchCurrent(): void {
        if (currentItem)
            currentItem.launchApp();
    }

    function selectNext(): void {
        incrementCurrentIndex();
        positionViewAtIndex(currentIndex, ListView.Contain);
    }

    function selectPrev(): void {
        decrementCurrentIndex();
        positionViewAtIndex(currentIndex, ListView.Contain);
    }

    property var filteredApps: {
        const entries = DesktopEntries.applications.values;
        const text = searchText.toLowerCase();
        return text ? entries.filter(a => a.name.toLowerCase().includes(text) || (a.comment && a.comment.toLowerCase().includes(text)) || (a.genericName && a.genericName.toLowerCase().includes(text))) : entries.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    model: filteredApps

    onSearchTextChanged: {
        currentIndex = 0;
        positionViewAtBeginning();
    }

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
            const entry = modelData;
            const base = Array.from(entry.command);
            Quickshell.execDetached({
                command: entry.runInTerminal ? [Config.terminal, "-e", ...base] : base,
                workingDirectory: entry.workingDirectory || ""
            });
        }

        width: root.width
        implicitHeight: Config.launcher.itemHeight

        StateLayer {
            function onClicked(): void {
                delegateItem.launchApp();
                root.launched();
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

import Quickshell

PersistentProperties {
    property bool bar
    property bool session
    property bool dashboard

    // Which dashboard page is showing: "info" (card grid), "apps" (launcher) or
    // "themes" (colour theme picker).
    property string page: "info"
}

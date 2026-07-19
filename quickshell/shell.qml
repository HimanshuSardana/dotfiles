import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// ============================
//  PillBar — Everforest theme
//  Time / Launcher / Todo list
// ============================

// ---- Everforest Dark palette ----
// bg0: #2b3339   bg1: #323d43   bg2: #3d484e
// bg3: #475258   bg4: #4f5b62   bg5: #56635f
// fg:  #d3c6aa   grey0: #7a8478  grey1: #859289
// red: #e67e80   orange: #e69875  yellow: #dbbc7f
// green: #a7c080  aqua: #83c092   blue: #7fbbb3
// purple: #d699b6

ShellRoot {
  id: root

  // ---------- IPC targets ----------
  IpcHandler {
    target: "pillbar"
    function toggle(): void { box.switchMode("launcher") }
    function open(): void { box.openMode("launcher") }
    function close(): void { box.closeMode() }
    function todo(): void { box.switchMode("todo") }
    function youtube(): void { box.switchMode("youtube") }
    function osd(type: string): void { box.showOsd(type) }
  }

  // ---------- window ----------
  PanelWindow {
    id: window
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "pillbar"
    WlrLayershell.anchors { left: true; right: true; top: true }
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: box.mode !== "time" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    implicitHeight: box.implicitHeight + 12
    color: "transparent"

    // ---------- the pill ----------
    Rectangle {
      id: box
      anchors.top: parent.top
      anchors.topMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true

      property string mode: "time"  // "time" | "launcher" | "todo" | "youtube"
      property var allApps: DesktopEntries.applications
      property bool ytSearching: false
      property bool ytSearched: false
      property string osdType: ""     // "volume" | "brightness"
      property real osdValue: 0        // 0.0 – 1.0
      property bool osdVisible: false

      readonly property bool isOpen: box.mode !== "time"

      implicitWidth: isOpen ? Math.min(540, window.width - 24) : timeRow.implicitWidth + 56
      implicitHeight: isOpen ? 500 : 40

      radius: 4
      color: isOpen ? "#2b3339" : "#1e2326"
      border.color: isOpen ? "#475258" : "#3d484e"
      border.width: 1

      Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
      Behavior on implicitHeight { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 200 } }
      Behavior on border.color { ColorAnimation { duration: 200 } }

      // ========== TIME MODE ==========
      RowLayout {
        id: timeRow
        anchors.centerIn: parent
        spacing: 8
        visible: box.mode === "time" && !box.osdVisible

        Text {
          id: timeLabel
          text: "--:--"
          color: "#d3c6aa"
          font.pixelSize: 14
          font.family: "monospace"
          font.bold: true
          horizontalAlignment: Text.AlignHCenter
          Layout.alignment: Qt.AlignCenter
        }
      }

      // ========== OSD OVERLAY ==========
      RowLayout {
        anchors.centerIn: parent
        spacing: 10
        visible: box.mode === "time" && box.osdVisible

        Text {
          text: box.osdType === "volume" ? "\uD83D\uDD0A" : "\u2600"
          color: "#d3c6aa"
          font.pixelSize: 16
        }

        Rectangle {
          width: 120
          height: 6
          radius: 3
          color: "#3d484e"

          Rectangle {
            height: parent.height
            width: parent.width * box.osdValue
            radius: 3
            color: "#a7c080"

            Behavior on width { NumberAnimation { duration: 100 } }
          }
        }

        Text {
          text: Math.round(box.osdValue * 100) + "%"
          color: "#7a8478"
          font.pixelSize: 12
          font.family: "monospace"
        }
      }

      MouseArea {
        anchors.fill: parent
        enabled: box.mode === "time"
        onClicked: box.switchMode("launcher")
        cursorShape: Qt.PointingHandCursor
      }

      // ========== LAUNCHER ==========
      Item {
        anchors.fill: parent
        anchors.margins: 12
        visible: box.mode === "launcher"
        opacity: box.mode === "launcher" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        ColumnLayout {
          anchors.fill: parent
          spacing: 10

          TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Search applications…"
            placeholderTextColor: "#7a8478"
            color: "#d3c6aa"
            font.pixelSize: 13
            leftPadding: 14
            rightPadding: 14
            topPadding: 10
            bottomPadding: 10
            selectByMouse: true

            background: Rectangle {
              radius: 4
              color: "#323d43"
              border.color: searchField.activeFocus ? "#4f5b62" : "#3d484e"
              border.width: 1
            }

            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                box.closeMode()
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (appListModel.count > 0) {
                  var item = appListModel.get(appList.currentIndex)
                  if (item && item.entry) box.launchApp(item.entry)
                }
              } else if (event.key === Qt.Key_Down ||
                         (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                appList.incrementCurrentIndex()
                appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                event.accepted = true
              } else if (event.key === Qt.Key_Up ||
                         (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                appList.decrementCurrentIndex()
                appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                event.accepted = true
              }
            }

            onTextChanged: box.populateApps(text)
          }

          ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds
            model: ListModel { id: appListModel }
            spacing: 2
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            ScrollBar.vertical: ScrollBar {
              policy: ScrollBar.AsNeeded
              width: 4
              background: Rectangle { color: "transparent" }
              contentItem: Rectangle {
                color: "#3d484e"
                radius: 2
              }
            }

            delegate: Item {
              id: appDelegate
              width: appList.width
              height: 48

              required property string name
              required property string genericName
              required property string icon
              required property var entry

              Rectangle {
                anchors.fill: parent
                radius: 4
                color: appDelegate.ListView.isCurrentItem ? "#323d43" : "transparent"
                border.color: appDelegate.ListView.isCurrentItem ? "#3d484e" : "transparent"
                border.width: 1
              }

              RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 12

                Item {
                  Layout.preferredWidth: 32
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter

                  IconImage {
                    id: appIcon
                    anchors.fill: parent
                    source: icon ? Quickshell.iconPath(icon) : ""
                    implicitSize: 32
                    asynchronous: true
                    visible: status !== Image.Error
                  }

                  Text {
                    anchors.centerIn: parent
                    text: name.charAt(0).toUpperCase()
                    color: "#a7c080"
                    font.pixelSize: 15
                    font.bold: true
                    visible: appIcon.status === Image.Error && icon !== ""
                  }
                }

                Column {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 2

                  Text {
                    text: name
                    color: "#d3c6aa"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    width: parent.width
                  }

                  Text {
                    text: genericName
                    color: "#7a8478"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    visible: genericName !== ""
                    width: parent.width
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  if (entry) box.launchApp(entry)
                }
              }
            }

            Text {
              anchors.centerIn: parent
              text: "No applications found"
              color: "#7a8478"
              font.pixelSize: 13
              visible: appList.count === 0
            }
          }
        }
      }

      // ========== TODO MODE ==========
      Item {
        anchors.fill: parent
        anchors.margins: 12
        visible: box.mode === "todo"
        opacity: box.mode === "todo" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        ColumnLayout {
          anchors.fill: parent
          spacing: 10

          // Master todo store (never filtered)
          ListModel { id: todoMasterModel }

          TextField {
            id: todoInput
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "+ task to add  |  type to filter"
            placeholderTextColor: "#7a8478"
            color: "#d3c6aa"
            font.pixelSize: 13
            leftPadding: 14
            rightPadding: 14
            topPadding: 10
            bottomPadding: 10
            selectByMouse: true

            background: Rectangle {
              radius: 4
              color: "#323d43"
              border.color: todoInput.activeFocus ? "#4f5b62" : "#3d484e"
              border.width: 1
            }

            onTextChanged: box.filterTodos(todoInput.text)

            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                box.closeMode()
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var text = todoInput.text.trim()
                if (text.startsWith("+")) {
                  var taskName = text.substring(1).trim()
                  if (taskName !== "") {
                    todoMasterModel.append({ task: taskName, done: false })
                    todoInput.text = ""
                    box.filterTodos("")
                  }
                } else if (todoFilteredModel.count > 0) {
                  var idx = todoList.currentIndex
                  var item = todoFilteredModel.get(idx)
                  if (item) {
                    for (var mi = 0; mi < todoMasterModel.count; mi++) {
                      var m = todoMasterModel.get(mi)
                      if (m.task === item.task) {
                        todoMasterModel.set(mi, { task: m.task, done: !m.done })
                        break
                      }
                    }
                    box.filterTodos(todoInput.text)
                  }
                }
              } else if (event.key === Qt.Key_Down ||
                         (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                todoList.incrementCurrentIndex()
                todoList.positionViewAtIndex(todoList.currentIndex, ListView.Contain)
                event.accepted = true
              } else if (event.key === Qt.Key_Up ||
                         (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                todoList.decrementCurrentIndex()
                todoList.positionViewAtIndex(todoList.currentIndex, ListView.Contain)
                event.accepted = true
              }
            }
          }

          // Header with count
          RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
              text: "TODO"
              color: "#d3c6aa"
              font.pixelSize: 11
              font.bold: true
              font.letterSpacing: 2
            }

            Text {
              text: "(" + todoMasterModel.count + ")"
              color: "#7a8478"
              font.pixelSize: 11
            }

            Item { Layout.fillWidth: true }

            Text {
              text: "+ to add  |  Enter to toggle"
              color: "#56635f"
              font.pixelSize: 10
            }
          }

          ListView {
            id: todoList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds
            model: ListModel { id: todoFilteredModel }
            spacing: 2
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            ScrollBar.vertical: ScrollBar {
              policy: ScrollBar.AsNeeded
              width: 4
              background: Rectangle { color: "transparent" }
              contentItem: Rectangle {
                color: "#3d484e"
                radius: 2
              }
            }

            delegate: Item {
              id: todoDelegate
              width: todoList.width
              height: 40

              required property string task
              required property bool done

              Rectangle {
                anchors.fill: parent
                radius: 4
                color: todoDelegate.ListView.isCurrentItem ? "#323d43" : "transparent"
                border.color: todoDelegate.ListView.isCurrentItem ? "#3d484e" : "transparent"
                border.width: 1
              }

              RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 10

                Rectangle {
                  Layout.preferredWidth: 18
                  Layout.preferredHeight: 18
                  Layout.alignment: Qt.AlignVCenter
                  radius: 3
                  color: "transparent"
                  border.color: done ? "#a7c080" : "#475258"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "\u2713"
                    color: "#a7c080"
                    font.pixelSize: 11
                    font.bold: true
                    visible: done
                  }
                }

                Text {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  text: task
                  color: done ? "#7a8478" : "#d3c6aa"
                  font.pixelSize: 13
                  font.strikeout: done
                  elide: Text.ElideRight
                }

                Text {
                  Layout.preferredWidth: 20
                  Layout.alignment: Qt.AlignVCenter
                  text: "\u00d7"
                  color: "#56635f"
                  font.pixelSize: 16
                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                      var taskToDel = task
                      for (var di = 0; di < todoMasterModel.count; di++) {
                        if (todoMasterModel.get(di).task === taskToDel) {
                          todoMasterModel.remove(di)
                          break
                        }
                      }
                      box.filterTodos(todoInput.text)
                    }
                    onEntered: parent.color = "#e67e80"
                    onExited: parent.color = "#56635f"
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  todoList.currentIndex = index
                  todoInput.focus = true
                }
              }
            }

            Text {
              anchors.centerIn: parent
              text: todoInput.text.trim().startsWith("+") ? "" :
                     (todoMasterModel.count === 0 ? "No tasks yet  \u2014  type + your task above" :
                      "No matching tasks")
              color: "#7a8478"
              font.pixelSize: 13
              visible: todoFilteredModel.count === 0
            }
          }
        }
      }

      // ========== YOUTUBE SEARCH ==========
      Item {
        anchors.fill: parent
        anchors.margins: 12
        visible: box.mode === "youtube"
        opacity: box.mode === "youtube" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Process {
          id: ytProcess
          running: false

          stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
              var line = data.trim()
              if (line === "") return
              var tabPos = line.indexOf("\t")
              if (tabPos >= 0) {
                var title = line.substring(0, tabPos)
                var id = line.substring(tabPos + 1)
                youtubeResults.append({ title: title, id: id })
              }
            }
          }

          onExited: function(exitCode, exitStatus) {
            box.ytSearched = true
            box.ytSearching = false
            if (youtubeResults.count > 0) {
              youtubeList.currentIndex = 0
              // Keep focus on the search field so keyboard nav still works
            }
          }
        }

        ColumnLayout {
          anchors.fill: parent
          spacing: 8

          TextField {
            id: ytInput
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: box.ytSearching ? "Searching YouTube…" : (
                               youtubeResults.count > 0 ? "Type to refine or press Enter to play" :
                               "Search YouTube…")
            placeholderTextColor: "#7a8478"
            color: "#d3c6aa"
            font.pixelSize: 13
            leftPadding: 14
            rightPadding: 14
            topPadding: 10
            bottomPadding: 10
            selectByMouse: true

            background: Rectangle {
              radius: 4
              color: "#323d43"
              border.color: ytInput.activeFocus ? "#4f5b62" : "#3d484e"
              border.width: 1
            }

            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                box.closeMode()
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (youtubeResults.count > 0 && !box.ytSearching) {
                  var item = youtubeResults.get(youtubeList.currentIndex)
                  if (item && item.id) {
                    Quickshell.execDetached(["mpv", "https://youtube.com/watch?v=" + item.id,
                                     "--ytdl-format=best"])
                    box.closeMode()
                  }
                } else {
                  var query = ytInput.text.trim()
                  if (query !== "") box.doYoutubeSearch(query)
                }
              } else if (event.key === Qt.Key_Down ||
                         (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                if (youtubeResults.count > 0) {
                  youtubeList.incrementCurrentIndex()
                  youtubeList.positionViewAtIndex(youtubeList.currentIndex, ListView.Contain)
                  event.accepted = true
                }
              } else if (event.key === Qt.Key_Up ||
                         (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                if (youtubeResults.count > 0) {
                  youtubeList.decrementCurrentIndex()
                  youtubeList.positionViewAtIndex(youtubeList.currentIndex, ListView.Contain)
                  event.accepted = true
                }
              }
            }
          }

          // Result count (always present, fixed height)
          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
            spacing: 6

            Text {
              text: youtubeResults.count > 0 ? "YOUTUBE (" + youtubeResults.count + ")" : ""
              color: "#7a8478"
              font.pixelSize: 10
              font.bold: true
              font.letterSpacing: 2
              visible: !box.ytSearching
            }

            Item { Layout.fillWidth: true }
          }

          ListView {
            id: youtubeList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds
            model: ListModel { id: youtubeResults }
            spacing: 2
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            visible: youtubeResults.count > 0

            ScrollBar.vertical: ScrollBar {
              policy: ScrollBar.AsNeeded
              width: 4
              background: Rectangle { color: "transparent" }
              contentItem: Rectangle {
                color: "#3d484e"
                radius: 2
              }
            }

            delegate: Item {
              id: ytDelegate
              width: youtubeList.width
              height: 44

              Rectangle {
                anchors.fill: parent
                radius: 4
                color: ytDelegate.ListView.isCurrentItem ? "#323d43" : "transparent"
                border.color: ytDelegate.ListView.isCurrentItem ? "#3d484e" : "transparent"
                border.width: 1
              }

              RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 10

                Rectangle {
                  Layout.preferredWidth: 24
                  Layout.preferredHeight: 24
                  Layout.alignment: Qt.AlignVCenter
                  radius: 3
                  color: "#475258"

                  Text {
                    anchors.centerIn: parent
                    text: (index + 1)
                    color: "#d3c6aa"
                    font.pixelSize: 11
                    font.bold: true
                  }
                }

                Column {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 2

                  Text {
                    text: title
                    color: "#d3c6aa"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    width: parent.width
                    maximumLineCount: 1
                  }

                  Text {
                    text: "youtu.be/" + id
                    color: "#7a8478"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: parent.width
                  }
                }

                Text {
                  Layout.preferredWidth: 20
                  Layout.alignment: Qt.AlignVCenter
                  text: "\u25B6"
                  color: "#56635f"
                  font.pixelSize: 12
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  youtubeList.currentIndex = index
                  var item = youtubeResults.get(index)
                  if (item && item.id) {
                    Quickshell.execDetached(["mpv", "https://youtube.com/watch?v=" + item.id,
                                     "--ytdl-format=best"])
                    box.closeMode()
                  }
                }
              }
            }
          }

          // Empty/idle state overlaid on the ListView area
          // (always present to prevent layout shifts)
          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: youtubeResults.count === 0

            Text {
              anchors.centerIn: parent
              text: box.ytSearching ? "Searching…" :
                     (!box.ytSearched ? "Search YouTube  \u2014  type a query and press Enter" :
                      "No results found")
              color: "#7a8478"
              font.pixelSize: 13
            }
          }
        }
      }

      // ========== methods ==========
      function populateApps(text) {
        appListModel.clear()
        var lower = text.toLowerCase()
        var apps = allApps.values
        for (var i = 0; i < apps.length; i++) {
          var app = apps[i]
          if (app.noDisplay) continue
          var nameMatch = app.name.toLowerCase().includes(lower)
          var genericMatch = app.genericName && app.genericName.toLowerCase().includes(lower)
          if (text === "" || nameMatch || genericMatch) {
            appListModel.append({
              name: app.name,
              genericName: app.genericName ? app.genericName : "",
              icon: app.icon ? app.icon : "",
              entry: app
            })
          }
        }
        if (appListModel.count > 0) appList.currentIndex = 0
      }

      function doYoutubeSearch(query) {
        youtubeResults.clear()
        ytSearching = true
        ytSearched = false
        ytProcess.exec(["yt-dlp", "--flat-playlist",
          "ytsearch20:" + query,
          "--print", "%(title)s\t%(id)s"])
      }

      function filterTodos(filterText) {
        todoFilteredModel.clear()
        var lower = filterText.toLowerCase()
        for (var i = 0; i < todoMasterModel.count; i++) {
          var item = todoMasterModel.get(i)
          if (filterText === "" || item.task.toLowerCase().includes(lower)) {
            todoFilteredModel.append({ task: item.task, done: item.done })
          }
        }
        if (todoFilteredModel.count > 0) todoList.currentIndex = 0
      }

      function launchApp(entry) {
        entry.execute()
        closeMode()
      }

      function switchMode(newMode) {
        if (box.mode === newMode && box.mode !== "time") {
          closeMode()
        } else {
          box.mode = newMode
          if (box.mode === "launcher") {
            searchField.text = ""
            populateApps("")
            Qt.callLater(function() {
              searchField.forceActiveFocus()
              searchField.focus = true
            })
          } else if (box.mode === "todo") {
            todoInput.text = ""
            filterTodos("")
            Qt.callLater(function() {
              todoInput.forceActiveFocus()
              todoInput.focus = true
            })
          } else if (box.mode === "youtube") {
            ytInput.text = ""
            youtubeResults.clear()
            ytSearching = false
            ytSearched = false
            Qt.callLater(function() {
              ytInput.forceActiveFocus()
              ytInput.focus = true
            })
          }
        }
      }

      function openMode(newMode) {
        if (box.mode !== newMode) switchMode(newMode)
      }

      function closeMode() {
        if (box.mode !== "time") {
          box.mode = "time"
          searchField.focus = false
          todoInput.focus = false
          ytInput.focus = false
          ytSearching = false
          ytSearched = false
          osdVisible = false
        }
      }

      function showOsd(type) {
        osdType = type
        osdVisible = true

        if (type === "volume") {
          osdVolumeReader.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
        } else if (type === "brightness") {
          osdBrightnessReader.exec(["bash", "-c",
            "echo \"$(brightnessctl get) $(brightnessctl max)\""])
        }

        osdHideTimer.restart()
      }
    }

    // ---- OSD helpers ----
    Process {
      id: osdVolumeReader
      running: false

      stdout: SplitParser {
        splitMarker: "\n"
        onRead: function(data) {
          var match = data.match(/Volume: ([\d.]+)/)
          if (match) box.osdValue = parseFloat(match[1])
        }
      }
    }

    Process {
      id: osdBrightnessReader
      running: false

      stdout: SplitParser {
        splitMarker: "\n"
        onRead: function(data) {
          var parts = data.trim().split(" ")
          if (parts.length === 2) {
            var cur = parseFloat(parts[0])
            var max = parseFloat(parts[1])
            if (max > 0) box.osdValue = cur / max
          }
        }
      }
    }

    Timer {
      id: osdHideTimer
      interval: 1500
      repeat: false
      onTriggered: {
        box.osdVisible = false
      }
    }
  }

  // ---- clock updater ----
  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      var now = new Date()
      timeLabel.text = now.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
    }
  }
}

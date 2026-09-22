import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  // Injected by omarchy-shell.
  property var shell: null

  property bool applied: false
  property bool applyPending: false
  property bool unloading: false

  readonly property string homeDir: Quickshell.env("HOME")
  readonly property string scriptSource: Qt.resolvedUrl("omarchy-auto-theme").toString().replace("file://", "")
  readonly property string unitDir: homeDir + "/.config/systemd/user"
  readonly property string unitService: unitDir + "/omarchy-auto-theme.service"
  readonly property string unitTimer: unitDir + "/omarchy-auto-theme.timer"

  readonly property string unitServiceContent:
    "[Unit]\n" +
    "Description=Auto-switch Omarchy light/dark theme by sunrise/sunset (Omarchy Auto Theme plugin)\n" +
    "\n" +
    "[Service]\n" +
    "Type=oneshot\n" +
    "Environment=PATH=/usr/bin\n" +
    "ExecStart=" + root.scriptSource + "\n"

  readonly property string unitTimerContent:
    "[Unit]\n" +
    "Description=Check and switch Omarchy theme by sunrise/sunset (once per login)\n" +
    "\n" +
    "[Timer]\n" +
    "OnBootSec=1min\n" +
    "\n" +
    "[Install]\n" +
    "WantedBy=timers.target\n"

  readonly property string applyScript:
    "set -e\n" +
    "mkdir -p \"" + root.unitDir + "\"\n" +
    "cat > \"" + root.unitService + "\" <<'EOF_UNIT_SERVICE'\n" + root.unitServiceContent + "EOF_UNIT_SERVICE\n" +
    "cat > \"" + root.unitTimer + "\" <<'EOF_UNIT_TIMER'\n" + root.unitTimerContent + "EOF_UNIT_TIMER\n" +
    "chmod +x \"" + root.scriptSource + "\"\n" +
    "systemctl --user daemon-reload\n" +
    // Retire stale self-scheduling timers (they may point at an old script copy).
    "for u in $(systemctl --user list-units --all --no-legend --plain --type=timer 'omarchy-auto-theme-sched-*' | awk '{print $1}'); do systemctl --user stop \"$u\"; done\n" +
    "systemctl --user enable --now omarchy-auto-theme.timer\n" +
    "systemctl --user start omarchy-auto-theme.service\n"

  readonly property string restoreScript:
    "systemctl --user disable --now omarchy-auto-theme.timer >/dev/null 2>&1 || true\n" +
    "for u in $(systemctl --user list-units --all --no-legend --plain --type=timer 'omarchy-auto-theme-sched-*' | awk '{print $1}'); do systemctl --user stop \"$u\"; done\n" +
    "systemctl --user daemon-reload >/dev/null 2>&1 || true\n" +
    "rm -f \"" + root.unitService + "\" \"" + root.unitTimer + "\"\n" +
    "systemctl --user daemon-reload >/dev/null 2>&1 || true\n"

  function apply() {
    if (root.unloading)
      return

    if (applyProcess.running) {
      root.applyPending = true
      return
    }

    root.applyPending = false
    applyProcess.command = ["bash", "-c", root.applyScript]
    applyProcess.running = true
  }

  Process {
    id: applyProcess

    stdout: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "")
          console.log("omarchy-auto-theme: " + text.trim())
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim() !== "")
          console.warn("omarchy-auto-theme: " + text.trim())
      }
    }

    onExited: function(exitCode) {
      root.applied = exitCode === 0
      if (exitCode !== 0)
        console.warn("omarchy-auto-theme: apply failed with exit code " + exitCode)
      if (root.applyPending && !root.unloading)
        Qt.callLater(root.apply)
    }
  }

  Component.onCompleted: Qt.callLater(root.apply)

  Component.onDestruction: {
    root.unloading = true
    // Detached so the restore survives shell teardown.
    Quickshell.execDetached(["bash", "-c", root.restoreScript])
  }
}

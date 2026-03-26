######################################
# Auto-close Terminal on shell exit
######################################
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  exit() {
    (sleep 0.2; osascript 2>/dev/null <<'EOF'
      tell application "Terminal"
        if (count of windows) <= 1 then
          quit
        else
          close front window
        end if
      end tell
EOF
    ) &disown
    builtin exit
  }
fi
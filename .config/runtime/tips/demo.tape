# ===============================
#  Professional CLI Showcase
#  Author: monkeymonk
#  Project: tips
# ===============================

# -------- Output --------
Output demo.gif

# -------- Terminal Look --------
Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 700
Set FontFamily "FiraCode Nerd Font"
Set Theme "Dracula"
Set Padding 20
Set CursorBlink true

# Optional: for slower, more polished feel
Set TypingSpeed 80ms
Set Framerate 60

# Hidden setup: clean environment + prompt
Hide
Type `export PS1='$ '`
Enter
Type "export TIPS_CONFIG_DIR=/tmp/tips-demo-config"
Enter
Type "rm -rf /tmp/tips-demo-config"
Enter
Type "mkdir -p /tmp/tips-demo-config/providers"
Enter
Type "clear"
Enter
Sleep 500ms
Show

# -------- Intro Section --------
Sleep 300ms

Type "# tips — extensible tip aggregator with pluggable providers"
Enter
Sleep 800ms

# -------- Help / Usage --------
Type "tips --help"
Enter
Sleep 2000ms

# -------- Random Tip --------
Sleep 200ms
Type "# Show a random tip"
Enter
Sleep 500ms

Type "tips"
Enter
Sleep 1500ms

Type "tips"
Enter
Sleep 1500ms

Type "tips"
Enter
Sleep 2000ms

# -------- Provider Status --------
Type "# See all registered providers and their status"
Enter
Sleep 500ms

Type "tips status"
Enter
Sleep 2500ms

# -------- List Tips --------
Type "# List all tips grouped by provider"
Enter
Sleep 500ms

Type "tips list --source static"
Enter
Sleep 2500ms

# -------- Count --------
Type "# Count tips per provider"
Enter
Sleep 500ms

Type "tips count"
Enter
Sleep 2000ms

# -------- Sources --------
Type "# List registered providers"
Enter
Sleep 500ms

Type "tips sources"
Enter
Sleep 2000ms

# -------- Outro --------
Type "# Documentation: https://github.com/monkeymonk/tips"
Enter
Sleep 1500ms

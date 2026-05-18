#!/usr/bin/env bash
# =============================================================================
# lock.sh — Tokyo Night lock screen via i3lock-color
# Deploy: cp lock/lock.sh ~/.config/i3/lock.sh && chmod +x ~/.config/i3/lock.sh
# Triggered by: Super+Shift+x (set in i3/config)
# =============================================================================

# Pause dunst so notifications don't pop over the lock screen
pkill -u "$USER" -USR1 dunst 2>/dev/null || true

i3lock-color \
    --blur=8 \
    --clock \
    --indicator \
    \
    --time-str="%H:%M" \
    --date-str="%A, %d %B" \
    \
    --time-font="JetBrains Mono" \
    --date-font="JetBrains Mono" \
    --layout-font="JetBrains Mono" \
    --verif-font="JetBrains Mono" \
    --wrong-font="JetBrains Mono" \
    \
    --time-size=72 \
    --date-size=18 \
    \
    --time-color=c0caf5ff \
    --date-color=a9b1d6ff \
    \
    --ring-color=7aa2f7ff \
    --ring-width=3.0 \
    --radius=60 \
    \
    --inside-color=1a1b26bb \
    --insidever-color=292e42bb \
    --insidewrong-color=1a1b26bb \
    \
    --keyhl-color=9ece6aff \
    --bshl-color=f7768eff \
    \
    --separator-color=292e42ff \
    --line-color=00000000 \
    \
    --verif-color=7aa2f7ff \
    --wrong-color=f7768eff \
    --layout-color=565f89ff \
    \
    --verif-text="verifying..." \
    --wrong-text="wrong." \
    --noinput-text="" \
    \
    --pass-media-keys \
    --pass-screen-keys \
    --nofork

# Resume dunst after unlock
pkill -u "$USER" -USR2 dunst 2>/dev/null || true

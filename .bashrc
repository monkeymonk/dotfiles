#!/bin/bash
#
#    _______   ____ ___
#   ╱       ╲╲╱    ╱   ╲
#  ╱        ╱╱         ╱    Stéphan Zych
# ╱         ╱╱       _╱     https://stephan.zych.be
# ╲__╱__╱__╱╲╲___╱___╱
#

# ~/.bashrc: executed by bash(1) for non-login shells.

export BROWSER=junction
export TERMINAL=ghostty

[ -f "$HOME/.config/runtime/bootstrap.sh" ] && source "$HOME/.config/runtime/bootstrap.sh"

. "$HOME/.local/share/../bin/env"

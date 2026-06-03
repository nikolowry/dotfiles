#!/usr/bin/env bash

rdp() {
    local action="$1"
    local rdp_key="org.gnome.desktop.remote-desktop.rdp"
    local status_on="ON (Vision active)"
    local status_off="OFF (Encoder free)"

    local current_state
    local next_state
    local status_msg

    # Guard clauses via short-circuiting
    command -v gsettings &>/dev/null || {
        printf "Error: 'gsettings' not found.\n"
        return 1
    }

    # Minimal "help", don't throw error
    [[ -z "$action" ]] &&
        printf "Usage: rdp <toggle|status|restart>\n" &&
        return 0

    # State & Message Resolution
    current_state=$(gsettings get "$rdp_key" enable)

    # Initialize next_state to current_state, invert only if toggling
    next_state="$current_state"

    [[ "$action" == "toggle" ]] &&
        next_state=$([[ "$current_state" == "true" ]] &&
            echo "false" ||
            echo "true")

    # Resolve UI message based on what the state WILL be (or IS)
    status_msg=$([[ "$next_state" == "true" ]] &&
        echo "$status_on" ||
        echo "$status_off")

    # Status - subcommand
    [[ "$action" == "status" ]] &&
        printf "Status: %s\n" "$status_msg" &&
        return 0

    # Toggle - subcommand
    [[ "$action" == "toggle" ]] &&
        gsettings set "$rdp_key" enable "$next_state" &&
        printf "RDP Toggled: %s\n" "$status_msg" &&
        return 0

    [[ "$action" == "restart" ]] && {
        printf "Bouncing RDP service...\n"

        gsettings set "$rdp_key" enable false &&
            sleep 1 &&
            gsettings set "$rdp_key" enable true

        printf "RDP Restarted: %s\n" "$status_on"
        return 0
    }

    # 4. Fallback for invalid args
    printf "Invalid command. Usage: rdp <toggle|status|restart>\n"
    return 1
}

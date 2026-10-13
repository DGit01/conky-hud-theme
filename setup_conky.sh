#!/bin/bash

echo "=== Starting Conky Setup Automation ==="

# 1. Install dependencies
echo "[+] Installing conky-all and lm-sensors..."
sudo apt update
sudo apt install -y conky-all lm-sensors

# 2. Auto-detect active network interface
NET_IFACE=$(ip route show | grep default | awk '{print $5}' | head -n1)
if [ -z "$NET_IFACE" ]; then
    echo "[-] Could not auto-detect network interface. Defaulting to 'enp3s0'."
    NET_IFACE="enp3s0"
else
    echo "[+] Detected active network interface: $NET_IFACE"
fi

# 3. Smart GPU Detection & Interactive Prompt
GPU_SECTION=""
GPU_DETECTED=false

while [ "$GPU_DETECTED" = false ]; do
    if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
        echo "[+] Detected NVIDIA GPU with working drivers."
        GPU_SECTION='${color 888888}GPU USAGE:${color} $alignr ${exec nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader}
${color 888888}GPU TEMP:${color} $alignr ${exec nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader}°C'
        GPU_DETECTED=true
    else
        echo "[-] NVIDIA GPU / drivers not automatically detected."
        echo ""
        echo "Select an option:"
        echo "  1) Ignore GPU and exclude it from the display"
        echo "  2) Try AMD / Generic GPU fallback (sysfs/sensors)"
        echo "  3) Retry GPU detection"
        read -p "Enter your choice [1-3]: " choice

        case $choice in
            1)
                echo "[+] Skipping GPU monitoring section."
                GPU_SECTION=""
                GPU_DETECTED=true
                ;;
            2)
                echo "[+] Applying AMD/Generic GPU fallback..."
                GPU_SECTION='${color 888888}GPU USAGE:${color} $alignr ${exec cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "N/A"}%
${color 888888}GPU TEMP:${color} $alignr ${exec sensors | grep -iE "edge|junction|gpu" | head -n 1 | awk "{print \$2}"}'
                GPU_DETECTED=true
                ;;
            3)
                echo "[*] Retrying GPU detection..."
                sleep 1
                ;;
            *)
                echo "[-] Invalid selection. Please choose 1, 2, or 3."
                ;;
        esac
    fi
done

# 4. Create Conky config directory and file
echo "[+] Creating Conky configuration..."
mkdir -p ~/.config/conky

cat << EOF > ~/.config/conky/conky.conf
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'e0e0e0',
    default_outline_color = 'black',
    default_shade_color = 'black',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    use_xft = true,
    font = 'JetBrains Mono:size=9',
    gap_x = 30,
    gap_y = 50,
    minimum_width = 220, minimum_height = 200,
    maximum_width = 240,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_stderr = false,
    extra_newline = false,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false,
}

conky.text = [[
\${color 00f0ff}\${font JetBrains Mono:size=10:bold}CORE_SYS_MONITOR\${font}\${color}
\${hr 1}
\${color 888888}CORE TEMP:\${color} \$alignr \${exec sensors | grep 'Core 0' | awk '{print \$3}'}
\${color 888888}CPU USAGE:\${color} \$alignr \$cpu% 
\${color 333333}\${cpu cpu0}% \${cpubar cpu0 4,160}\${color}

\${color 888888}RAM USAGE:\${color} \$alignr \$mem (\$memperc%)
\${color 333333}\${membar 4,200}\${color}
${GPU_SECTION:+
$GPU_SECTION
}
\${color 00f0ff}\${font JetBrains Mono:size=10:bold}NETWORK\${font}\${color}
\${hr 1}
\${color 888888}DOWN:\${color} \${downspeed $NET_IFACE} \$alignr \${totaldown $NET_IFACE}
\${color 888888}UP:\${color}   \${upspeed $NET_IFACE} \$alignr \${totalup $NET_IFACE}
]]
EOF

# 5. Setup Autostart
echo "[+] Configuring desktop autostart..."
mkdir -p ~/.config/autostart

cat << EOF > ~/.config/autostart/conky.desktop
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky
StartupNotify=false
Terminal=false
EOF

echo "=== Setup Complete! Launching Conky... ==="
pkill conky 2>/dev/null
conky &
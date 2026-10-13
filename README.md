# Minimal Conky System Monitor for Debian-Based Linux

A lightweight, clean, and minimal system telemetry HUD designed for the top-right corner of your desktop. Built for **Debian-based distributions** (Ubuntu, Linux Mint, Debian, Pop!_OS, etc.), featuring an automated setup script that handles dependencies and hardware detection out of the box.

---

## What It Monitors
* **Core Temperature:** Live reading from CPU core 0.
* **CPU Usage:** Total percentage + a sleek minimal usage bar.
* **RAM Usage:** Current memory consumption and percentage + usage bar.
* **GPU Usage & Temp:** Real-time metrics via `nvidia-smi` (with graceful fallback handling).
* **Network Activity:** Real-time download/upload speeds and session totals for your active network interface.

---

## Automated Installation

You can set everything up automatically with a single script that installs dependencies, auto-detects your active network interface and GPU, generates the config, and configures login autostart.

### 1. Clone or Download the Script
Save the `setup_conky.sh` script to your local machine.

### 2. Make it Executable
Open your terminal in the directory containing the script and run:
```bash
chmod +x setup_conky.sh

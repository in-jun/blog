---
title: "Why I Chose Linux as My Primary Operating System"
date: 2024-05-16T13:16:11+09:00
tags: ["Linux", "Ubuntu", "Operating System", "Development"]
draft: false
---

## Introduction

It's been several years since I started using Linux as my primary operating system as a developer. When a colleague recently asked me "why do you use Linux," I couldn't explain my reasons systematically. I'd like to take this opportunity to organize my thoughts on why I chose Linux.

## Linux History and Philosophy

To understand Linux, it's necessary to first examine its roots. Unix, developed by Ken Thompson and Dennis Ritchie at AT&T Bell Labs in 1969, became the foundation of modern operating systems. It was an innovative system supporting multitasking and multi-user environments. This influenced the design philosophy of countless operating systems that followed. The GNU Project, started by Richard Stallman in 1983, became the starting point of the free software movement. It proposed the philosophy that software source code should be freely used, modified, and distributed.

The Linux kernel, developed by Finnish university student Linus Torvalds in 1991, combined with GNU Project tools to form a complete operating system. It became a representative example of an open-source project developed through collaboration by developers worldwide. This open-source philosophy had a profound impact on the modern development ecosystem. The software development approach based on transparency and collaboration was further accelerated by the emergence of platforms like GitHub and GitLab. This laid the foundation for most of today's cloud infrastructure and server environments to run on Linux.

## Distribution Comparison and Selection

One of the great advantages of Linux is the ability to choose a distribution that fits user needs. Ubuntu is a distribution developed by Canonical that provides the most user-friendly environment for beginners. The LTS (Long Term Support) version provides security updates for 5 years. It has an extensive community and rich documentation, making problem-solving easy. Most commercial software prioritizes Ubuntu support.

Fedora is a community distribution sponsored by Red Hat, characterized by rapid adoption of the latest technologies. It serves as a testbed for RHEL (Red Hat Enterprise Linux). SELinux is enabled by default, providing high security. It's suitable for learning the Red Hat ecosystem in enterprise environments. Arch Linux pursues minimalism and user-centered philosophy. It provides always-updated packages through a rolling release approach. Users can access extensive packages through the AUR (Arch User Repository). While building the system from scratch provides deep understanding, the entry barrier is high for beginners.

Debian is a distribution that prioritizes stability above all else, including only thoroughly tested packages. It is widely used as a server operating system. It's also the base distribution for Ubuntu. For developers, I recommend Ubuntu or Fedora. Ubuntu provides an immediately usable environment with abundant support. Fedora is suitable for developers who want to experience the latest technologies and learn the Red Hat ecosystem. Arch Linux can also be a good choice if you want deep system understanding.

## Main Reasons for Choosing Linux

### 1. Convenience of the Development Environment

From a developer's perspective, the biggest advantage of Linux is the ease of setting up a development environment. You can easily install necessary tools through package managers and benefit from an efficient terminal-based work environment. In particular, high compatibility with container technologies and the native Unix environment greatly enhance the development workflow.

```bash
# Installing development tools
sudo apt install build-essential
sudo apt install python3-dev

# Running a development server
python3 manage.py runserver
```

The ability to build and manage development environments with such simple commands is one of Linux's major attractions.

### 2. System Stability

Linux provides remarkable system stability. Efficient memory management and minimal performance degradation during long-running operations are beneficial not only in server environments but also in everyday development work. The optimization of background processes, allowing for efficient use of system resources, is also a significant advantage.

### 3. System Control and Management

Linux offers detailed system control capabilities. You can monitor and control almost every aspect of the system through the terminal, providing a transparent operating experience.

```bash
# Checking system status
top

# Checking disk usage
df -h

# System updates
sudo apt update && sudo apt upgrade
```

Regular security updates and flexible system configuration possibilities provide developers with great freedom.

### 4. Cost and Freedom

As an open-source operating system, Linux has no license costs. This not only provides economic benefits but also the freedom to modify system components according to your needs. You can choose from various distributions like Ubuntu, Fedora, or Arch Linux to suit your requirements, and receive technical support through active communities.

### 5. Technical Learning

Using Linux naturally leads to understanding the basic principles of operating systems. When problems occur, solving them directly improves problem-solving abilities, and you also acquire skills to automate repetitive tasks. These experiences greatly help in developing system management capabilities.

## Practical Development Environment Setup

Setting up a development environment on Linux is simple yet powerful. Docker is the standard for container technology and runs natively on Linux. It ensures consistency between development and production environments. It can isolate and resolve dependency issues. The Python development environment manages multiple versions through pyenv. It configures independent environments per project with virtualenv. It installs packages through pip.

Node.js development allows easy switching between versions using nvm (Node Version Manager). Packages are managed with npm and yarn. It provides an environment optimized for web application development. The Java development environment manages JDK versions through SDKMAN. Maven and Gradle are used as build tools. IntelliJ IDEA and Eclipse work perfectly on Linux. The Go language shows particularly fast compilation speed on Linux. It's suitable for system programming with a simple installation process and powerful standard library.

For IDE and editor selection, VSCode shows excellent performance on Linux. It provides rich extensions and an integrated terminal. IntelliJ IDEA is optimized for Java and Kotlin development. vim and neovim provide powerful editing capabilities in terminal environments. IDE-level functionality can be implemented through plugins. Terminal customization has a significant impact on development productivity. zsh provides enhanced auto-completion and themes compared to bash. oh-my-zsh enhances the terminal with hundreds of plugins and themes. tmux allows splitting and managing terminal sessions to perform multiple tasks simultaneously.

## Real Workflow

Daily development work typically starts by opening a terminal and starting a tmux session. Move to the project directory and activate the virtual environment. Write code in the editor while running tests in the terminal. Run local development servers with Docker containers. Perform version control with Git.

Package managers are core operating system tools. Ubuntu's apt is the standard package manager for Debian-based systems, providing extensive package repositories. Fedora's dnf is the Red Hat-based package manager, providing improved dependency resolution. Arch Linux's pacman manages the system with fast speed and concise syntax. It provides access to community packages through AUR.

System monitoring tools are essential for understanding system status. htop allows visual process management and real-time checking of CPU and memory usage. glances provides more comprehensive system information, monitoring network and disk I/O. btop allows viewing all system resources at a glance with a modern interface.

Automation is a core strength of Linux. Automate repetitive tasks with bash scripts. Schedule periodic tasks with cron. Manage background processes with systemd services. Manage infrastructure as code with Ansible or Terraform.

## Linux vs Windows vs macOS

From a development perspective, Linux provides perfect alignment with server environments. It supports native Unix tools and container technologies. It can be used for free. It allows complete system control. Windows excels at game and commercial software support. It provides Linux environment through WSL2. It's optimized for Visual Studio and .NET development. However, license costs occur. System updates are mandatory. File system and permission management is complex.

macOS has rich development tools as a Unix-based system. It provides excellent user experience and hardware integration. It's essential for iOS development. However, high hardware costs are required. Customization is limited. Upgrades to newer versions tend to be forced.

In terms of performance and resource usage, Linux provides the most efficient memory management. Background processes are minimized. It runs quickly even on low-spec hardware. Boot time is short and system response is fast. Alignment with server environments is a decisive advantage of Linux. Identical development and production environments minimize deployment issues. Docker containers and Kubernetes were designed based on Linux. Most instances from cloud providers run Linux. Environments tested locally are reproduced on servers exactly.

Cost-wise, Linux itself is free. Most development tools are open source. Low hardware requirements reduce costs. There are no license costs for server deployment. Windows incurs OEM license costs. Server versions require additional costs. macOS requires purchasing Apple hardware, resulting in high initial investment costs.

## Problems I Overcame

During the initial adaptation period, time was needed to become familiar with CLI rather than GUI. Alternative software for what I used on Windows had to be found. Terminal commands and file system structure had to be learned. Hardware compatibility issues were one of the most common obstacles. WiFi drivers weren't supported by default, requiring driver installation via wired connection. NVIDIA graphics cards required manual installation of proprietary drivers. Bluetooth and printer setup could be tricky. However, most hardware is now supported by default. Community documentation is abundant, making it easy to find solutions.

Finding commercial software alternatives was also a challenge. Use LibreOffice or Google Workspace instead of Microsoft Office. Use GIMP or Krita instead of Adobe Photoshop. Use DaVinci Resolve or Kdenlive instead of Adobe Premiere. Most cases can be replaced with web-based applications. Wine and Proton are compatibility layers that enable running Windows programs on Linux. Wine implements the Windows API on Linux, allowing many Windows applications to run. Proton is a Wine-based tool developed by Valve that enables running Steam games on Linux. Recently, many Windows games run smoothly on Linux. Performance is similar to Windows or sometimes even better.

## Current Situation in 2025-2026

Linux desktop market share is steadily increasing. The success of Steam Deck improved perception as a gaming platform. Linux usage among developers is rapidly increasing. The importance of Linux is becoming more prominent as cloud-native development environments become common. The emergence of WSL2 (Windows Subsystem for Linux 2) expanded Linux's influence. It enables Windows users to experience the Linux environment. Many developers use Linux tools on Windows through WSL2. This is a case of Microsoft itself recognizing Linux's value.

The importance of Linux in the cloud era is growing. Most instances on AWS, Azure, and GCP run Linux. Kubernetes and Docker depend on Linux kernel features. Serverless functions also run in Linux containers. Linux knowledge is essential for DevOps and SRE engineers. Wayland is a new display server protocol replacing X11, providing better security and performance. HiDPI and multi-monitor support have improved. Most major distributions are transitioning to Wayland. However, some applications still require X11. NVIDIA driver support for Wayland has only recently been improving.

## Recommended Resources

Learning materials for Linux include Linux Journey, which provides a free interactive guide for beginners. The Linux Command Line is a free book by William Shotts that explains terminal usage in detail. ArchWiki is the Arch Linux wiki but provides useful information for all distributions. Linux From Scratch is a project for learning by building Linux from scratch.

Community resources include Reddit's r/linux and r/linuxquestions, which provide active discussions and Q&A. Stack Exchange's Unix & Linux provides detailed answers to technical questions. Linux Forums and Ubuntu Forums operate distribution-specific communities. Discord and Telegram Linux groups support real-time communication.

Useful blogs include It's FOSS, which provides Linux news and tutorials. LinuxConfig provides detailed configuration guides. OMG! Ubuntu delivers Ubuntu-related news. Phoronix covers Linux hardware and performance benchmarks. YouTube channels include The Linux Experiment, which covers Linux desktop and open-source software. LearnLinuxTV provides systematic lectures from beginner to advanced. Level1Techs provides hardware and Linux in-depth analysis. Chris Titus Tech shares practical Linux tips and configurations.

## Practical Considerations

Linux is optimized for development environments, has a stable system, and allows for free control. Cost efficiency is also a significant benefit that cannot be ignored.

However, there are limitations to consider: some commercial software is not supported, and compatibility with specific hardware needs to be verified in advance. Time is required for initial learning, and there are restrictions on running certain games.

## Conclusion

Linux is a powerful OS for developers. While it requires an initial adaptation period, the benefits it provides in terms of development work and system management are substantial. As of 2025-2026, Linux has matured in desktop environments. It has become an essential platform in the cloud and container era. Rich learning materials and active communities support new users. I hope this post helps those considering using Linux.

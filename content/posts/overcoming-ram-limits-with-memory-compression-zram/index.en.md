---
title: "Overcoming RAM Limits with zram Memory Compression"
date: 2025-05-02T12:12:58+09:00
draft: false
description: "Memory compression and performance improvement with zram."
tags: ["Linux", "Memory", "Performance"]
---

## ZRAM Concept and Principles

ZRAM (formerly known as compcache) is a memory compression technology provided by the Linux kernel that creates a virtual block device by compressing a portion of RAM. This technology was first developed by Nitin Gupta in 2009 and officially integrated into the Linux kernel from version 3.14. It has been widely used ever since. The core idea of ZRAM is to utilize compressed RAM as swap space instead of disk-based swap, effectively reducing memory usage without the overhead of disk I/O operations. This approach significantly improves system performance, especially in memory-constrained environments.

The ZRAM device compresses data in real-time before storing it in memory and decompresses it when accessing the data. Although this process consumes some CPU resources, it completely avoids disk I/O operations, contributing significantly to overall system performance improvement. ZRAM typically achieves compression ratios of 2:1 to 4:1 using high-speed compression algorithms such as LZO (Lempel-Ziv-Oberhumer), LZ4, and ZSTD (Zstandard). The compression algorithm can be selected based on system requirements, and Ubuntu 24.04 uses the LZ4 algorithm by default, which provides an excellent balance between speed and compression ratio.

## Key Advantages of ZRAM

### Memory Capacity Expansion

The most significant advantage of ZRAM is the ability to effectively increase available memory without physical RAM expansion. In environments with a lot of text data, it can achieve compression ratios of up to 4:1, with an average of about 2:1. This means that on an 8GB RAM system, you can effectively experience the equivalent of 12-16GB of memory, allowing you to improve system performance without additional hardware investment.

### Improved System Responsiveness

Disk-based swap is slow to access, significantly degrading system responsiveness. HDDs in particular incur delays of tens of milliseconds. ZRAM, on the other hand, operates within RAM, allowing data access hundreds of times faster than disk swap with only microsecond-level latency. This greatly helps maintain system responsiveness even in low-memory situations. It is particularly effective in low-specification systems, environments with limited memory, and when running memory-intensive applications such as web browsers or IDEs.

### Extended Disk Lifespan

Storage devices like SSDs have limited write cycles, and excessive swap usage can shorten disk lifespan. Typical SSDs have a lifespan of tens to hundreds of TBW (Terabytes Written), and excessive swap usage is a major cause of reduced lifespan. ZRAM reduces disk-based swap usage, effectively extending the life of storage devices. This benefit is particularly important in embedded systems, environments using budget SSDs, and 24/7 operating systems such as servers.

### Power Efficiency

For mobile devices or laptops, increased disk I/O leads to higher power consumption. HDDs in particular consume significant power due to physical head movement and platter rotation, while SSDs also consume consistent power during write operations. ZRAM helps extend battery life by reducing disk access. Although it uses CPU for compression and decompression, modern processors have efficient compression instructions and low CPU power consumption. The disk I/O reduction benefits are much greater, resulting in overall improved power efficiency.

## Easy Installation and Usage in Ubuntu 24.04

In Ubuntu 24.04, installing and using ZRAM is very straightforward. The Ubuntu development team provides a pre-configured package for general users, so you can install it with just a single command without complex kernel module configuration or script writing. It can be automatically configured and immediately used.

```bash
sudo apt install zram-config
```

By installing the zram-config package with this command, the system automatically sets up and activates ZRAM. It registers a systemd service to start automatically at boot and applies optimal default settings. You can experience the effects immediately without requiring a reboot or additional configuration.

### Default Configuration

When you install the zram-config package in Ubuntu 24.04, the following default settings are automatically applied. These settings are optimized values determined by the Ubuntu development team through various tests and benchmarks.

-   ZRAM size is set to approximately 50% of RAM to maintain a balance between physical memory and compressed memory
-   The efficient LZ4 compression algorithm is used to ensure fast compression and decompression speeds
-   Swap priority is set to 100 to prioritize it over disk swap (default priority -2)
-   Automatically activated at system boot to operate continuously without user intervention

These default settings are suitable for most users and provide immediate performance improvements in typical desktop workloads without any additional adjustments.

### Verifying Installation

To check if ZRAM is working properly after installation, you can use the following commands:

```bash
zramctl
```

Or

```bash
swapon --show
```

If `/dev/zram0` appears in the output, ZRAM is properly installed and activated.

## Considerations When Using ZRAM

In most common usage environments, the default settings provide sufficient performance improvements, particularly effective for typical workloads such as web browsing, document editing, and code development. When using very memory-intensive applications or running multiple virtual machines, you can experience even greater performance improvements.

**Hibernation and ZRAM**: If hibernation (sleep mode) is needed, consider using zswap instead of ZRAM. This is because ZRAM is purely memory-based and data is lost when power is turned off, whereas zswap works together with disk swap and supports hibernation. zswap acts as a memory compression cache, storing compressed data in RAM but able to write to disk when necessary, making it a middle ground between ZRAM and disk swap.

**Effects by Memory Capacity**: On systems with abundant memory (32GB or more), the effect of ZRAM may be limited. In environments where swap is rarely used, you may not notice performance improvements even with ZRAM enabled. Conversely, systems with 8GB or less of memory, or usage patterns with many open browser tabs, will see significant benefits from ZRAM.

**CPU Load Considerations**: In environments where CPU load is already high, additional load may occur during compression and decompression processes. However, modern processors provide very efficient compression performance, so in most cases CPU overhead is only 1-3%, and the benefits from reduced disk I/O wait times are much greater.

## Conclusion

In Ubuntu 24.04, ZRAM is a powerful memory optimization technology that can be utilized immediately with just a single installation command. It boasts proven stability and efficiency with over 15 years of validation since its development in 2009. It can significantly improve performance especially on systems with limited memory, and provides practical advantages in terms of disk lifespan extension and power efficiency. Thanks to the pre-configured package provided by Ubuntu, the default settings alone provide sufficient benefits, making it a very useful tool for general users.

If you are experiencing memory shortage issues or want to improve system responsiveness in Ubuntu 24.04, you can experience immediate improvement effects just by installing the zram-config package. The effects are particularly pronounced on systems with 8GB or less of RAM or in environments running multiple applications simultaneously.

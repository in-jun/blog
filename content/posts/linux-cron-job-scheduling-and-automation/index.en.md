---
title: "How to Set Up Cron Jobs on Linux - Automating System Tasks"
date: 2025-02-17T22:55:37+09:00
tags: ["Cron", "Automation", "Linux", "Scheduling"]
description: "This article explains how to set up cron jobs on Linux, including real-world use cases."
draft: false
---

## Cron

Manually taking care of repetitive tasks is a waste of time. Tasks like backing up system, cleaning logs, checking disk space, and many more, need to be automated. Cron is the most basic tool in Linux that lets you automate such tasks.

## Understanding Cron

Cron executes scheduled tasks at specified times. You define the time and the command to be executed in a configuration file called crontab. Each line in the crontab consists of a time and a command.

```bash
* * * * * /path/to/command
```

The five asterisks represent minute, hour, day, month, and weekday respectively. An asterisk signifies 'all'. So the above configuration runs the command every minute.

## Scheduling Time

You can set up various use cases such as running backups every day at 3 AM, generating business reports on weekdays at 9 AM, or checking server health every 5 minutes.

```bash
# Backup every day at 3 AM
0 3 * * * /scripts/backup.sh

# Generate reports on weekdays at 9 AM
0 9 * * 1-5 /scripts/report.sh

# Check server health every 5 minutes
*/5 * * * * /scripts/healthcheck.sh
```

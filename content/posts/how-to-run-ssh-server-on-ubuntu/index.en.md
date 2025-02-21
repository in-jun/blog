---
title: "Run and Connect to SSH Server on Ubuntu"
date: 2024-08-14T15:16:40+09:00
tags: ["ubuntu", "ssh", "networking"]
draft: false
---

## Introduction

SSH (Secure Shell) is a network protocol that allows you to log in to another computer over a network and execute commands on a remote system or transfer files. In this article, we will go through the step-by-step process of installing an SSH server on an Ubuntu system, configuring it to start automatically, and connecting to the SSH server.

## Installing the SSH Server

1. First, open a terminal and update the list of packages:

    ```bash
    sudo apt update
    ```

2. Install the OpenSSH server:

    ```bash
    sudo apt install openssh-server
    ```

3. Once the installation is complete, the SSH service should be started automatically. To check the status of the SSH service, enter the following command:

    ```bash
    sudo systemctl status ssh
    ```

    If the service is not running, you can start it with this command:

    ```bash
    sudo systemctl start ssh
    ```

4. Enable the SSH service to start automatically on boot:

    ```bash
    sudo systemctl enable ssh
    ```

    This will make sure that the SSH service is started automatically whenever the system boots up.

## Configuring the SSH Server

1. Open the SSH configuration file:

    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

2. You can change the following settings based on your requirements:

    - **Change Port**: You can change the default port 22 to a different port for increased security. For example, to change the port to 2222:

        ```bash
        Port 2222
        ```

    - **Disable Root Login**: You can disable SSH login as the root user for enhanced security:

        ```bash
        PermitRootLogin no
        ```

    - **Disable Password Authentication**: If you are using public key authentication, you can disable password authentication:

        ```bash
        PasswordAuthentication no
        ```

3. Save the changes and exit the editor (Ctrl+O to save, Ctrl+X to exit).

4. Restart the SSH service to apply the changes:

    ```bash
    sudo systemctl restart ssh
    ```

## Configuring Firewall

If you are using UFW, which is the default firewall on Ubuntu, you need to allow SSH connections. Check if UFW is active and allow SSH connections:

```bash
sudo ufw status
sudo ufw allow ssh
```

If you are using a non-standard port, you can allow it by specifying the port like this:

```bash
sudo ufw allow 2222/tcp
```

## Connecting to the SSH Server

1. From your client computer, try connecting to the SSH server using this command:

    ```bash
    ssh username@server_ip
    ```

    Replace `username` with the username on the server and `server_ip` with the IP address of the server. If you are using a non-standard port, you can specify the port while connecting:

    ```bash
    ssh -p 2222 username@server_ip
    ```

2. The first time you connect, you will get a message asking you to trust the server's authenticity. Type "yes" to continue.

3. Enter the password and log in.

## Security Hardening Tips

1. **Use strong passwords**: Use a strong and unpredictable password.
2. **Use public key authentication**: Enhance security by utilizing public key authentication instead of passwords.
3. **Use a non-standard port**: Use a different port instead of the default port 22 to reduce brute force attacks.
4. **Install fail2ban**: To prevent brute force attacks, install `fail2ban`:

    ```bash
    sudo apt install fail2ban
    ```

5. **Regular updates and patching**: Keep your system and packages updated to maintain security.

## Conclusion

You now know how to install an SSH server on an Ubuntu system, configure it to start automatically, and connect to the SSH server. SSH is a vital tool for remote system administration, but it is crucial to pay attention to security. By following the security hardening tips mentioned above, you can have a more secure SSH environment.

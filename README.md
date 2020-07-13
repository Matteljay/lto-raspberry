# LTO Network staking for Raspberry Pi

## Introduction

This repository is for those who want to set up an LTO Network node on a Raspberry Pi and start staking LTO cryptocurrency. Here you'll read tips to help speed up the installation process and you can get scripts to facilitate this goal. There's a brief Raspberry Pi server configuration guide, a script to turn the LTO Java executable into a reliable background process, a secure offline tool to generate your encoded seed, a server monitoring short cut and some general tips. Note that this document was based on the [official article](https://docs.ltonetwork.com/public-node/mining-staking/node-raspberry-pi-expert).

DISCLAIMER: Following this guide might render your Raspberry Pi inaccessible or delete all data from it. Also, executable files from this GitHub repository will be used which may pose a security risk. Care will be taken to ensure security but I take NO responsibility in case things go wrong and all your coins are lost. Proceed at your own risk!

## Basic server setup

### Step 1: physically connect

Your Raspberry Pi should be connected to the modem/router of your ISP with an ethernet cable. Connect a computer monitor to the Raspberry to help complete the Raspbian installation. Follow the installation steps from the Raspbian SD card. It is assumed you now have an internet connection on your Raspberry Pi via your modem.

Further reading for this step: [Raspbian installation guide](https://electropeak.com/learn/complete-guide-install-raspbian-raspberry-pi/)

### Step 2: modem access

Find out how to access your modem with your internet browser. This can be done from the Raspberry's graphical desktop itself or from a laptop connected via WIFI to **the same modem**. Usually you can search for *gateway IP address* in your desktop's internet settings or on Linux you could use the command `ifconfig`, on Windows this is `ipconfig`. The user manual of your ISP's modem often has this gateway value in print. Let's say for this article the gateway IP address is `192.168.1.254`.

Further reading for this step: [Find default gateway on Windows](https://www.lifewire.com/how-to-find-your-default-gateway-ip-address-2626072)

### Step 3: enable DMZ IP address

The goal of this step (and the previous step) is to change your modem settings in such a way that other LTO servers can freely connect and communicate with the LTO software on your Raspberry. For this you'll want to login to your modem and search for *Setup DMZ*. Once you found it, usually you are free to enter an IP address of your choice. You could enter something like `192.168.1.123`. Save those settings and leave the modem admin panel.

Your specific modem's user manual is the best source of [further reading](https://duckduckgo.com/?q=how+enable+dmz+modem).

### Step 4: change Raspberry's IP address

Change your Raspberry's internet connection settings to use that DMZ address. Your Raspberry's desktop might have the option to set a *static IP address* in the internet settings. However mine didn't so I changed the content of my file `/etc/dhcpcd.conf` via the terminal/console. This is a great read: [electronicshub](https://www.electronicshub.org/setup-static-ip-address-raspberry-pi/). Example of the relevant part of my `dhcpcd.conf`:

```
# Example static IP configuration:
interface eth0
static ip_address=192.168.1.123/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
static routers=192.168.1.254
#static domain_name_servers=192.168.2.254 8.8.8.8 fd51:42f8:caae:d92e::1
static domain_name_servers=192.168.1.254
```

Reboot your Raspberry to see if it is still working and can still connect to the internet. This can be tested in the terminal by running `ping github.com`. In case this ping test fails, [further reading](https://duckduckgo.com/?q=raspberry+set+up+static+ip) may be required.

### Step 5: enable secure shell access

You probably want to be able to control your Raspberry from anywhere in the world. Checking the logs or restarting the server can be useful and fun. Even on your smartphone you could use [Termux](https://termux.com/) on Android or [iSH](https://ish.app/) on Apple iOS to access your Raspberry Pi server. First let's open a root shell: `sudo -s`. Then make sure your system is updated: `apt-get update && apt-get -y upgrade`, that will take a while and restart afterward. Now enable the SSH login feature with command: `systemctl --now enable ssh`. And update your user password with `passwd pi`, make sure you create a strong password.

Lastly, find out your Raspberry's public internet IP address with command `curl ipecho.net/plain;echo`. Note this is NOT the same as `192.168.1.123` from above. Let's say for this article, your IP address (public host name) is `1.2.3.4`.

### Step 6: log in from a remote machine

From a Windows machine you could use [PuTTY](https://putty.org/) to log in. In the *Host Name* field put `pi@1.2.3.4`, make sure SSH is checked and press **Open**. You probably don't want to type the password every time so there is some [further reading](https://duckduckgo.com/?q=putty+automatic+ssh+login) to automate this.
The same for Termux and iSH, make sure package `openssh` is installed and you can automate login by generating another key for your device with `ssh-keygen` and `ssh-copy-id`. Combine this with a good `~/.ssh/config` file on your phone:
```
Host lto
    User pi
    HostName 1.2.3.4
    Port 22
```
With probably a bit of [further reading](https://wiki.termux.com/wiki/Remote_Access) you should be ready to simply type `ssh lto` into your phone's terminal app. You will then have complete control of your Raspberry from any place with internet in the world.

## Setting up the LTO node

The LTO Network blockchain software is written in Java, make sure Java is installed on your Raspberry:

    java -version || apt install oracle-java8-jdk

For hashing your keys securely on your machine with the `baser.py` script, add these Python packages:

    pip3 install pyblake2 base58

Finally we're at the LTO specific part and the files of this repository can be used. It is assumed you want to run the server as user named **pi** since this is the default user name on most Raspberry Pi systems. Let's install all the required files from this repository to your Raspberry:

    git clone https://github.com/matteljay/lto-raspberry && sudo lto-raspberry/install.sh

The folder `~/java-lto/scripts/` will be added to your PATH environment but you need to completely log out of your SSH session and log in again to activate it. Assuming you created a wallet seed at [wallet.lto.network](https://wallet.lto.network/start), you should now base58 encode it by running:

    ~/java-lto/scripts/baser.py

Copy-paste (or type) the complete seed phrase and press enter. Then edit your LTO configuration:

    nano ~/java-lto/lto-mainnet.conf

And paste that base58 value into the `# seed = ""` setting, remove the prefixed `#` character. While you're editing that file, you can personalize the `node-name` and `declared-address` settings.

Extra: if you would like to activate the rest-api and personalize the `api-key-hash` value, you should use command `baser.py --hash` and type any strong plain text password of your choosing to generate the hash.

Save the config file (Ctrl + O) and exit nano (Ctrl + X).

Then start the LTO server and enable it at every server reboot with:

    systemctl --now enable lto

The added commands from the `scripts/` folder makes your server more user friendly:
- `logs` - allow you to monitor the relevant logs especially microblock stats, exit with Ctrl+C
- `stop` - stops LTO service, more verbose wrapper for `systemctl stop lto`
- `start` - starts LTO service, more verbose wrapper for `systemctl start lto` 
- `reboot` - simple wrapper for `sudo reboot`, reboots the Raspberry Pi
- `baser.py` - encodes strings to base58 with the option to perform blake2b/sha-256 hash first

## Contact info & donations

See the [contact file](CONTACT.md)

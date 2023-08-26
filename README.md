# KeepTails

_**Script to backup and restore gnome settings for Tails OS**_

---

## Get/Use

Clone the project using **Git:**

```bash
  git clone https://github.com/TechWhizKid/KeepTails.git
```

**To save and load settings for Tails OS, follow these steps:**

1. Enable "dotfiles" from the persistence storage settings.
2. Copy the script (`keeptails.sh`) into the dotfiles folder.
3. Open a terminal and run the command `sudo chmod +x keeptails.sh`. Make sure to set up the "Administrator password" from the welcome screen to perform sudo operations.
4. Restart Tails OS if "dotfiles" is enabled for the first time.
5. Open a terminal and run the command `./keeptails.sh backup` to backup all settings.
6. Press `Ctrl + H` to enable "show hidden files", then copy the settings file (`.gnome_settings`) into the dotfiles folder.

**Important Note:** If you are using a custom wallpaper that is not available directly in the settings, you must manually change the location of the wallpaper. Keep the wallpaper in the persistence folder and modify the "picture-uri" in the settings file under `[org/gnome/desktop/background]` to `file:///home/amnesia/Persistent/example.jpg`.

**Now you are all set! You can run `./keeptails.sh load` to load the backed-up settings directly from the home folder.**

---

**You can try out the `example.conf` using the following command:**

```
./keeptails.sh load example.conf
```

_**The script enables you to save settings modified using the gnome-tweaks app without requiring the installation of gnome-tweaks every time.**_

```
Usage: ./keeptails.sh [load/backup] [filename]
Options:
  load     : Load gnome settings from backup (default: load from default file)
  backup   : Make a backup of gnome settings (default: use default filename)
  filename : Specify the filename for backup/restore (optional)
  -h, --help : Display this help message
```

---

##### Extra information.

The reason you have to change the wallpaper location mannually is because when you set a wallpaper, a copy of it is created in the `/home/amnesia/Pictures/Wallpapers/` folder. This copy is used as the wallpaper to ensure it is preserved even if the original file is deleted. However, this copied file is temporary and will be removed upon the next reboot. As a result, the `./keeptails.sh backup` script will back up this temporary location. Therefore, after loading the settings using `./keeptails.sh load`, you must manually update the wallpaper location in the `.gnome_settings` file under `[org/gnome/desktop/background]` to point to your desired wallpaper location in the persistence folder.

---

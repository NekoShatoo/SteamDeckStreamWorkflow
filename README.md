# SteamDeck Stream Workflow

This project enhances the display experience of Sunshine streaming on SteamDeck by adjusting the output resolution for a cleaner and more optimal view on an iPad.

![IMG_9878_small](https://github.com/user-attachments/assets/33ad164d-e661-4ab1-8839-2634f2466e80)

---

## Prerequisites

0. Basic computer skills (file creation and editing)
1. Sunshine installed and configured from the Discover store
2. Sunshine’s language set to English

**Note:**  
This guide is designed for a 13-inch iPad client. Instructions for custom resolutions can be found in the section below.

---

## Setup Steps

### 1. Create `.xprofile`

In your **Home directory**, create a file named `.xprofile` and add the following:

```bash
xrandr --newmode "1200x1600_60.00"  162.25  1200 1288 1416 1632  1600 1603 1613 1658 -hsync +vsync
xrandr --newmode "1200x1600_120.00"  342.50  1200 1304 1432 1664  1600 1603 1613 1717 -hsync +vsync
xrandr --addmode eDP "1200x1600_60.00"
xrandr --addmode eDP "1200x1600_120.00"
````

<img width="1337" height="781" src="https://github.com/user-attachments/assets/ea4bc0a2-cd48-438e-b631-3f089b889621" />

---

### 2. Prepare the Scripts

Place all files from this repository into a dedicated folder in your Home directory (ensure it will not be deleted).
Right-click the files → **Properties → Permissions**, and enable **Execute**.

<img width="1017" height="725" src="https://github.com/user-attachments/assets/3a49db0b-5c05-4122-ab33-8c911d865b3f" />

---

### 3. Add Autostart Entry

Open:

**System Settings → Autostart → Add New → Login Script**
Select **AutoSunshine.sh**.

<img width="1019" height="741" src="https://github.com/user-attachments/assets/dcb5c0c8-3a85-4e9a-89fb-aab9e14744a6" />

---

### 4. Configure Script Path

Open the properties of the added `AutoSunshine.sh` entry and set:

**WorkPath → the folder containing the three `.sh` files**

<img width="1164" height="670" src="https://github.com/user-attachments/assets/161e2ac8-6993-40be-8198-9d1917849525" />

---

### 5. Finish

Reboot the system.
On the next Sunshine connection, the SteamDeck display will automatically switch to the specified resolution.

---

## Custom Resolutions

### 1. `.xprofile` Stores Resolution Modes

Extra resolutions can be added at startup by editing `.xprofile`.

---

### 2. Generate a New Resolution

Use:

```bash
cvt <width> <height> <refresh>
```

**Important:**
SteamDeck’s physical panel is vertically oriented, so swap width and height when generating your target resolution.

Example:

<img width="886" height="132" src="https://github.com/user-attachments/assets/84f4b986-ad16-4fa1-979a-ab71a1d6a4dd" />

After generating a modeline:

* Add it to `.xprofile` following the existing structure
* Update `SunshineDisplay.sh` by adding your new mode

---

### 3. Other SteamOS Devices

You may use this workflow on other SteamOS devices.
Retrieve your display’s available modes:

```bash
xrandr
```

Then update the mode name inside `ResetMainDisplay.sh` accordingly.

---

## Additional Information

1. Multi-monitor setups have not been tested; unexpected behavior may occur.
2. To preserve your desktop state, enabling hibernation is recommended:
   [https://github.com/nazar256/publications/blob/main/guides/steam-deck-hibernation.md](https://github.com/nazar256/publications/blob/main/guides/steam-deck-hibernation.md)
3. Based on testing, using an iPhone 16 Pro as a hotspot for both iPad and SteamDeck can achieve stable 120 Hz streaming.
4. Verified behavior:

   * Display returns to normal when putting the SteamDeck to sleep
   * Display resets automatically after reboot
     This prevents accidental black-screen scenarios.

---


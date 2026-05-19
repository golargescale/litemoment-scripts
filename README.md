# litemoment-scripts
 Addon scripts for litemoment video processing

reocat can merge Reolink camera SD card recordings to a single MP4 file, it's fast. Here you can find Mac/Win/Android(Termux) versions. All require ffmpeg installed as dependency.

**Mac:**

brew install ffmpeg

copy script folder to hard drive and run, read source code for options

```
chmod +x reocat.sh.command
```

**Win:**

copy script folder to hard drive

**Step 1: Confirm the Drive Letter**\
Copy the "win-reocat" directory to the hard drive of your Windows computer. Please open and edit the 10th line of the script "reocat.bat":
```batch
set "targetDir=E:\Mp4Record"
```
Change the drive letter "E:" to the letter assigned to your computer after inserting the card.

**Step 2: Insert the SD card from the grassroots veo camera and verify the correct drive letter.**\
Run "reocat.bat" Upon successful execution, a complete 4K video of the event will be generated.

ffmpeg.org for Win32 binary download and install

in win-reocat/bin please read instruction how to download and put ffmpeg exe files in to this folder. You can also edit line 13 of reocat.bat for other folder path.

Tip: **Avidemuxer** is my personal favorite video editor for trimming generated mp4 quickly on Win. Howto format SD card bigger than 32G on Windows https://www.howtogeek.com/316977/how-to-format-usb-drives-larger-than-32gb-with-fat32-on-windows/

**Android:** *You have to copy recording date folder to internal storage before processing

**Experimental: Now you can quickly trim video with Android without PC**
1. Install termux-reocat scripts
2. Record QR Screen Time at the beginning of video
3. Upload lite clicks to cloud after game(LiteButton, WebApp or Flic 2, watch tutorial videos)
4. Copy video from REOCAM SD card to Android
5. Run termux-reocat to trim lites in just minutes
6. Optional: You can use Google photo or other app like "Video Crop" to process trimed lites right on your phone

Android QR Screen Time Companion App APK download
https://www.litemoment.com/update/apk/QR_Screen_Time.apk

Install Termux,Termux:API,Termux:Widget (F-Droid has the official release, Play Store version is obseleted)

**Step 1: Install Termux - Note that F-Droid is the official distribution channel for Termux.**
```bash
pkg upgr
pkg install ffmpeg
termux-setup-storage
pkg install zbar
pkg install termux-api
pkg install python
pkg install opencv-python
pkg install rsync
pip install moviepy
pip install requests
pip install pyzbar
pip install ffmpeg-python
pip install jinja2

Note: --fix-missing might be needed
```

**Step 2: Create a Working Directory**
```bash
mkdir -p storage/dcim/litemoment-scripts/Mp4Record
cp -r termux-reocat storage/dcim/litemoment-scripts/
```

**Step 3: Usage Instructions**\
Copy the date directory (e.g., 2023-12-15) from the SD card's Mp4Record to the phone's storage in the directory DCIM/litemoment/Mp4Record using the system file manager. In Termux, enter:
```bash
cd storage/dcim/litemoment-scripts/termux-reocat
bash reocat.sh
```

Upon successful execution, a merged 4K video of the recordings will be generated.


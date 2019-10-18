# FLAC-to-MP3
Automatically convert FLAC files to MP3

Download the script and modify the settings.
* Important variables are the MusicFolder, BitRate, ShowGui and YesLog
* If ShowGui is enabled it becomes a standalone app, will not work as a background script
* Place the file somewhere it can stay

Inside Lidarr go to the connect settings page
* add a new connection as a Custom Script
* Point the path to the script
* Make sure to only have the script active on download or upgrade.
* This script requires that you have FFMPEG installed into your environment variables PATH

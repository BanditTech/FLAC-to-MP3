# FLAC-to-MP3
Automatically convert FLAC files to MP3

Download the script and modify the settings for deleting the origin files, and set the bitrate.
* Once configured compile the AHK file into an EXE
* Place the file somewhere it can stay

Inside Lidarr go to the connect settings page
* add a new connection as a Custom Script
* Point the path to the compiled script, and in arguements place your Music collection folder
* Make sure to only have the script active on download or upgrade.
* This script requires that you have FFMPEG installed into your environment variables PATH

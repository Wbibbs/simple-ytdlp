# simple ytdlp
*A Bash wrapper for [yt-dlp](https://github.com/yt-dlp/yt-dlp) to download audio and video with minimal effort*

---

## Features

- Download **video + audio** or **audio only**
- Automatically organizes downloads by **media type** and **date**.
- Retry mechanism for content requiring login/cookies.
- Logs failed downloads to `failed_downloads.log`.

---

## Installation

1. Ensure you have ```yt-dlp``` installed

2. Save the script as **sytdlp.sh** (or however you wish to name it) and make it executable
```bash
chmod +x sytdlp.sh
```
3. (Optional) Set the download directory via the ```SYTDLP_BASE_DIR``` variable
```bash
export $SYTDLP_BASE_DIR="/my/custom/dir"
```
4. (Optional) Add the script to your ```PATH``` for easy execution from anywhere


## To Do

* Write more generic cookie handling, and not tie it to a single browser

* Provide the user with the option to define their own output folder format, or none at all

## Notes
I have used this script for a little while now, and figured to share it in the hopes others also find it useful. Downloading a video
takes little more than a few moments to grab the URL and invoke the script to have a nicely organized and painless downloading experience!

Feedback is always welcome. Thank you for looking at my little project
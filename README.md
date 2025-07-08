# MPify
A open-source Flutter app to manage and play offline music - with support for downloading MP3s from Youtube using `yt-dlp`.  

This app uses FFmpeg (https://ffmpeg.org), licensed under the GNU General Public License v3.
Source code for this application is available at: https://github.com/your-repo

> **DISCLAIMER:** This project does not host, share, or facilitate of any copyrighted material.  
Mpify provides a graphical for `yt-dlp`. User are responsible for their usage and must follow  
local laws and Youtube's TOS.

The developer of this project does not endorse or take any responsibility for any misuse, including  
attempts to profit from copyrighted material using this tool.  

# Features
- Offline MP3 playback.  
- Ability to add/delete/edit album.  
- Download MP3 from Youtube via `yt-dlp`.  
- Lightweight and minimal UI.  
  
# Screenshot  
![MPify UI Preview](/mpify/assets/example_1.png)  
![MPify UI Preview](/mpify/assets/example_2.png)  
![MPify UI Preview](/mpify/assets/example_3.png)  
![MPify UI Preview](/mpify/assets/example_4.png)  
  
# Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- Flutter version ^3.8.1  
- [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases)  
- [FFmpeg & FFprobe](https://www.gyan.dev/ffmpeg/builds/)
# Installation  
  
### 1. Clone the repo: 
- git clone https://github.com/Harpcheemse/Mpify.git  

### 2. Install Dependencies
This tool simply provides a GUI to `yt-dlp` and ease of managing files.  
By donwloading `yt-dlp`, user agrees to be responsible for any misconduct.  

- Place yt-dlp.exe directly in the root folder.
- Place FFmpeg & FFprobe directly in the root folder.  
- Add the Mpify folder path to your system's PATH in enviroment variables.  
- Run: "flutter pub get" to get the dependencies.

### 3. Run the app: 
- flutter run  
## License  

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.  

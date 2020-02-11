#### Media Works Shell Scripts
## [**msslib**](msslib)
It uses **ffmpeg, bash** and some simple commands to normalize audio volume, compress audio volume, recompress, accelerate/deaccelerate the speed, split video/audio files and so on. There are scripts:
- to process video
  - **nvenc2mp4** - nvidia hardware accelerated video transcoding script
  - **mpeh** - allow to find a "high motion" zones and increase bitrate of them during analysing x264-2-pass.log file
  - **csvc** - acceleration and deacceleration the speed for video files or cuts in video files during reencoding
- to process audio streams in video files
  - **fdrch+** - force dynamic range compression to center channel, makes the sound of center channel (FC) louder, it also contain "fdrc" functionality for stereo/mono channels
- to process audio only
  - **nit** - "normalize it" - normalize the volume of audio files
  - **cuesplit** - split one audio into separate flac files corresponding to the CUE
  - **tempo** - acceleration and deacceleration the speed of audio files
  - **lca** - add a local cover picture to mp3 or flac or mka -files
>**for help run ./msslib -h**

There are [**old versions of scripts**](archive) 

There are some [**examples**](some_examples) of how it can be used

### Some demonstration of work 
./[**msslib**](msslib) fdrch+
![fig1](fdrch_demo.gif)

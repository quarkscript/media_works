## Media Works Shell Scripts

##### Video

- [**nvenc2mp4**](nvenc2mp4) -nvidia hardware accelerated video transcoding script: mkv, webm, flv, ts, avi to mp4 [Video demonstration](http://www.youtube.com/watch?v=393S58i6VnM)

- [**mpeh**](mpeh) - experimental helper script for x264 multi-pass encoding, it allow to find a "high motion" zones and increase bitrate of them

- [**csvc**](csvc) - changing the speed for video file or for cuts in video file during reencoding. A demonstration of the work of this script can be found in the [playlist](https://www.youtube.com/playlist?list=PLCEQBF42fgWP4pWrBDskJCboBldHUo8ym), except for the first video from the playlist.

##### Audio streams in video files

- [**fdrc**](fdrc) - "force dynamic range compression" makes the sound of video files in the format *.mkv or *.mp4 louder, but not an  equivalent to sources, so it suitable for movies and cartoons, but not for concerts and music. This is best used for stereo channels or downmix to stereo. [Video demonstration](http://www.youtube.com/watch?v=PAv4LF05Bes)

- [**fdrch**](fdrch) or [**fdrch+**](fdrch+) - "Force Dynamic Range Compression to center cHannel" makes the sound of video files in the format *.mkv louder. This is best used for multichannel audio streams with a center channel (FC) [Demonstration](fdrch_demo.gif)

##### Audio

- [**nit**](nit) - "normalize it" - bash script that normalize the volume of audio files

- [**cuesplit**](cuesplit) - Splitting one audio into separate flac files corresponding to the CUE

- [**tempo**](tempo) - shell script that allow to "overclock" or "underclock" speed of audio files

[**msslib**](msslib) - all previous scripts in single file (+ new function - 'lca' - add a local cover art to mp3, flac or mka)

**More simpler scripts:**

- [**normnconv**](normnconv) - normalize audio/music during convert it to *.ogg 

- [**f2fn**](f2fn) ~~(fvn)~~ - normalize and recompress flac to flac, equivalent but louder if possible.

>**For more help see script code**

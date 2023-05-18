# remux-script

A script that remuxes .mkv files to .mp4 files using ffmpeg.

**Both the README.md and script are still somewhat being worked on, however as of version 0.1.0 it is usuable.**

## Config file

From the first release (0.1.0) onwrads, the script will utilize a `conf.ini` file. This will not be included inthe github repository or release packages, but instead will be auto-generated by the script. The template generated by the script will be :

```ini
[MAIN]
CRF=20
PRESET=5
TUNE=1
ColorspaceConversion=0
ConvertToProRes=0
```

A small part of the documentation will be dedicated to using and understanding these settings, but for now please visit this [website](https://trac.ffmpeg.org/wiki/Encode/H.264).

Code heavily inspired by [gmzorz's prorec script.](https://github.com/gmzorz/prerecs)

## Author Notes:

-   The -crf value is set to 0 which normally means lossless, so it may be extremely slow depending on file specifics.
-   The tune is specifically set for animtion, so the output will have higher deblocking than normal to keep things looking smooth
-   The preset is set to veryslow which prioritizes conserving the bitrate.
-   The script assumes that the original .mkv file is in a codec that the .mp4 container supports.
-   Latest version dropped -ar flag which specifies audio sampling frequency. (This is kept the same as the input file)

For more information on H.264 encoding, read:

https://trac.ffmpeg.org/wiki/Encode/H.264

## To-Do

-   [ ] Further testing into remuxing times
-   [ ] How to use & install
-   [ ] Auto-config saving
-   [ ] Simple and Advanced modes
-   [ ] Update the README.md

## Credit

-   KiraEdits for originally introducing me to remuxing with ffmpeg back in 2021.
-   Gmzorz for his work on prorec as well as help with other projects.
-   Dre and Sofy for encouragement and showing me love.

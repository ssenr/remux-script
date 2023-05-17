# remux-script

A script that remuxes .mkv files to .mp4 files using ffmpeg.

Code heavily inspired by [gmzorz's prorec script:](https://github.com/gmzorz/prerecs)

## Author Notes:

-   The -crf value is set to 0 which normally means lossless, so it may be extremely slow depending on file specifics.
-   The tune is specifically set for film, so the output will have higher deblocking than normal to keep things looking smooth
-   The preset is set to veryslow which prioritizes conserving the bitrate.

For more information on H.264 encoding, read:

https://trac.ffmpeg.org/wiki/Encode/H.264

TESTS

-   2023-05-16
-   Works on AE 2021

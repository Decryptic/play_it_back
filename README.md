# Play it Back

An open source Flutter project for recording audio and playing it in reverse.

<!-- TODO hyperreference play store URL -->
<p align="middle">
  <a href=""><img src="https://raw.githubusercontent.com/Decryptic/Decryptic/main/google_play_badge.png" width="300"></a>
  <a href="https://apps.apple.com/app/play-it-back/id6455259987"><img src="https://raw.githubusercontent.com/Decryptic/Decryptic/main/app_store_badge.png" width="300"></a>
</p>

<p align="middle">
  <img src="https://raw.githubusercontent.com/Decryptic/play_it_back/main/assets/screenshots/iphone_11_pro_max/001.png" width="300">
  <img src="https://raw.githubusercontent.com/Decryptic/play_it_back/main/assets/screenshots/iphone_11_pro_max/002.png" width="300">
</p>

## Getting Started
```
flutter run
```

Press the record button to start recording.
Then, press the stop button to stop.
Afterward, the play controls will be enabled.

The forward play button will play the audio forward.
The reverse play button will play the audio in reverse.

You can stop playing with the floating action button while audio is playing.
You can record a new clip with the floating action button while idle.

## Notes

This is the first open-source app that I will try and sell on the app stores for $1.
If you are so inclined, you can build the app and run it for free.

In hindsight, it would probably have been more straightforward to build two native apps.
I had to use three libraries to create this very simplistic app.

<a href="https://pub.dev/packages/audioplayers">AudioPlayers</a> was used to play the audio.

<a href="https://pub.dev/packages/record/example">Record</a> was used to record audio. This library took some extra time to implement because their <a href="https://github.com/llfbandit/record">example code on GitHub</a> appears to be deprecated. Apparently they renamed the `AudioRecorder` object `Record`. Their example code on Pub.dev does work.

To play the audio in reverse, I used the <a href="https://pub.dev/packages/ffmpeg_kit_flutter">ffmpeg_kit</a> for Flutter, using the command `ffmpeg -i input -af output`. I was hoping to set the `playback speed` to -1 in AudioPlayers, but the playback speed only supports a range of 0.5 to 2.0.

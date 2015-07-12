# HKWPlayer

* HKWPlayer is a sample Music player application that plays MP3 audio files on the iPhone. You can create and manage a playlist with MP3 files stored in iOS Music app, and play songs to Omni speakers in the network.
* The purpose of the app is to demonstrate the key features of the HKWirelessHD SDK.  

## Release Notes (v1.2)
### Features
* Support for Web Streaming audio
* Support for Mute/Unmute

----
## Release Notes (v1.1)
### Features
* Replaced the callback functions with Delegate protocols
  - Plrease refer to HKWPlayerEventHandlerSingleton.h and HKWDeviceEventHandelerSingleton.h
* Apple Watch Support
  -  If user installs the HKWPlayer app on the iPhone and enable "Show App on Apple Watch" option in Apple Watch app, then the corresponding watch app will appear in the menu screen of Apple Watch.
  - Apple watch app also supports Glance view. It is useful to check the current playback information easily.

## Release Notes (v1.0)

### Features
* Support playlist
  - User can add songs from iOS Music app (via Media Picker) to the playlist, and delete a song from the list.
  - Skip forward and backward during the playback.
  - Select or deselect speakers to play on during the playback.
  - Volume control for the entire speakers simultaneously.
  - Volume control of individual speaker

* View and change speaker information:
  - view or change speaker name
  - view the model name and the firmware version of the speaker
  - view or change group that the speaker belongs to
  - view the current WiFi signal strength and IP address
#
# Be sure to run `pod lib lint LMMediaPlayer.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LMMediaPlayer"
  s.version          = "0.2.1"
  s.summary          = "Video and audio player with replaceable UI component."
  s.homepage         = "https://github.com/0x0c/LMMediaPlayer"

  s.license          = 'MIT'
  s.author           = { "Akira Matsuda" => "akira.matsuda@me.com" }
  s.source           = { :git => "https://github.com/0x0c/LMMediaPlayer.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resources = ['Pod/Assets/LMMediaPlayerView.xib', 'Pod/Assets/LMMediaPlayerView.bundle']

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'AVFoundation', 'MediaPlayer'

    s.description  = <<-DESC
LMMediaPlayer is a video and audio player for iPhone with changeable user interface.

![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/2.png)

![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/1.png)
![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/3.png)

Requirements
====

- Runs on iOS 6.0 or later.
- Must be complied with ARC.

Intstallation
===

First, please add these frameworks.

===
  #import <MediaPlayer/MediaPlayer.h>
  #import <AVFoundation/AVFoundation.h>
===

Second, add files which is contained "LMMediaPlayer" folder.

That's it.

If you want to play with fullscreen mode, please add "View controller-based status bar appearance" key and set value with "NO" at your Info.plist
                   DESC
end

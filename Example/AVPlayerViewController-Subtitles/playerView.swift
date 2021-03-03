//
//  FixedFramePlayer.swift
//  test
//
//  Created by Isabel Lee on 1/24/19.
//  Copyright © 2019 littlstar. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol FixedFramePlayerDelegate {
  func fixedFramePlayerDidChangeBufferingStatus(buffering: Bool)
  func fixedFramePlayerDidReceiveSingleTap()
  func fixedFramePlayerDidReachEnd()
  func fixedFramePlayerDidUpdateProgress(currentTime: Double, availableTime: Double, totalDuration: Double)
  @objc optional func fixedFramePlayerStartPlayingAds()
  @objc optional func fixedFramePlayerEndPlayingAds()
}

// fixed frame video player view with simple play/pause/replay features
class FixedFramePlayer: UIView {
  let subtitleUrl = URL(string: "https://gist.githubusercontent.com/ijl0322/5b2d5a5b392b965acfac8117447526f8/raw/5c1103253974de30807511a87a47807321807a99/test2.srt")
  var subtitleData: NSDictionary?
  var player:AVPlayer?
  var playerItem:AVPlayerItem?
  var autoLoop = false
  var playerLayer:AVPlayerLayer?
  var observer: Any?
  var delegate: FixedFramePlayerDelegate?
  var notBuffering = false
  var videoDuration: Double?
  var isPaused: Bool {
    return player?.timeControlStatus == .paused
  }
  var seeked: Bool = false
  var isLive: Bool {
    return videoDuration == nil
  }
  var currentTime: Double = 0.0
  var subtitleLabel: UILabel!

  init(frame: CGRect, url: URL?, duration: Double?, autoLoop: Bool = false, contentMode: AVLayerVideoGravity = .resizeAspectFill) {
    super.init(frame: frame)
    self.autoLoop = autoLoop
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playTapped)))

    guard let url = url else { return }
    playerItem = AVPlayerItem(url: url)
    player = AVPlayer(playerItem: playerItem)
    playerLayer = AVPlayerLayer(player: player)
    playerLayer!.frame = frame
    playerLayer!.videoGravity = contentMode
    layer.addSublayer(playerLayer!)

    subtitleLabel = UILabel(frame: frame)
    subtitleLabel.textColor = .cyan
    subtitleLabel.text = "sub title"
    addSubview(subtitleLabel)

    Subtitles.open(fileFromRemote: subtitleUrl!, completion: { subtitles in
      self.subtitleData = subtitles
    })

    NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)

    observer = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main, using: { (time) in
      self.timeObserverUpdate(time: time)
    })
  }

  func timeObserverUpdate(time: CMTime) {
    guard let currentItem = self.player?.currentItem else { return }
    let duration = playerItem?.asset.duration.seconds
    if (duration?.isNaN == false) {
      videoDuration = duration
    }
    var bufferedDuration = time.seconds
    if currentItem.status == .readyToPlay {
      if currentItem.loadedTimeRanges.count > 1 {
        let bufferedTimeRange = currentItem.loadedTimeRanges[0].timeRangeValue
        bufferedDuration = CMTimeGetSeconds(bufferedTimeRange.duration)
      }
      if seeked == true {
        // After seeking, observer updates once with previous time,
        // causing UI glitch. Omit that one off time and return
        seeked = false
        return
      }
      self.currentTime = time.seconds
      self.delegate?.fixedFramePlayerDidUpdateProgress(currentTime: time.seconds, availableTime: bufferedDuration, totalDuration: videoDuration ?? 0.0)
    }
    if currentItem.isPlaybackLikelyToKeepUp != self.notBuffering {
      // Only call delegate method if buffering state changed
      self.notBuffering = currentItem.isPlaybackLikelyToKeepUp
      self.delegate?.fixedFramePlayerDidChangeBufferingStatus(buffering: !self.notBuffering)
    }

    guard let subtitleData = subtitleData else {
      return
    }
    // Search && show subtitles
    subtitleLabel.text = Subtitles.searchSubtitles(at: time.seconds, parsedData: subtitleData)
  }

  @objc func playTapped() {
    self.delegate?.fixedFramePlayerDidReceiveSingleTap()
  }

  // Seek video to start to prepare for replay
  @objc func playerDidFinishPlaying(note: NSNotification) {
    self.delegate?.fixedFramePlayerDidReachEnd()
    reset()
  }

  func reset() {
    player?.pause()
    player?.seek(to: kCMTimeZero)
    if autoLoop {
      player?.play()
    }
  }

  func play() {
    player?.play()
  }

  func pause() {
    player?.pause()
  }

  func seek(to seconds: CGFloat) {
    player?.pause()
    let seconds = CMTime(seconds: Double(seconds), preferredTimescale: 1000)
    player?.seek(to: seconds, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    player?.play()
    seeked = true
  }

  override func layoutSubviews() {
    // Needed for auto layout resizing
    guard self.playerLayer != nil else { return }
    self.playerLayer!.frame = self.bounds
  }

  // Need to call this before deinit to prevent memory leak
  func cleanUp() {
    NotificationCenter.default.removeObserver(self)
    if observer != nil {
      player?.removeTimeObserver(observer!)
    }
    playerLayer?.removeFromSuperlayer()
    playerLayer = nil
    playerItem = nil
    player = nil
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


//
//  ViewController.swift
//  AVPlayerViewController-Subtitles
//
//  Created by mhergon on 23/12/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class ViewController: UIViewController {
  var videoView: FixedFramePlayer!
  var subtitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      let vidUrl = URL(string: "https://edge.mhq.12core.net/7e8dc730c769fe0be7f72b09cfeabf2b.m3u8")!
      videoView = FixedFramePlayer(frame: CGRect(x: 0, y: 100, width: view.frame.width, height:  view.frame.width), url: vidUrl, duration: 300)
      view.addSubview(videoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Actions
    @IBAction func showVideo(_ sender: UIButton) {
      videoView.play()
        // Movie player
//        let moviePlayer = AVPlayerViewController()

//      moviePlayer.player = AVPlayer(url: URL(string: "https://edge.mhq.12core.net/7e8dc730c769fe0be7f72b09cfeabf2b.m3u8")!)
//        present(moviePlayer, animated: true, completion: nil)

        // Add subtitles - local
        // moviePlayer.addSubtitles().open(fileFromLocal: subtitleURL)
        // moviePlayer.addSubtitles().open(fileFromLocal: subtitleURL, encoding: .utf8)

        // Add subtitles - remote

      //addSubtitles().open(fileFromRemote: subtitleRemoteUrl!)

        // Change text properties
        //moviePlayer.subtitleLabel?.textColor = UIColor.red

        // Play
        //moviePlayer.player?.play()

    }
}



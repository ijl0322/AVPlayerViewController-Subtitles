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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Actions
    @IBAction func showVideo(_ sender: UIButton) {

        // Video file
        //let videoFile = Bundle.main.path(forResource: "trailer_720p", ofType: "mov")

        // Local subtitle file
        //let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
        //let subtitleURL = URL(fileURLWithPath: subtitleFile!)

        // Remote subtitle file
        let subtitleRemoteUrl = URL(string: "https://gist.githubusercontent.com/ijl0322/5b2d5a5b392b965acfac8117447526f8/raw/5c1103253974de30807511a87a47807321807a99/test2.srt")

        // Movie player
        let moviePlayer = AVPlayerViewController()
      moviePlayer.player = AVPlayer(url: URL(string: "https://edge.mhq.12core.net/7e8dc730c769fe0be7f72b09cfeabf2b.m3u8")!)
        present(moviePlayer, animated: true, completion: nil)

        // Add subtitles - local
        // moviePlayer.addSubtitles().open(fileFromLocal: subtitleURL)
        // moviePlayer.addSubtitles().open(fileFromLocal: subtitleURL, encoding: .utf8)

        // Add subtitles - remote
        moviePlayer.addSubtitles().open(fileFromRemote: subtitleRemoteUrl!)

        // Change text properties
        moviePlayer.subtitleLabel?.textColor = UIColor.red

        // Play
        moviePlayer.player?.play()

    }

    func subtitleParser() {

        // Subtitle file
        let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt")
        let subtitleURL = URL(fileURLWithPath: subtitleFile!)

        // Subtitle parser
        let parser = Subtitles(file: subtitleURL, encoding: .utf8)

        // Do something with result
        _ = parser.searchSubtitles(at: 2.0) // Search subtitle at 2.0 seconds

    }

}



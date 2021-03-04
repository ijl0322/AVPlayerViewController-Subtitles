//
//  SubtitlesAVPlayer.swift
//  AVPlayerViewController-Subtitles
//
//  Created by Isabel Lee on 3/3/21.
//  Copyright © 2021 Marc Hervera. All rights reserved.
//

import Foundation
//
//  Subtitles.swift
//  Subtitles
//
//  Created by mhergon on 23/12/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import ObjectiveC
import MediaPlayer
import AVKit
import CoreMedia

@objc public class Subtitles : NSObject {

  // MARK: - Properties
  fileprivate var parsedPayload: NSDictionary?

  @objc public static func searchSubtitles(at time: TimeInterval, parsedData: NSDictionary) -> String? {
    return Subtitles.searchSubtitles(parsedData, time)
  }

  fileprivate static func parseSubRip(_ payload: String) -> NSDictionary? {

    do {

      // Prepare payload
      var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
      payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
      payload = payload.replacingOccurrences(of: "\r\n", with: "\n")

      // Parsed dict
      let parsed = NSMutableDictionary()

      // Get groups
      let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
      let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
      let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))

      for m in matches {

        let group = (payload as NSString).substring(with: m.range)

        // Get index
        var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
        var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
        guard let i = match.first else {
          continue
        }
        let index = (group as NSString).substring(with: i.range)

        // Get "from" & "to" time
        regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
        match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
        guard match.count == 2 else {
          continue
        }
        guard let from = match.first, let to = match.last else {
          continue
        }

        var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0

        let fromStr = (group as NSString).substring(with: from.range)
        var scanner = Scanner(string: fromStr)
        scanner.scanDouble(&h)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&m)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&s)
        scanner.scanString(",", into: nil)
        scanner.scanDouble(&c)
        let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)

        let toStr = (group as NSString).substring(with: to.range)
        scanner = Scanner(string: toStr)
        scanner.scanDouble(&h)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&m)
        scanner.scanString(":", into: nil)
        scanner.scanDouble(&s)
        scanner.scanString(",", into: nil)
        scanner.scanDouble(&c)
        let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)

        // Get text & check if empty
        let range = NSMakeRange(0, to.range.location + to.range.length + 1)
        guard (group as NSString).length - range.length > 0 else {
          continue
        }
        let text = (group as NSString).replacingCharacters(in: range, with: "")

        // Create final object
        let final = NSMutableDictionary()
        final["from"] = fromTime
        final["to"] = toTime
        final["text"] = text
        parsed[index] = final
      }
      return parsed
    } catch {
      return nil
    }
  }

  fileprivate static func searchSubtitles(_ payload: NSDictionary?, _ time: TimeInterval) -> String? {

    let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", time, "from", time, "to")

    guard let values = payload?.allValues, let result = (values as NSArray).filtered(using: predicate).first as? NSDictionary else {
      return nil
    }

    guard let text = result.value(forKey: "text") as? String else {
      return nil
    }

    return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

  static func open(fileFromRemote filePath: URL, encoding: String.Encoding = String.Encoding.utf8, completion: @escaping ((NSDictionary?) -> Void)) {

    //subtitleLabel?.text = "..."
    URLSession.shared.dataTask(with: filePath, completionHandler: { (data, response, error) -> Void in

      if let httpResponse = response as? HTTPURLResponse {
        let statusCode = httpResponse.statusCode

        //Check status code
        if statusCode != 200 {
          NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
          return
        }
      }
      if let checkData = data as Data? {
        if let contents = String(data: checkData, encoding: encoding) {
          let parsedSubtitles = parseSubRip(contents)
          completion(parsedSubtitles)
        }
      }
    }).resume()
  }
}

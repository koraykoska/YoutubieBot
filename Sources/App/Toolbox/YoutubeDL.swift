//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Foundation

struct YoutubeDL {

    let tmpPath: String

    init(tmpPath: String = "/tmp") {
        self.tmpPath = tmpPath
    }

    func downloadMP3(item: YoutubeApi.Response.Item) -> String? {
        guard let videoId = item.id.videoId else {
            return nil
        }
        let videoUrl = "https://www.youtube.com/watch?v=\(videoId)"

        let tmpName = "\(UUID().uuidString)"
        let filePath = "\"\(tmpPath)/\(tmpName).%(ext)s\""

        let command = """
        /usr/local/bin/youtube-dl -x --audio-format mp3 --ffmpeg-location /usr/local/bin --embed-thumbnail -o \(filePath) "\(videoUrl)"
        """

        let success = shell(command.split(separator: " ").map { String($0) })

        if success == 0 {
            let fileName = "\(tmpPath)/\(tmpName).mp3"
            let fileNameTmp = "\(tmpPath)/\(tmpName)tmp.mp3"

            let ct = item.snippet.channelTitle.replacingOccurrences(of: "\"", with: "\\\"")
            let t = item.snippet.title.decodingHTMLEntities().replacingOccurrences(of: "\"", with: "\\\"")
            let ffmpeg = """
            /usr/local/bin/ffmpeg -i \(fileName) -c copy -metadata artist="\(ct)" -metadata title="\(t)" \(fileNameTmp)
            """
            if shell(ffmpeg.split(separator: " ").map { String($0) }) != 0 {
                return nil
            }
            _ = shellOutput("rm \(fileName)")
            _ = shellOutput("mv \(fileNameTmp) \(fileName)")

            return fileName
        } else {
            return nil
        }
    }

    func deleteMP3(filePath: String) {
        shell(["rm", filePath])
    }

    @discardableResult
    private func shell(_ args: [String]) -> Int32 {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c"] + ["PATH=/usr/local/bin:$PATH \(args.joined(separator: " "))"]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }

    private func shellOutput(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments = ["-c", "PATH=/usr/local/bin:$PATH \(command)"]
        task.launchPath = "/bin/bash"
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}

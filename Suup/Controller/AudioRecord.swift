//
//  AudioRecord.swift
//  Suup
//
//  Created by Gauri Bhagwat on 12/07/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
import AVFoundation
class AudioRecord : NSObject,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var fileName = "audioFile.m4a"
    
    func setupRecorder(){
        let recordSettings = [ AVFormatIDKey : kAudioFormatAppleLossless,
                               AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                               AVEncoderBitRateKey: 320000,
                               AVNumberOfChannelsKey : 2,
                               AVSampleRateKey : 44100.0 ] as [String : Any]
        
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName)
        
            soundRecorder = try! AVAudioRecorder.init(url: fileURL, settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.isMeteringEnabled = true
            soundRecorder.prepareToRecord()
    }

    func startRec(){
soundRecorder.record()
}
    func stopRec(){
        soundRecorder.stop()
        do {
        var audioSession = try AVAudioSession.sharedInstance().setActive(false)
        }catch {
            print("error")
        }
}
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
        }else {
            print("error")
        }
    }
}

//
//  AudioRecorder.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/22.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let shared = AudioRecorder()
    
    private override init() {
        super.init()
        checkForRecordPermission()
    }
    
    func checkForRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("granted")
            isAudioRecordingGranted = true
            break
        case .denied:
            print("denied")
            isAudioRecordingGranted = false
            break
        case .undetermined:
            print("undetermined")
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                self.isAudioRecordingGranted = isAllowed
            }
        default:
            break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Error setting up audio recorder", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        print(audioFileName)
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error recording", error.localizedDescription)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    
}

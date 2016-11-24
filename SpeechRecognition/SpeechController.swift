//
//  SpeechController.swift
//  SpeechRecognition
//
//  Created by Stephen Anthony on 24/11/2016.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import Foundation
import Speech

class SpeechController {
    
    /// The speech recogniser used by the controller to record the user's speech.
    private let speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))!
    
    /// The current speech recognition request. Created when the user wants to begin speech recognition.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// The current speech recognition task. Created when the user wants to begin speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// The audio engine used to record input from the microphone.
    private let audioEngine = AVAudioEngine()
    
    /// The delegate of the receiver.
    var delegate: SpeechControllerDelegate?
    
    /// Begins a new speech recording session.
    ///
    /// - Throws: Errors thrown by the creation of the speech recognition session
    func startRecording() throws {
        if let recognitionTask = recognitionTask {
            // We have a recognition task still running, so cancel it before starting a new one.
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode, let recognitionRequest = recognitionRequest else {
            throw SpeechControllerError.noAudioInput
        }
        
        recognitionTask = speechRecogniser.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            var isFinal = false
            
            if let result = result {
                self.delegate?.speechController(self, didRecogniseText: result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    /// Ends the current speech recording session.
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

/// The protocol to conform to for delegates of `SpeechController`.
protocol SpeechControllerDelegate {
    
    /// The message sent when the user's speech has been transcribed. Will be called with partial results of the current recording session.
    ///
    /// - Parameters:
    ///   - speechController: The controller sending the message.
    ///   - text: The text transcribed from the user's speech.
    func speechController(_ speechController: SpeechController, didRecogniseText text: String)
}

/// The error types vended by `SpeechController` if it cannot create an audio recording session.
///
/// - noAudioInput: No audio input connection could be created.
enum SpeechControllerError: Error {
    case noAudioInput
}

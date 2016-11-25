//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Stephen Anthony on 24/11/2016.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var speechController: SpeechController = {
        let speechController = SpeechController()
        speechController.delegate = self
        return speechController
    }()
    fileprivate lazy var uiController: UIController = {
        return UIController(view: self.view, textLabel: self.textLabel)
    }()
    
    @IBOutlet private var textLabel: UILabel!

    @IBAction private func startRecording(_ sender: Any) {
        do {
            try speechController.startRecording()
        } catch {
            print("Could not begin recording")
        }
    }
    
    @IBAction private func stopRecording(_ sender: Any) {
        speechController.stopRecording()
    }
}

extension ViewController: SpeechControllerDelegate {
    func speechController(_ speechController: SpeechController, didRecogniseText text: String) {
        uiController.update(withSpokenText: text)
    }
}

//
//  UIController.swift
//  SpeechRecognition
//
//  Created by Stephen Anthony on 24/11/2016.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit

/// The class used to manage updating the application's UI in accordance with spoken text.
class UIController {
    private let view: UIView
    private let textLabel: UILabel
    
    /// The colours and their corresponding names that the controller can access.
    private lazy var coloursAndNames: Dictionary<String, UIColor> = {
        return ["black": .black,
                "white": .white,
                "gray": .gray,
                "red": .red,
                "green": .green,
                "blue": .blue,
                "cyan": .cyan,
                "yellow": .yellow,
                "magenta": .magenta,
                "orange": .orange,
                "purple": .purple,
                "brown": .brown]
    }()
    
    /// - Parameters:
    ///   - view: The view whose background colour will be modified with spoken text.
    ///   - textLabel: The text label used to display the spoken text.
    init(view: UIView, textLabel: UILabel) {
        self.view = view
        self.textLabel = textLabel
    }
    
    /// Tells the receiver to update the view and text label that it was initialised with to reflect the given text.
    ///
    /// - Parameter spokenText: The text that the user spoke.
    func update(withSpokenText spokenText: String) {
        textLabel.text = spokenText
        guard let lastWord = spokenText.components(separatedBy: .whitespaces).last, let colour = coloursAndNames[lastWord] else {
            return
        }
        view.backgroundColor = colour
    }
}

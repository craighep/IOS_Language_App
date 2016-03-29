//
//  RevisionCompletionViewController.swift
//  LanguageReviser
//
//  Created by administrator on 29/03/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class RevisionCompleteViewController: UIViewController{

    var correctAnswers = 0
    @IBOutlet weak var correctNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctNumberLabel.text = "You scored \(correctAnswers) out of 10.)"
    }
    
}
/**
 RevisionCompleteViewController.swift
 Language-Revisor
 
 Shows the user their total score following completing the quiz on the revision tab.
 Does a simple switch statement, indicating how good they are at Welsh based on their score.
 
 Created by Craig Heptinstall on 10/03/2015.
 */
import UIKit

class RevisionCompleteViewController: UIViewController{
    
    var correctAnswers = 0
    @IBOutlet weak var correctNumberLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctNumberLabel.text = "You scored \(correctAnswers) out of 10."
        switch correctAnswers {
        case 10:
            adviceLabel.text = "Your Welsh is perfect!"
            break
        case 9, 8, 7, 6:
            adviceLabel.text = "You're almost there!"
            break
        case 5, 4:
            adviceLabel.text = "Try harder next time."
            break
        case 3, 2:
            adviceLabel.text = "You have some revision to do."
            break
        case 1:
            adviceLabel.text = "Try putting some effort in."
            break
        case 0:
            adviceLabel.text = "You managed to get them all wrong..."
            break
        default:
            break
        }
    }
}
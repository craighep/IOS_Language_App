//
//  PhraseDetailsViewController.swift
//  TabBar-part1-Swift
//
//  Created by administrator on 21/03/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class PhraseDetailsViewController: UIViewController {

    var phrase:Phrase?
    @IBOutlet weak var englishTextField: UITextField!
    
    @IBOutlet weak var welshTextField: UITextField!
    
    @IBOutlet weak var noteTextField: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var schoolTagSwitch: UISwitch!
    
    @IBOutlet weak var workTagSwitch: UISwitch!
    
    @IBOutlet weak var homeTagSwitch: UISwitch!
    
    @IBOutlet weak var otherTagSwitch: UISwitch!
    
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let phrase = phrase {
            self.title = "Edit Phrase"
            englishTextField.text = phrase.english
            welshTextField.text = phrase.welsh
            noteTextField.text = phrase.note
            schoolTagSwitch.setOn(phrase.hasTag("School"), animated: false)
            workTagSwitch.setOn(phrase.hasTag("Work"), animated: false)
            homeTagSwitch.setOn(phrase.hasTag("Home"), animated: false)
            otherTagSwitch.setOn(phrase.hasTag("Other"), animated: false)
            switch phrase.type{
            case "Verb":
                typeSegmentControl.selectedSegmentIndex = 0
            case "Noun":
                typeSegmentControl.selectedSegmentIndex = 1
            default:
                typeSegmentControl.selectedSegmentIndex = 2
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidPhrase() {
        // Disable the Save button if the text field is empty.
        let english = englishTextField.text ?? ""
        let welsh = welshTextField.text ?? ""
        saveButton.enabled = !english.isEmpty || !welsh.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidPhrase()
        navigationItem.title = textField.text
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

}

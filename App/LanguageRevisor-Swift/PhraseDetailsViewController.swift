/**
 PhraseDetailsViewController.swift
 Language-Revisor
 
 Represents and provides methods for the detail view for individual phrases. Allows 
 items from the GUI to be read, such as english and welsh meanings for words.
 Takes in an initial phrase, to populate the GUI with an already existing phrase.
 Sends the user back to the PhraseViewController via segue.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import UIKit

class PhraseDetailsViewController: UIViewController, UITextFieldDelegate {

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
            // change title bar to say edit if its not a new phrase
            self.title = "Edit Phrase"
            englishTextField.text = phrase.english
            welshTextField.text = phrase.welsh
            noteTextField.text = phrase.note
            schoolTagSwitch.setOn(phrase.hasTag("School"), animated: false)
            workTagSwitch.setOn(phrase.hasTag("Work"), animated: false)
            homeTagSwitch.setOn(phrase.hasTag("Home"), animated: false)
            otherTagSwitch.setOn(phrase.hasTag("Other"), animated: false)
            switch phrase.type{
            case "verb":
                typeSegmentControl.selectedSegmentIndex = 0
            case "noun":
                typeSegmentControl.selectedSegmentIndex = 1
            default:
                typeSegmentControl.selectedSegmentIndex = 2
            }
        }
        //Setting the Delegate for the TextField
        englishTextField.delegate = self
        welshTextField.delegate = self
        //Default checking and disabling of the Button
        if ((englishTextField.text!.isEmpty) || (welshTextField.text!.isEmpty)){
            saveButton.enabled = false // Disabling the button
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == englishTextField
        {
            let oldStr = englishTextField.text! as NSString
            let newStr = oldStr.stringByReplacingCharactersInRange(range, withString: string) as NSString
            if ((newStr.length == 0) || (welshTextField.text!.isEmpty))
            {
                saveButton.enabled = false
            }else
            {
                saveButton.enabled = true
            }
        }
        if textField == welshTextField
        {
            let oldStr = welshTextField.text! as NSString
            let newStr = oldStr.stringByReplacingCharactersInRange(range, withString: string) as NSString
            if ((newStr.length == 0) || (englishTextField.text!.isEmpty))
            {
                saveButton.enabled = false
            }else
            {
                saveButton.enabled = true
            }
        }
        return true
    }
}

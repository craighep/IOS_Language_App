//
//  MapsViewController.swift
//  TabBar-part1-Swift
//
//  Created by Neil Taylor on 10/03/2015.
//  Copyright (c) 2015 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData
import GameplayKit

class RevisionViewControler: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    var currentQuestion = 0
    var correctAnswers = 0
    var questions = [Question]()
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }()
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerPicker.dataSource = self;
        self.answerPicker.delegate = self;
        
        let fetchRequest = NSFetchRequest(entityName: "Phrase")
        do{
            let phrases = try managedContext.executeFetchRequest(fetchRequest) as! [Phrase]
            generateQuestions(phrases)
        }
        catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func generateQuestions(phrases:[Phrase]){
        if phrases.count > 10{
            let shuffledPhrases = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(phrases) as! [Phrase]
            for phrase in shuffledPhrases {
                if questions.count == 10{
                    break
                }
                let possibleAnswers = [String](arrayLiteral: "Yeah", "poo", phrase.welsh, "pee", "waaa")
                let question = Question(english: phrase.english, possible: possibleAnswers, answer: phrase.welsh, given: possibleAnswers[2])
                questions.append(question)
            }
            
            // start the quiz
            englishLabel.text = questions[0].english
            questionNumLabel.text =  "\(currentQuestion+1) of 10"
            answerPicker.selectRow(2, inComponent: 0, animated: true)
            setButtons()
        }
        else {
            print("not enough in db")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return questions[currentQuestion].possibleAnswers.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return questions[currentQuestion].possibleAnswers[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        questions[currentQuestion].givenAnswer = questions[currentQuestion].possibleAnswers[row]
        print(questions[currentQuestion].givenAnswer)
    }
    
    @IBAction func nextQuestion(sender: AnyObject) {
        if currentQuestion > 8{
            completeQuiz()
            return
        }
        currentQuestion++
        setButtons()
        setStatus()
        englishLabel.text = questions[currentQuestion].english
        let givenAnswer = questions[currentQuestion].givenAnswer
        if givenAnswer != ""{
            let defaultRowIndex = questions[currentQuestion].possibleAnswers.indexOf(givenAnswer)
            answerPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
        }
        else{
            answerPicker.selectRow(2, inComponent: 0, animated: true)
        }
        self.answerPicker.reloadAllComponents();
    }
    
    @IBAction func previousQuestion(sender: AnyObject) {
        if currentQuestion < 1{
            return
        }
        currentQuestion--
        setButtons()
        setStatus()
        englishLabel.text = questions[currentQuestion].english
        
        let givenAnswer = questions[currentQuestion].givenAnswer
        if givenAnswer != ""{
            let defaultRowIndex = questions[currentQuestion].possibleAnswers.indexOf(givenAnswer)
            answerPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
        }
        self.answerPicker.reloadAllComponents();
    }
    
    func setStatus(){
        questionNumLabel.text =  "\(currentQuestion+1) of 10"
        let progress = Float(currentQuestion)/10
        progressBar.setProgress(progress, animated: true)
    }
    
    func setButtons(){
        if !previousButton.enabled && currentQuestion > 0{
            previousButton.enabled = true
        }
        else if previousButton.enabled && currentQuestion == 0{
            previousButton.enabled = false
        }
        if nextButton.titleLabel != "Next" && currentQuestion < 9{
            nextButton.setTitle("Next", forState: UIControlState.Normal)
        }
        else if nextButton.enabled && currentQuestion == 9 {
            nextButton.setTitle("Complete", forState: UIControlState.Normal)
        }
    }
    
    func completeQuiz(){
        self.correctAnswers = 0
        for question in questions{
            if question.givenAnswer == question.answer{
                self.correctAnswers++
            }
        }
        print("Complete!")
        print("Number correct: \(correctAnswers)/10")
        performSegueWithIdentifier("CompleteQuiz", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CompleteQuiz" {
            let revisionCompleteViewController = segue.destinationViewController as! RevisionCompleteViewController
            revisionCompleteViewController.correctAnswers = self.correctAnswers
        }
    }
    
}

/**
 RevisionViewController.swift
 Language-Revisor
 
 Looks after the GUI for the revision quiz tab. Shows the user a set of randomly selected questions from
 the most recent phrases added by the user. Updates the status bar as the user navigates through
 questions, allows generation of new quizzes, and opens a segue to show final score.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

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
    var phrases = [Phrase]()
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    // Allows phrases to be pulled from CoreData
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerPicker.dataSource = self;
        self.answerPicker.delegate = self;
        
        startNewQuiz()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Refresh quiz incase and phrases have changed.
        startNewQuiz()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func newQuiz(sender: AnyObject) {
        // Called when user clicks the new quiz button.
        startNewQuiz()
    }
    
    /*
     Method gets the most recent 10 phrases added by the user, and then calls on the
     generate questions method to populate the GUI. Checks if there are actually 10
     available phrases before starting, otherwise shows a popup telling the user it cannot start
     until 10 are present.
     */
    func startNewQuiz(){
        let fetchRequest = NSFetchRequest(entityName: "Phrase")
        let fetchSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [fetchSort]
        do{
            phrases = try managedContext.executeFetchRequest(fetchRequest) as! [Phrase]
            if(phrases.count < 10){
                let alert = UIAlertController(title: "Error!", message: "Please have a minimum of 10 phrases before starting a quiz!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
            questions = [Question]()
            generateQuestions()
            }
        }
        catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    /*
     Method generates an array of questions based on the recent 10 phrases added. Uses
     the gamePlayKit shuffle to make sure it is different each time. With each phrase, a question
     object is created, taking in the question, answer, a set of possible answers, and the answer 
     to be default selected when viewing the question initially.
     */
    func generateQuestions(){
        if phrases.count > 9{
            // Get a subset of phrases, the first and most recent 10
            phrases = Array(phrases[0...9])
            // Shuffle the phrases uniquely
            let shuffledPhrases = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(phrases) as! [Phrase]
            for phrase in shuffledPhrases {
                // Create questions until there are 10
                if questions.count == 10{
                    break
                }
                // Get a list of random answers
                let possibleAnswers = getRandomAnswers(phrase.welsh)
                // Create question
                let question = Question(english: phrase.english, possible: possibleAnswers, answer: phrase.welsh, given: possibleAnswers[2])
                questions.append(question)
            }
            
            // start the quiz
            englishLabel.text = questions[0].english
            answerPicker.selectRow(2, inComponent: 0, animated: true)
            currentQuestion = 0
            correctAnswers = 0
            setButtons()
            setStatus()
            // Reload the picker to show first question
            answerPicker.reloadAllComponents()
        }
        else {
            print("not enough phrases in db")
        }
    }
    
    /*
     Method loops over all the phrases in CoreData and pulls 4 random welsh terms. These are appended
     to an array alongide the correct answer. Once shuffled, they are then returned to be shown
     on the answerPicker selector.
     - parameter answer: the correct answer for this question
     - returns: array of possible answers, containing the correct answer
     */
    func getRandomAnswers(answer: String) -> [String]{
        var answers = [String]()
        // Store initial correct answer, then add incorrect ones
        answers.append(answer)
        let shuffledPhrases = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(phrases) as! [Phrase]
        for phrase in shuffledPhrases{
            if answers.count == 5{
                break
            }
            // Do not add duplicates
            if(!answers.contains(phrase.welsh)){
                answers.append(phrase.welsh)
            }
        }
        // Shuffle the array and return it
        let shuffledAnswers = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(answers) as! [String]
        return shuffledAnswers
    }
    
    // PICKER VIEW METHODS ----
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if questions.count < 10{
            return 0
        }
        return questions[currentQuestion].possibleAnswers.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return questions[currentQuestion].possibleAnswers[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(questions.count > 9){
        questions[currentQuestion].givenAnswer = questions[currentQuestion].possibleAnswers[row]
        }
    }
    
    // END PICKER VIEW METHODS ----
    
    /*
     Method sets the GUI to show the next answer. Gets the current question number, and then
     replaces the question label, and the answerPicker. If the question has been completed
     already, show the selected answer. The status bar is also updated to the correct state.
     */
    @IBAction func nextQuestion(sender: AnyObject) {
        // Call completion of quiz if at final qustion
        if currentQuestion > 8{
            completeQuiz()
            return
        }
        // move question counter along
        currentQuestion += 1
        setButtons()
        setStatus()
        englishLabel.text = questions[currentQuestion].english
        let givenAnswer = questions[currentQuestion].givenAnswer
        if givenAnswer != ""{
            // set the answer picker to previously answered
            let defaultRowIndex = questions[currentQuestion].possibleAnswers.indexOf(givenAnswer)
            answerPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: true)
        }
        else{
            // by default, set picker to middle
            answerPicker.selectRow(2, inComponent: 0, animated: true)
        }
        self.answerPicker.reloadAllComponents();
    }
    
    /*
     Method sets the GUI to show the previous question in the quiz. Performs same actions as
     the method to get next qustion from quiz.
     */
    @IBAction func previousQuestion(sender: AnyObject) {
        // do not change anything if question is already first one
        if currentQuestion < 1{
            return
        }
        currentQuestion -= 1
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
    
    /*
     Method sets the status lables for the question number, and for the progress bar.
    */
    func setStatus(){
        questionNumLabel.text =  "\(currentQuestion+1) of 10"
        // get current decimal value based on question number 0-1
        let progress = Float(currentQuestion)/10
        progressBar.setProgress(progress, animated: true)
    }
    
    /*
     Method updates the buttons for moving forward or backward based on the current question number.
     Checks if the quiz is complete, then changes the button to move forward to a complete button.
     */
    func setButtons(){
        if !previousButton.enabled && currentQuestion > 0{
            previousButton.enabled = true
        }
        else if previousButton.enabled && currentQuestion == 0{
            previousButton.enabled = false
        }
        // Change back to 'next' when current question not the last
        if nextButton.titleLabel != "Next" && currentQuestion < 9{
            nextButton.setTitle("Next", forState: UIControlState.Normal)
        }
        // change to complete if the curent question is the last
        else if nextButton.enabled && currentQuestion == 9 {
            nextButton.setTitle("Complete", forState: UIControlState.Normal)
        }
    }
    
    /*
     When the quiz is comnpleted, work out the number of correct answers
     and then send the user to the RevisionCompleteViewController to show their results.
     */
    func completeQuiz(){
        self.correctAnswers = 0
        for question in questions{
            if question.givenAnswer == question.answer{
                self.correctAnswers += 1
            }
        }
        // Start a segue to the complete quiz view
        performSegueWithIdentifier("CompleteQuiz", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CompleteQuiz" {
            let revisionCompleteViewController = segue.destinationViewController as! RevisionCompleteViewController
            // Tell the view how many correct answers the user has
            revisionCompleteViewController.correctAnswers = self.correctAnswers
        }
    }
    
    @IBAction func unwindToRevisionController(sender: UIStoryboardSegue) {
        // upon unwind, start a new quiz
        startNewQuiz()
    }

    
}

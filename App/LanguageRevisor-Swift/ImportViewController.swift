/**
 ImportViewController.swift
 Language-Revisor
 
 Controls the GIU for the import tab, and pulls in JSON from external sources.
 The class then creates new Phrases based on information gathered. This is done on
 a seperate thread. A bubble notification informs the user of success or failure, and 
 a notification is sent to the phrases table to reload after import.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import UIKit
import CoreData

class ImportViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var inputURL: UITextField!
    
    /**
     Method reads the URL box from the GUI and then pulls the file from it.
     Onces json is gathered, the parseJson method is called. This function
     is called from clicking the import button. Alert is fired if an error occurs.
     */
    @IBAction func importFromURL(sender: AnyObject) {
        let requestURL: NSURL = NSURL(string: inputURL.text!)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        //Runs on another thread.
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            // If connection was made and data is returned
            if (statusCode == 200) {
                do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    // Send raw json to parse method
                self.parseJson(json)
                }catch {
                    let alert = UIAlertController(title: "Error!", message: "Phrases could not be imported.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    print("Error with Json: \(error)")
                }
            }
        }
    task.resume()
    }
    
    /**
     Method takes in raw json, reads in all data, and creates a new phrase word pair from it.
     This is done asyncronously, to allow this to be done in the background. Once a phrase has
     been added using the managed context object, an alert stating success is opened, and the 
     phraseViewController recieves a notification to reload the table of phrases.
     - parameter json: raw Json text
     */
    func parseJson(json: AnyObject){
        dispatch_async(dispatch_get_main_queue(), {
        var alert: UIAlertController
        let managedContext: NSManagedObjectContext = {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.managedObjectContext
        }()
        if let rawPhrases = json["wordpairs"] as? [[String: AnyObject]] {
            // Loop each phrase, and create a managed object representing it.
            for rawPhrase in rawPhrases {
                
                let english = rawPhrase["wordPhraseOne"] as? String
                let welsh = rawPhrase["wordPhraseTwo"] as? String
                let note = rawPhrase["note"] as? String
                let type = rawPhrase["type"] as? String
                let phraseEntity = NSEntityDescription.entityForName("Phrase", inManagedObjectContext:managedContext)
                let phrase = Phrase(entity: phraseEntity!, insertIntoManagedObjectContext: managedContext)
                
                phrase.english = english!
                phrase.welsh = welsh!
                phrase.note = note!
                phrase.type = type!
                phrase.timeStamp = NSDate()
                
                do {
                    try managedContext.save()
                    
                } catch let error as NSError {
                    alert = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                }

            }
        }
        // Tell the PhraseViewController class to reload the table of phrases
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
        //Create alert
        alert = UIAlertController(title: "Success!", message: "Phrases have been imported.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    

}

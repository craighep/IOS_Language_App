//
//  PhraseViewController
//  TabBar-part1-Swift
//
//  Created by Neil Taylor on 10/03/2015.
//  Copyright (c) 2015 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class PhraseViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    var managedContext: NSManagedObjectContext?

    var phrases: [Phrase] = PhrasesData().phrases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // DB THINGS -------
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Phrases")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "english", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext!, sectionNameKeyPath: "english", cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("There was an error trying to access Speakers: \(error)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phrases.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhraseTableViewCell", forIndexPath: indexPath) as! PhraseTableViewCell
        
        let phrase = phrases[indexPath.row]
        cell.englishLabel.text = phrase.english
        cell.welshLabel.text = phrase.welsh
        cell.typeLabel.text = phrase.type
        if phrase.tags.count == 1 {
            cell.tagsLabel.text = phrase.tags[0].name
        }
        else if phrase.tags.count > 1 {
            cell.tagsLabel.text = "\(phrase.tags[0].name), ..."
        }
        else{
            cell.tagsLabel.text = "-"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            phrases.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    @IBAction func cancelToPhraseViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func unwindToPhraseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PhraseDetailsViewController, phrase = sourceViewController.phrase {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing phrase.
                phrases[selectedIndexPath.row] = phrase
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new phrase.
                let newIndexPath = NSIndexPath(forRow: phrases.count, inSection: 0)
                phrases.append(phrase)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let phraseDetailsViewController = segue.destinationViewController as! PhraseDetailsViewController
            
            // Get the cell that generated this segue.
            if let selectedPhraseCell = sender as? PhraseTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPhraseCell)!
                let selectedPhrase = phrases[indexPath.row]
                phraseDetailsViewController.phrase = selectedPhrase
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new phrase")
        }
    }
    
}


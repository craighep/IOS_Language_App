//
//  PhraseViewController
//  TabBar-part1-Swift
//
//  Created by Neil Taylor on 10/03/2015.
//  Copyright (c) 2015 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class PhraseViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }()
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // DB THINGS -------
        
        let fetchRequest = NSFetchRequest(entityName: "Phrase")
        let fetchSort = NSSortDescriptor(key: "english", ascending: true)
        fetchRequest.sortDescriptors = [fetchSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhraseTableViewCell", forIndexPath: indexPath) as! PhraseTableViewCell
        
        let phrase = fetchedResultsController.objectAtIndexPath(indexPath) as! Phrase
        cell.englishLabel.text = phrase.english
        cell.welshLabel.text = phrase.welsh
        cell.typeLabel.text = phrase.type
        if phrase.tags.count == 1 {
            cell.tagsLabel.text = phrase.tags.anyObject()!.name
        }
        else if phrase.tags.count > 1 {
            cell.tagsLabel.text = "\(phrase.tags.anyObject()!.name), ..."
        }
        else{
            cell.tagsLabel.text = "-"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    @IBAction func cancelToPhraseViewController(segue:UIStoryboardSegue) {
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let phrase = fetchedResultsController.objectAtIndexPath(indexPath) as! Phrase
            managedContext.deleteObject(phrase)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error saving context after delete: \(error.localizedDescription)")
            }
        default:break
        }
    }
    
    @IBAction func unwindToPhraseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PhraseDetailsViewController {
            if sourceViewController.phrase != nil{
                print("edit")
                do {
                    try self.managedContext.save()
                    
                } catch let error as NSError {
                    NSLog("Could not save data \(error)")
                }
            }
            else {
                let phraseEntity = NSEntityDescription.entityForName("Phrase", inManagedObjectContext: self.managedContext)
                let phrase = Phrase(entity: phraseEntity!, insertIntoManagedObjectContext: self.managedContext)
                
                phrase.english = sourceViewController.englishTextField.text!
                phrase.welsh = sourceViewController.welshTextField.text!
                phrase.note = sourceViewController.noteTextField.text
                switch sourceViewController.typeSegmentControl.selectedSegmentIndex{
                case 0:
                    phrase.type = "Verb"
                case 1:
                    phrase.type = "Noun"
                default:
                    phrase.type = "Unkown"
                }
                let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedContext)
                let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: self.managedContext)
                tag.name = "Work"
                phrase.addTag(tag)
                
                do {
                    try self.managedContext.save()
                    
                } catch let error as NSError {
                    NSLog("Could not save data \(error)")
                }
                print("Added new phrase! count:")
                print(fetchedResultsController.sections!.count)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let phraseDetailsViewController = segue.destinationViewController as! PhraseDetailsViewController
            // Get the cell that generated this segue.
            if let selectedPhraseCell = sender as? PhraseTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPhraseCell)!
                let selectedPhrase = fetchedResultsController.objectAtIndexPath(indexPath) as! Phrase
                phraseDetailsViewController.phrase = selectedPhrase
            }
        }
    }
    
    
}


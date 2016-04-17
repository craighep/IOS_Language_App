/**
PhraseViewController.swift
 Language-Revisor
 
 Controls the table view for phrases. Allows the user to add, edit and delete phrases, 
 alongside the search bar functionality. Contains methods to filter phrases, fetch them, delete them, and
 edit them. Implements the FetechedResultsController, SearchResultsUpdating and SearchBarDelegate 
 to allow for all these operations.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import UIKit
import CoreData

class PhraseViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    // To keep track of a phrase being edited
    var selectedPhrase:Phrase?
    // Reads this to populate the table when being filtered
    var filteredPhrases = [Phrase]()
    // Allows the database to be read and the table to be populated
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        navigationItem.leftBarButtonItem = editButtonItem()
        fetchPhrases()
        
        // SEARCH CONTROLLER ------
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "English", "Welsh", "Phrase"]
        searchController.searchBar.delegate = self
        
        // LOAD NOTIFIER ------
        // set up a notification listener that runs a reload of the table if its called by an 
        // external controller.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhraseViewController.loadList(_:)),name:"load", object: nil)
    }
    
    /*
     Fetches all phrases and assigns them to the fetchedResultsController object. 
     Orders them alphabetically by English in ascending order.
     */
    func fetchPhrases(){
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
    
    /*
     Reloads the table with a new fetch of phrases when called via notification from another
     view for instance.
     - parameter notification: notifier calling this method
     */
    func loadList(notification: NSNotification){
        // Close search bar on reload
        searchController.active = false
        fetchPhrases()
        tableView.reloadData()
    }
    
    /*
     Upon typing in the search bar, this gets the scope of the search, and then
     filters the phrases accordingly.
     */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        // gets scope, e.g. searching english text only
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterPhrases(searchController.searchBar.text!, scope: scope)
    }
    
    /*
     Method populates the array of filtered phrases by calling format string methods on 
     CoreData. Searches based on the scope given, and uses text from the searchbar.
     Upon filter, the table reload method is called to show results.
     - parameter searchText: the text to search for in CoreData
     - parameter scope: the scope to search in. Defaults all
     */
    func filterPhrases(searchText: String, scope: String = "All"){
        // Create search predicate, based on the scope. Pass in the search string
        let searchPredicate: NSPredicate
        if(scope == "Welsh"){
            searchPredicate = NSPredicate(format: "SELF.welsh CONTAINS[c] %@", searchText)
        }
        else if(scope == "English"){
            searchPredicate = NSPredicate(format: "SELF.english CONTAINS[c] %@", searchText)
        }
        else if(scope == "Phrase"){
            searchPredicate = NSPredicate(format: "SELF.note CONTAINS[c] %@", searchText)
        }
        else{
            searchPredicate = NSPredicate(format: "SELF.english CONTAINS[c] %@ OR SELF.welsh CONTAINS[c] %@ OR SELF.welsh CONTAINS[c] %@", searchText, searchText, searchText)
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Phrase")
        let fetchSort = NSSortDescriptor(key: "english", ascending: true)
        fetchRequest.sortDescriptors = [fetchSort]
        // Assign the fetch request the search predicate
        fetchRequest.predicate = searchPredicate
        do{
            // get filtered phrases from managed context
            filteredPhrases = try managedContext.executeFetchRequest(fetchRequest) as! [Phrase]
        }
        catch let error as NSError{
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
        // Shows results
        tableView.reloadData()
    }
    
    // Upon change of the search bar, update filtered results
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
        filterPhrases(searchController.searchBar.text!, scope: scope)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TABLE VIEW METHODS ----
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        else{
            return self.fetchedResultsController.sections?.count ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // used filtered phrases if they are present
        if searchController.active && searchController.searchBar.text != "" {
            return filteredPhrases.count
        }
        else{
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get the cell based on the index of current row, use custom cell class
        let cell = tableView.dequeueReusableCellWithIdentifier("PhraseTableViewCell", forIndexPath: indexPath) as! PhraseTableViewCell
        let phrase:Phrase
        // if filtering is happening, then use these phrases, otherwise use directly from CoreData
        if searchController.active && searchController.searchBar.text != "" {
            phrase = filteredPhrases[indexPath.row]
        } else {
            phrase = fetchedResultsController.objectAtIndexPath(indexPath) as! Phrase
        }
        // Assign values of custom cell with phrase details
        cell.englishLabel.text = phrase.english
        cell.welshLabel.text = phrase.welsh
        cell.typeLabel.text = phrase.type
        if phrase.tags.count == 1 {
            cell.tagsLabel.text = phrase.tags.anyObject()!.name
        }
        else if phrase.tags.count > 1 {
            // Show ... to indicate there are more than one tag
            cell.tagsLabel.text = phrase.tags.anyObject()!.name
            cell.tagsLabel.text?.appendContentsOf("...")
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
        // based on action, perform an insert, reload or delete to cell
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
            // if deleting a cell, delete from managed context list, and then save.
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
    
    // END TABLE VIEW METHODS ----
    
    @IBAction func unwindToPhraseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PhraseDetailsViewController {
            if sourceViewController.phrase != nil{
                do {
                    // assign some values to selected phrase variable to hold to allow update to coreData
                    selectedPhrase!.welsh = sourceViewController.welshTextField.text!
                    selectedPhrase!.english = sourceViewController.englishTextField.text!
                    selectedPhrase!.note = sourceViewController.noteTextField.text
                    switch sourceViewController.typeSegmentControl.selectedSegmentIndex{
                    case 0:
                        selectedPhrase!.type = "verb"
                    case 1:
                        selectedPhrase!.type = "noun"
                    default:
                        selectedPhrase!.type = "unknown"
                    }
                    selectedPhrase!.switchTag("Work", enable: sourceViewController.workTagSwitch.on, managedContext: managedContext)
                    selectedPhrase!.switchTag("School", enable: sourceViewController.schoolTagSwitch.on, managedContext: managedContext)
                    selectedPhrase!.switchTag("Home", enable: sourceViewController.homeTagSwitch.on, managedContext: managedContext)
                    selectedPhrase!.switchTag("Other", enable: sourceViewController.otherTagSwitch.on, managedContext: managedContext)
                    // Save and reload table
                    try self.managedContext.save()
                    tableView.reloadData()
                    
                } catch let error as NSError {
                    NSLog("Could not save data \(error)")
                }
            }
            else {
                // Otherwise, a new phrase is being created.
                let phraseEntity = NSEntityDescription.entityForName("Phrase", inManagedObjectContext: self.managedContext)
                let phrase = Phrase(entity: phraseEntity!, insertIntoManagedObjectContext: self.managedContext)
                
                phrase.english = sourceViewController.englishTextField.text!
                phrase.welsh = sourceViewController.welshTextField.text!
                phrase.note = sourceViewController.noteTextField.text
                phrase.timeStamp = NSDate()
                switch sourceViewController.typeSegmentControl.selectedSegmentIndex{
                case 0:
                    phrase.type = "verb"
                case 1:
                    phrase.type = "noun"
                default:
                    phrase.type = "unknown"
                }
                // Check if any tags have been enabled, and if so, create a new tag object, assign it to
                // this phrase. 
                // Note: This could be made dynamic in the future.
                if(sourceViewController.workTagSwitch.on){
                    let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedContext)
                    let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: self.managedContext)
                    tag.name = "Work"
                    phrase.addTagObject(tag)
                }
                if(sourceViewController.homeTagSwitch.on){
                    let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedContext)
                    let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: self.managedContext)
                    tag.name = "Home"
                    phrase.addTagObject(tag)
                }
                if(sourceViewController.otherTagSwitch.on){
                    let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedContext)
                    let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: self.managedContext)
                    tag.name = "Other"
                    phrase.addTagObject(tag)
                }
                if(sourceViewController.schoolTagSwitch.on){
                    let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext: self.managedContext)
                    let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: self.managedContext)
                    tag.name = "School"
                    phrase.addTagObject(tag)
                }
                do {
                    try self.managedContext.save()
                    
                } catch let error as NSError {
                    NSLog("Could not save data \(error)")
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            // If user clicks on cell, the phrase in the PhraseDetailsViewController will be assigned
            // this phrase, and then it will be able to bring back any details already stored.
            let phraseDetailsViewController = segue.destinationViewController as! PhraseDetailsViewController
            if let selectedPhraseCell = sender as? PhraseTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPhraseCell)!
                // If currently fitering, pass a phrase from that list, otherwise get it from the 
                // entire list.
                if searchController.active && searchController.searchBar.text != "" {
                    selectedPhrase = filteredPhrases[indexPath.row]
                } else {
                    selectedPhrase = fetchedResultsController.objectAtIndexPath(indexPath) as? Phrase
                }
                phraseDetailsViewController.phrase = selectedPhrase
            }
        }
    }
    
}


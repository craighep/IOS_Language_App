/**
 Talk.swift
 Language-Revisor

 Class contains managed context object for word phrase pairs. Holds both welsh and english
 words, the note, type of word and holds a relationship to tags. Class contains methods to
 add or remove tags as nessecary.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import Foundation
import CoreData

class Phrase: NSManagedObject {
    
    @NSManaged var english: String
    @NSManaged var welsh: String
    @NSManaged var tags:NSSet
    @NSManaged var note: String
    @NSManaged var type: String
    @NSManaged var timeStamp: NSDate
    
    /*
     Method checks if a tag is related to this phrase.
     -parameter nameTag: name of the tag to search for.
     -returns: boolean of if tag is related.
     */
    func hasTag(nameTag: String) -> Bool{
        for tag in tags{
            if tag.name == nameTag{
                return true
            }
        }
        return false
    }
    
    /*
     Method enables or disables a relationship between tags and this phrase.
     Creates a new tag object if one is not already existing.
     -parameter nameTag: name of tag to search for.
     -parameter enable: whether to relate to a tag or not.
     -parameter managedContext: the context used to save a new tag.
     */
    func switchTag(nameTag: String, enable: Bool, managedContext: NSManagedObjectContext){
        if enable{
            if !hasTag(nameTag){
                let tagEntity = NSEntityDescription.entityForName("Tag", inManagedObjectContext:managedContext)
                let tag = Tag(entity: tagEntity!, insertIntoManagedObjectContext: managedContext)
                tag.name = nameTag
                self.addTagObject(tag)
            }
        }
        else {
            for tag in tags{
                if tag.name == nameTag{
                    self.removeTagObject(tag as! Tag)
                    break
                }
            }
        }
    }
}

extension Phrase {
    func addTagObject(value:Tag) {
        let items = self.mutableSetValueForKey("tags");
        items.addObject(value)
    }
    
    func removeTagObject(value:Tag) {
        let items = self.mutableSetValueForKey("tags");
        items.removeObject(value)
    }
}
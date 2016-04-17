/**
 Tag.swift
 Language-Revisor
 
 Class contains managed object for a tag. Holds the name and related phrase for the tag.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

import Foundation
import CoreData

class Tag: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var phrase: Phrase

}
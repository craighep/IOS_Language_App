//
//  Talk.swift
//  TabBar-part1-Swift
//
//  Created by Neil Taylor on 10/03/2015.
//  Copyright (c) 2015 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData

class Phrase: NSManagedObject {
    
    @NSManaged var english: String
    @NSManaged var welsh: String
    @NSManaged var tags:NSSet
    @NSManaged var note: String
    @NSManaged var type: String

//    init(english: String, welsh: String, note: String, type: String) {
//        self.english = english
//        self.welsh = welsh
//        self.note = note
//        self.type = type
//    }
    
    func addTag(tag: Tag) {
    //    tags.
    }
    
    func hasTag(nameTag: String) -> Bool{
        for var i = 0; i < tags.count ; ++i {
       //     if tags[i].name == nameTag{
     //           return true
      //      }
        }
        return false
    }
    
    func switchTag(nameTag: String, enable: Bool){
        if enable{
            if !hasTag(nameTag){
            //    addTag(Tag(name: nameTag))
            }
        }
        else {
            for var i = 0; i < tags.count ; ++i {
     //           if tags[i].name == nameTag{
       //             tags.removeAtIndex(i)
       //         }
            }
        }
    }
}
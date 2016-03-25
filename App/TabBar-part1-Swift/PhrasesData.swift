//
//  Talks.swift
//  TabBar-part1-Swift
//
//  Created by Neil Taylor on 10/03/2015.
//  Copyright (c) 2015 Aberystwyth University. All rights reserved.
//

import Foundation

class PhrasesData {
    
    var phrases: [Phrase] = []
    
    init() {
        
        let phrase = Phrase(english: "Slow", welsh: "Araf", note: "Road", type: "Unknown")
        phrase.addTag(Tag(name: "Other"))
        phrase.addTag(Tag(name: "School"))
        phrases.append(phrase)
    }
}
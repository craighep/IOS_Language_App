//
//  Question.swift
//  LanguageReviser
//
//  Created by administrator on 29/03/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import Foundation

class Question {
    
    var english: String
    var possibleAnswers = [String]()
    var answer: String
    var givenAnswer: String
    
    init(english: String, possible: [String], answer:String, given:String) {
        self.english = english
        self.possibleAnswers = possible
        self.answer = answer
        self.givenAnswer = given
    }
    
}
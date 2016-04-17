/**
 Question.swift
 Language-Revisor
 
 Class represents a single question in a revision quiz. Holds information such as:
 the english word to translate, a list of all possible answers, the correct answer, and the
 answer given from a user.
 
 Created by Craig Heptinstall on 10/03/2015.
 */

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
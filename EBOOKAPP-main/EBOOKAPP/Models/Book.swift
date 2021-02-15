//
//  Book.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 9.02.2021.
//

import Foundation
 class Book
 {
    private var id : String
    private var language : String
    private var title : String

    init(id:String, language:String, title:String)
    {
        self.id = id
        self.language = language
        self.title = title
    }
    
    func getId() -> String {self.id}
    func getLanguage() -> String {self.language}
    func getTitle() -> String {self.title}
    
    func toString() -> String
    {
        let toString = getId() + getLanguage() + getTitle()
        return toString
    }
 }


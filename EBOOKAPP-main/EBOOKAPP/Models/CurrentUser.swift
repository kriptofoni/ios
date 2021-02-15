//
//  CurrentUser.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 2.02.2021.
//

import Foundation

 class CurrentUser
{
    private var userId: String
    private var email: String
    private var age: String
    private var country: String
    private var gender: String
    private var isActive : Bool
    private var currentBookId : String
    
    
    init(userId:String, email:String, age:String, country:String, gender:String, isActive : Bool, currentBookId : String)
    {
        self.userId = userId
        self.email = email
        self.age = age
        self.country = country
        self.gender = gender
        self.isActive = isActive
        self.currentBookId = currentBookId
    }
    
    init()
    {
        userId = String()
        email = String()
        age = String()
        country = String()
        gender = String()
        isActive = Bool()
        currentBookId = String()
    }
    
    func setUserId(userId : String) {self.userId = userId}
    func setEmail(email : String) {self.email = email}
    func setAge(age: String) {self.age = age}
    func setCountry(country : String) {self.country = country}
    func setGender(gender : String) {self.gender = gender}
    func setIsActive(isActive: Bool) {self.isActive = isActive}
    func setCurrentBookId(currentBookId : String){self.currentBookId = currentBookId}
    
    func getUserId() -> String {return self.userId}
    func getEmail() -> String {return self.email}
    func getAge() -> String {return self.age}
    func getCountry() -> String {return self.country}
    func getGender() -> String {return self.gender}
    func getIsActive() -> Bool {return self.isActive}
    func getCurrentBookId() -> String {return self.currentBookId}
    
    func toString() -> String
    {
        let toString = getUserId() + getEmail() + getAge() + getCountry() + getGender() + String(getIsActive()) + " Current Book ID: " + getCurrentBookId()
        return toString
    }
}

//
//  FirebaseSingleton.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 2.02.2021.
//

import Foundation
import Firebase

class singleton
{
    
    private static var  uniqueInstance:singleton? = nil
    private var db = Firestore.firestore()
    private var usersDatabase:CollectionReference?
    private var booksDatabase:CollectionReference?
    
    private init()
    {
        self.db = Firestore.firestore()
        self.usersDatabase = self.db.collection("Users")
        self.booksDatabase = self.db.collection("Books")
    }
    
    public static func instance() -> singleton
    {
        if uniqueInstance == nil
        {
            uniqueInstance = singleton()
        }
        return uniqueInstance!
    }
    
    func getDb() -> Firestore {return singleton.uniqueInstance!.db}
    
    func getUsersDatabase() -> CollectionReference {return singleton.uniqueInstance!.usersDatabase!}
    
    func getBooksDatabase() -> CollectionReference {return singleton.uniqueInstance!.booksDatabase!}
    
    
}

class FirebaseUtil
{
    static func getUserDataAndCreateCore(userId : String, isActive : Bool)
    {
        var newUser = CurrentUser()
        let docRef = singleton.instance().getUsersDatabase().document(userId)
        docRef.getDocument
        {
           (document, error) in
           if let document = document, document.exists
           {
               let dataDescription = document.data()
               let age  = dataDescription?["age"] as! String
               let country  = dataDescription?["country"] as! String
               let email  = dataDescription?["email"] as! String
               let gender  = dataDescription?["gender"] as! String
               let userId  = dataDescription?["userId"] as! String
               newUser = CurrentUser(userId: userId, email: email, age: age, country: country, gender: gender, isActive: isActive, currentBookId: "")
               CoreDataUtil.createUserCoreData(user: newUser)
           }
        }
    }
    
    static func getEbooks(userId : String, completion: @escaping ([String:Int64]?, Error?) -> Void)
    {
        let user =  Auth.auth().currentUser
        let docRef = singleton.instance().getUsersDatabase().document(userId)
        
        docRef.getDocument
        {
           (document, error) in
           if let document = document, document.exists
           {
               let dataDescription = document.data()
               var thisMap = dataDescription?["ebooks"] as! [String:Int64]
               completion(thisMap,nil)
           }
           else if let error = error
           {
               completion(nil,error)
           }
           else
           {
              completion(nil,nil)
           }
        }
        
    }
 
    
    
    
    static func getPdfFromStorageAndSave(id : String)
    {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var islandRef = storageRef.child(id)
        //et localURL = URL(string: id)
        let tmporaryDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        let localURL = tmporaryDirectoryURL!.appendingPathComponent(id)
        islandRef.write(toFile: localURL) { url, error in
            if let error = error {
               print("\(error.localizedDescription)")
            } else
            {
               
                print(localURL)
            }
         }
    }
    
    
    static func getPdfFromLibrary(id : String) -> String
    {
        let fileManager = FileManager.default
        var newUrlString = ""
        let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for pdf in fileURLs
            {
                let pdfPathArray = pdf.absoluteString.split(separator: "/").map(String.init)
                if pdfPathArray.contains(id)
                {
                    newUrlString = pdf.absoluteString
                    print(newUrlString)
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return newUrlString
    }
}
    
 

//
//  LibraryController.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 7.02.2021.
//

import UIKit

class LibraryController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var homeButton: UIButton!
    var controllerType = Bool()
    @IBOutlet weak var tableView: UITableView!
    var booksForBuy = [Book]()
    var booksForLibrary = [Book]()
    @IBOutlet weak var libraryButton: UIButton!
    var libraryMap = [String:Int64]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self;
        makeWhiteBorder(button: homeButton)
        if !controllerType//This is library view controller
        {
            libraryButton.setTitle("LIBRARY", for: UIControl.State.normal)
            getAvailableBooksForLibrary()
        }
        else//This is buy view controller
        {
            libraryButton.setTitle("BUY", for: UIControl.State.normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !controllerType//This is library view controller
        {
            return booksForLibrary.count
        }
        else//This is buy view controller
        {
            return booksForBuy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryCell
        cell.buttonType = controllerType
        if !controllerType//This is library view controller
        {
            cell.bookId = self.booksForLibrary[indexPath.row].getId()
            cell.label.text = self.booksForLibrary[indexPath.row].getTitle().uppercased()
            libraryButton.setTitle("LIBRARY", for: UIControl.State.normal)
            cell.viewController = self
        }
        else//This is buy view controller
        {
            cell.bookId = self.booksForBuy[indexPath.row].getId()
            cell.label.text = self.booksForBuy[indexPath.row].getTitle().uppercased()
            libraryButton.setTitle("BUY", for: UIControl.State.normal)
        }
        return cell
    }
    
    func makeWhiteBorder(button: UIButton)
    {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func presentActivityViewController(withUrl url: URL) {
        DispatchQueue.main.async
        {
          let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
          activityViewController.popoverPresentationController?.sourceView = self.view
          self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func getAvailableBooksForLibrary()
    {
        let docRef = singleton.instance().getBooksDatabase().getDocuments { (querySnapshot, err) in
            if let err = err{print("Error getting documents: \(err)")}
            else
            {
                for document in querySnapshot!.documents
                {
                    if document.exists
                    {
                        if let val = self.libraryMap[document.documentID]
                        {
                            let dataDescription = document.data()
                            let language = dataDescription["language"] as! String
                            let title = dataDescription["title"] as! String
                            let id = dataDescription["id"] as! String
                            let book = Book(id: id, language: language, title: title)
                            self.booksForLibrary.append(book)
                            print("Count:" + String(self.booksForLibrary.count))
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

}

    



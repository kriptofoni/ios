//
//  CooperationAndHelp.swift
//  learning
//
//  Created by Deniz Eren Gençay on 17.04.2021.
//

import UIKit
import MessageUI

class CooperationAndHelp: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoopAndHelpTextFieldCell", for: indexPath) as! CoopAndHelpTextFieldCell
            cell.textField.placeholder = "Please enter Subject"
            return cell
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoopAndHelpTextViewCell", for: indexPath) as! CoopAndHelpTextViewCell
            cell.textView.text = "PlaceHolder"
            cell.textView.textColor =  UIColor.lightGray
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoopAndHelpButtonCell", for: indexPath) as! CoopAndHelpButtonCell
            cell.sentButton.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside);
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 1
        {
            height = 100
        }
        else if indexPath.row == 2
        {
            height = 233
        }
        else
        {
            height = 120
        }
        return CGFloat(height)
    }
    
    func getCell(index : Int) -> CoopAndHelpTextFieldCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let multiLineCell = tableView.cellForRow(at: indexPath as IndexPath) as? CoopAndHelpTextFieldCell
        return multiLineCell!
    }
    
    func getCellView(index : Int) -> CoopAndHelpTextViewCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let multiLineViewCell = tableView.cellForRow(at: indexPath as IndexPath) as? CoopAndHelpTextViewCell
        return multiLineViewCell!
    }
    
    @objc func tappedButton(sender : UIButton)
    {
        let subjectText = getCell(index: 1).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let mainText = getCellView(index: 2).textView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard MFMailComposeViewController.canSendMail() else {return}
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["denizgencay35@gmail.com"])
        composer.setSubject(subjectText)
        composer.setMessageBody(mainText, isHTML: false)
        present(composer, animated: true)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}

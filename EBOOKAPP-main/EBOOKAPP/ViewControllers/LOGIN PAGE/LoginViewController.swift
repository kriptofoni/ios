//
//  LoginViewController.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 29.01.2021.
//

import UIKit
import Firebase
import CoreData

class LoginViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var stayActiveMarkButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var stayActiveMarked = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        tableView.register(UINib(nibName: "LoginCell",bundle: nil), forCellReuseIdentifier: "loginCell")
        makeWhiteBorder(button: loginButton)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell", for: indexPath) as! RegisterCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        switch indexPath.row
        {
            case 0:
                cell.label.text = "E-Mail;"
                cell.view = view
                //cell.createBottomLine()
                
            case 1:
                cell.label.text = "Password;"
                cell.view = view
                cell.textField.isSecureTextEntry = true
                //cell.createBottomLine()
            default:
                cell.label.text = "NULL"
                cell.view = view
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 100}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 2}
    func makeWhiteBorder(button: UIButton){button.layer.borderWidth = 2;button.layer.borderColor = UIColor.white.cgColor}
    
    func isStayActiveButtonControl()
    {
        if !stayActiveMarked
        {
            stayActiveMarkButton.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            stayActiveMarked = true
        }
        else
        {
            stayActiveMarkButton.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
            stayActiveMarked = false
        }
    }
    
    
    
    @IBAction func stayActiveButtonAction(_ sender: Any){isStayActiveButtonControl()}
    
    @IBAction func stayActiveImageButtonAction(_ sender: Any){isStayActiveButtonControl()}
    
    func getCell(index : Int) -> RegisterCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let multilineCell = tableView.cellForRow(at: indexPath as IndexPath) as? RegisterCell
        return multilineCell!
    }
    
    @IBAction func passwordRecoveryAction(_ sender: Any)
    {
        alertForResetPassword()
    }
    
    
    @IBAction func loginButtonAction(_ sender: Any)
    {
        loginButton.isEnabled = false
        let email = getCell(index: 0).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = getCell(index: 1).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if email != "" && password != "" //if email and password is not empty
        {
            Auth.auth().signIn(withEmail: email, password: password)//Firebase signIn methods
            { (authData, error) in
                if error != nil
                {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                    self.loginButton.isEnabled = true
                }
                else//if coredata not exist create and set it.
                {
                    let user = Auth.auth().currentUser
                    self.performSegue(withIdentifier: "toFirstController1", sender: self)
                }
            }
        }
    }
    
    
    
    
    /// It selects the cell button type
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
     {
            if segue.identifier == "toFirstController1"
            {
                let destinationVC = segue.destination as! FirstController
                if stayActiveMarked
                {
                    destinationVC.isActive = true
                }
                else
                {
                    destinationVC.isActive = false
                }
            }
     }
    
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    
    ///Creates customized pop-up alert for reseting password
    func alertForResetPassword()
        {
            let alert = UIAlertController(title: "Reset your password", message: "Please write your e-mail...", preferredStyle: UIAlertController.Style.alert )
            let attributedStringTitle = NSAttributedString(string: "Reset your password", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.white])
            let attributedStringMessage = NSAttributedString(string: "Please write your e-mail...", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor : UIColor.white])
            alert.setValue(attributedStringTitle, forKey: "attributedTitle")
            alert.setValue(attributedStringMessage, forKey: "attributedMessage")
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor  =  UIColor.black//Customization of this pop up alert
            alert.view.tintColor = UIColor.white
            let save = UIAlertAction(title: "Reset", style: .default) { (alertAction) in//Reset action
                let textField = alert.textFields![0] as UITextField
                if textField.text != ""
                {
                    Auth.auth().sendPasswordReset(withEmail: textField.text!) { error in//Sends email pasword reset from firebase
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                    }
                }
                else
                {
                    self.makeAlert(titleInput: "Error", messageInput: "E-mail blank is empty.")
                }
            }
            alert.addTextField { (textField) in
                textField.placeholder = "Please write your e-mail"
                textField.textColor = .black
            }
            alert.addAction(save)
            let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }//Cancel action
            alert.addAction(cancel)
            self.present(alert, animated:true, completion: nil)
        }
    
    
}

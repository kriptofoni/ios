//
//  RegisterViewController2.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 29.01.2021.
//

import UIKit
import Firebase
import CoreData


class RegisterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var acceptTermsImageButton: UIButton!
    var isTermsAccepted = false
    let genders = ["Female","Male","Others"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        makeWhiteBorder(button: doneButton)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 5}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell", for: indexPath) as! RegisterCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        switch indexPath.row {
        case 0:
            cell.label.text = "E-mail"
            cell.view = view
        case 1:
            cell.label.text = "Password"
            cell.view = view
            cell.textField.isSecureTextEntry = true
        case 2:
            cell.label.text = "Age"
            cell.view = view
            cell.textField.keyboardType = UIKeyboardType.numberPad
        case 3:
            cell.label.text = "Country"
            let placeholderColor = UIColor.black
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Please select your country.", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor])
            cell.isTextFieldPicker = true
            cell.array = Countries.getCountries()
            cell.textField.inputView = cell.picker
            createToolbar(textField: cell.textField)
        case 4:
            cell.label.text = "Gender"
            let placeholderColor = UIColor.black
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Please select your gender.", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor])
            cell.isTextFieldPicker = true
            cell.array = genders
            cell.textField.inputView = cell.picker
            createToolbar(textField: cell.textField)
        default:
            cell.label.text = "NUll"
        }
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 79}
    
    func createToolbar(textField : UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(RegisterViewController.dismissPicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    @objc func dismissPicker() {view.endEditing(true)}
    func makeWhiteBorder(button: UIButton)
    {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func isTermsAcceptedControl()
    {
        if !isTermsAccepted
        {
            acceptTermsImageButton.setBackgroundImage(UIImage(named: "checked"), for: .normal)
            isTermsAccepted = true
        }
        else
        {
            acceptTermsImageButton.setBackgroundImage(UIImage(named: "unchecked"), for: .normal)
            isTermsAccepted = false
        }
    }
    
    @IBAction func acceptTermsImageButtonAction(_ sender: Any){isTermsAcceptedControl()}
    @IBAction func acceptTermsButtonAction(_ sender: Any){isTermsAcceptedControl()}
    @IBAction func doneButtonAction(_ sender: Any)
    {
        let email = getCell(index: 0).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = getCell(index: 1).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age = getCell(index: 2).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let country = getCell(index: 3).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender =  getCell(index: 4).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if email != "" && password != "" && age != "" && country != "" && gender != ""
        {
            if isTermsAccepted
            {
                doneButton.isEnabled = false
                Auth.auth().createUser(withEmail: email, password: password)//Authantication
                               { (authData, error) in
                                 if error != nil
                                 {
                                     self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")//for alertMessages of Firebase
                                     self.doneButton.isEnabled = true
                                 }
                                 else
                                 {
                                    let user = Auth.auth().currentUser
                                    let registerDict =  ["userId":user!.uid,"email":email,"age":age,"country":country,"gender":gender,"ebooks":[String:Int64]()] as [String : Any]
                                    let currentUser = CurrentUser(userId: user!.uid, email: email, age: age, country: country, gender: gender, isActive: true, currentBookId: "")
                                    CoreDataUtil.createUserCoreData(user: currentUser)
                                    singleton.instance().getUsersDatabase().document(user!.uid).setData(registerDict)
                                    self.performSegue(withIdentifier: "toFirstController2", sender: self)
                                }
                }
            }
            else
            {
                makeAlert(titleInput: "Aooo!!", messageInput: "Please accept terms and conditions.")
                doneButton.isEnabled = true
            }
        }
        else
        {
            makeAlert(titleInput: "Aooo!!", messageInput: "Please fill all the blanks.")
            doneButton.isEnabled = true
        }

    }
    
    func getCell(index : Int) -> RegisterCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let multilineCell = tableView.cellForRow(at: indexPath as IndexPath) as? RegisterCell
        return multilineCell!
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
            let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated:true, completion: nil)
    }
    
    
    
}

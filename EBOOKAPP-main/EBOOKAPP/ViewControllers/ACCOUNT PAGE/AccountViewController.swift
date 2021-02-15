//
//  AccountViewController.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 30.01.2021.
//

import UIKit
import Firebase

class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let eBookLanguages = ["Bengali","Hindi","Russian","Italian","Japanese","Chinese tangerine","Arab","Spanish","English","French","Portuguese","German","Turkish"]
    let genders = ["Female","Male","Others"]
    var currentUser = CurrentUser()
    @IBOutlet weak var homeButton: UIButton!
    var isActive = Bool()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        tableView.backgroundView = nil
        currentUser = CoreDataUtil.getCurrentUser()
        makeWhiteBorder(button: saveButton)
        makeWhiteBorder(button: homeButton)
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 3}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell", for: indexPath) as! RegisterCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        switch indexPath.row {
        case 0:
            cell.label.text = "Country;"
            //let placeholderColor = UIColor.black
            //cell.textField.attributedPlaceholder = NSAttributedString(string: "Please select your country.", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor])
            cell.textField.text = currentUser.getCountry()
            cell.isTextFieldPicker = true
            cell.array = Countries.getCountries()
            cell.textField.inputView = cell.picker
            createToolbar(textField: cell.textField)
        case 1:
            cell.label.text = "Age;"
            cell.textField.text = currentUser.getAge()
            cell.view = view
            cell.textField.keyboardType = UIKeyboardType.numberPad
        case 2:
            cell.label.text = "Gender;"
            //let placeholderColor = UIColor.black
            //cell.textField.attributedPlaceholder = NSAttributedString(string: "Please select your gender.", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor])
            cell.textField.text = currentUser.getGender()
            cell.isTextFieldPicker = true
            cell.array = genders
            cell.textField.inputView = cell.picker
            createToolbar(textField: cell.textField)
        default:
            cell.label.text = "Null"
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
    
    @IBAction func saveButtonAction(_ sender: Any)
    {
        let age = getCell(index: 1).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let country = getCell(index: 0).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender =  getCell(index: 2).textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if age != "" && country != ""  && gender != ""
        {
                saveButton.isEnabled = false
                let user = Auth.auth().currentUser
                CoreDataUtil.updateCurrentUserOnAccount(age: age, country: country, gender: gender)
                let changeDict =  ["age":age,"country":country,"gender":gender] as [String : Any]
                singleton.instance().getUsersDatabase().document(user!.uid).updateData(changeDict)
                saveButton.isEnabled = true
        }
        else
        {
            makeAlert(titleInput: "Aooo!!", messageInput: "Please fill all the blanks.")
            saveButton.isEnabled = true
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

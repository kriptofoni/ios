//
//  RegisterCell.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 29.01.2021.
//

import UIKit

class RegisterCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var array = [String]()
    let picker = UIPickerView()
    var isTextFieldPicker = false
    var view = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.dataSource = self; picker.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        createBottomLine(textField: textField)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        textField.delegate = self
        // Configure the view for the selected state
    }
    
    func createBottomLine(textField : UITextField)
    {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height+0.01, width: 320, height: 1.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{return 1}
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{return array.count}
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{return array[row]}
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        textField.text = array[row]
        print(textField.text!)
        print("Sonra")
        print(array[row])
    }

    
    ///Starts Editing The Text Field
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
    
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -80, up: true)}
    /// Finishes Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {moveTextField(textField, moveDistance: -80, up: false)}
    /// Moves the text field in a pretty animation
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool)
    {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    */
    
    /// Hides the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return true}

}

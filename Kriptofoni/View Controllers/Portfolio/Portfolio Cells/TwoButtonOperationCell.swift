//
//  TwoButtonOperationCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit

class TwoButtonOperationCell: UITableViewCell {

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
        buyButton.borderColor = Util.newGreen
        buyButton.setTitleColor(Util.newGreen, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func buyButtonAction(_ sender: Any)
    {
        buyButton.borderColor = Util.newGreen
        buyButton.setTitleColor(Util.newGreen, for: .normal)
        sellButton.borderColor = UIColor.gray
        sellButton.setTitleColor(UIColor.gray, for: .normal)
    }
    
    @IBAction func sellButtonAction(_ sender: Any)
    {
        buyButton.borderColor = UIColor.gray
        buyButton.setTitleColor(UIColor.gray, for: .normal)
        sellButton.borderColor = Util.newRed
        sellButton.setTitleColor(Util.newRed, for: .normal)
    }
    
}


class OperationInputCell: UITableViewCell, UITextFieldDelegate
{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var view = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        Util.createBottomLine(textField : textField)
        textField.keyboardType = UIKeyboardType.decimalPad
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        textField.delegate = self
        // Configure the view for the selected state
    }
    
    ///Starts Editing The Text Field
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
        
    /// Hides the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return true}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           if string == "," {
               textField.text = textField.text! + "."
               return false
           }
           return true     // Could also filter on numbers only
   }


}

class OperationDateCell: UITableViewCell, UITextFieldDelegate
{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var view = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        Util.createBottomLine(textField : textField)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        textField.delegate = self
        // Configure the view for the selected state
    }
    
    ///Starts Editing The Text Field
    @objc func didTapView(gesture: UITapGestureRecognizer){view.endEditing(true)}
        
    /// Hides the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return true}
}

class AddOperationButtonCell: UITableViewCell
{
    @IBOutlet weak var addOperationButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addOperationButtonClicked(_ sender: Any) {
        print("cem")
    }
}



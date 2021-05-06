//
//  FiatConverter.swift
//  learning
//
//  Created by Deniz Eren Gençay on 19.04.2021.
//

import UIKit

class FiatConverter: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var cryptoTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var cryptoAmountTextField: UITextField!
    @IBOutlet weak var currencyAmountTextField: UITextField!
    
    private var cryptos = ["usd","try","cad"]
    private let currencies = ["usd","try","cad"]
    
    private var cryptoPickerView = UIPickerView()
    private var currencyPickerView = UIPickerView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cryptoTextField.inputView = cryptoPickerView
        currencyTextField.inputView = currencyPickerView
        
        cryptoTextField.placeholder = "Crypto"
        currencyTextField.placeholder = "Currency"
        
        cryptoTextField.textAlignment = .center
        currencyTextField.textAlignment = .center
        
        cryptoPickerView.delegate = self
        cryptoPickerView.dataSource = self
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        
        cryptoPickerView.tag = 1
        currencyPickerView.tag = 2
    }
    
    
    @IBAction func cryptoEdit(_ sender: Any)
    {
        
        
        if let cryptoAmountControlText = cryptoAmountTextField.text, cryptoAmountControlText.isEmpty{
            
            currencyAmountTextField.isUserInteractionEnabled = true
            
            
        }else{
            
            currencyAmountTextField.isUserInteractionEnabled = false
            
        }
        
    }
    
    @IBAction func currencyEdit(_ sender: Any) {
        
        if let currencyAmountControlText = currencyAmountTextField.text, currencyAmountControlText.isEmpty{
            
            cryptoAmountTextField.isUserInteractionEnabled = true
            
        }else{
            
            cryptoAmountTextField.isUserInteractionEnabled = false
            
        }
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return cryptos.count
        case 2:
            return currencies.count
        default:
            
            return 1
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        
        switch pickerView.tag {
        case 1:
            return cryptos[row]
        case 2:
            return currencies[row]
        default:
            
            return "Nothing Found"
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        switch pickerView.tag {
        case 1:
            
            cryptoTextField.text = cryptos[row]
            cryptoTextField.resignFirstResponder()
            
        case 2:
            
            currencyTextField.text = currencies[row]
            currencyTextField.resignFirstResponder()
            
        default:
            
            return
            
        }
    }
  
    @IBAction func convertButton(_ sender: Any) {
        
        
        
    }
    
}

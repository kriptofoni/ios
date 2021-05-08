//
//  FiatConverter.swift
//  learning
//
//  Created by Deniz Eren Gençay on 19.04.2021.
//

import UIKit


import UIKit

class FiatConverter: UIViewController
{

    @IBOutlet weak var cryptoTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var cryptoAmountTextField: UITextField!
    @IBOutlet weak var currencyAmountTextField: UITextField!
    static var selectedCoinId = "bitcoin"
    static var selectedCoinName = "Bitcoin"
    static var selectedCurrency = "usd"
    var activityView: UIActivityIndicatorView?
    var pageType = ""
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cryptoAmountTextField.keyboardType = UIKeyboardType.decimalPad
        currencyAmountTextField.keyboardType = UIKeyboardType.decimalPad
        cryptoTextField.addTarget(self, action: #selector(coinSelectorFunc), for: .touchDown)
        currencyTextField.addTarget(self, action: #selector(currencySelectorFunc), for: .touchDown)
        
        cryptoTextField.placeholder = "Crypto"
        currencyTextField.placeholder = "Currency"
        
        cryptoTextField.textAlignment = .center
        currencyTextField.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        cryptoTextField.text = FiatConverter.selectedCoinName
        currencyTextField.text = FiatConverter.selectedCurrency
        
    }
    
    @objc func coinSelectorFunc(textField: UITextField)
    {
        pageType = "coin"
        self.performSegue(withIdentifier: "toSelector", sender: self)
    }
    
    
    @IBAction func currencyAmountEditEnd(_ sender: Any) {
        
        let currencyAmountTextEndControl = currencyAmountTextField.text
        
        if currencyAmountTextEndControl!.isEmpty{
            
            cryptoAmountTextField.text = ""
            
        }
        
    }
    
    @IBAction func cryptoAmountEditEnd(_ sender: Any) {
        
        let cryptoAmountTextEndControl = cryptoAmountTextField.text
        
        if cryptoAmountTextEndControl!.isEmpty{
            
            currencyAmountTextField.text = ""
            
        }
        
    }
    
    @objc func currencySelectorFunc(textField: UITextField)
    {
        pageType = "currency"
        self.performSegue(withIdentifier: "toSelector", sender: self)
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
    
  
    @IBAction func convertButton(_ sender: Any) {
        
        let currencyControlText = currencyAmountTextField.text
        let cryptoControlText = cryptoAmountTextField.text
        let currency = FiatConverter.selectedCoinId
        var newDictionary = [String : Any]()
        if !currencyControlText!.isEmpty
        {
            DispatchQueue.main.async{self.showActivityIndicator(scroll: false)}
            CoinGecko.getCoinDetails(id: currency, currencyType: FiatConverter.selectedCurrency) { result in
                newDictionary = result
                let price = newDictionary["current_price_for_currency"] as! NSNumber
                DispatchQueue.main.async{
                    self.hideActivityIndicator()
                    let currencyAmount = Double(self.currencyAmountTextField.text!)
                    let calculatedPriceCurrency = currencyAmount! / price.doubleValue
                    let cryptoDecimalValue = NSDecimalNumber(string: String(calculatedPriceCurrency))
                    self.cryptoAmountTextField.text = String(cryptoDecimalValue.stringValue)
                    print(cryptoDecimalValue)
                }

            }
            
        }
        else if !cryptoControlText!.isEmpty
        {
            DispatchQueue.main.async{self.showActivityIndicator(scroll: false)}
            CoinGecko.getCoinDetails(id: currency, currencyType: FiatConverter.selectedCurrency) { result in
                newDictionary = result
                let price = newDictionary["current_price_for_currency"] as! NSNumber
                DispatchQueue.main.async{
                    self.hideActivityIndicator()
                    let cryptoAmount = Double(self.cryptoAmountTextField.text!)
                    let calculatedPrice = price.doubleValue * cryptoAmount!
                    let currencyDecimalValue = NSDecimalNumber(string: String(calculatedPrice))
                    self.currencyAmountTextField.text = String(currencyDecimalValue.stringValue)
                    print(currencyDecimalValue)
                }
            }
        }
        else if !currencyControlText!.isEmpty && !cryptoControlText!.isEmpty {
            self.makeAlert(messageInput:  "Lütfen yeni bir değer giriniz.")
        }
        else{
            self.makeAlert(messageInput:  "Lütfen bir değer giriniz.")
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toSelector"
        {
            let destinationVC = segue.destination as! FiatSelectorController
            destinationVC.pageType = pageType
            
        }
    }
    
    
    //shows spinner
    func showActivityIndicator(scroll : Bool)
    {
        if #available(iOS 13.0, *) {activityView = UIActivityIndicatorView(style: .medium)}
        else {activityView = UIActivityIndicatorView(style: .gray)}
        if scroll {activityView?.center = CGPoint(x: self.view.center.x, y: UIScreen.main.bounds.size.height * 3/4)}
        else{activityView?.center = self.view.center}
        
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    //hides spinner
    func hideActivityIndicator() {if (activityView != nil){activityView?.stopAnimating()}}
    
    func makeAlert(messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: "Oops!", message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
}

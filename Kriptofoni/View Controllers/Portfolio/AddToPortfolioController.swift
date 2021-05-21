//
//  OperationViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit
import Toast_Swift
import ScrollableSegmentedControl
//operation portfolio
class AddToPortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
   
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var currencyTypes = [String]()
    var selectedCoinShorthening = ""
    var searchCoinArray = [SearchCoin]()
    var pickerDate = UIDatePicker()
    var dateTimestamp : Double = 0 //holds the timestamp of date picker result
    var portfolioTotalDict  = [String:Double]()
    var operationType = true // true -> buy , false -> sell
    let numberFormatter = NumberFormatter()
    var sSize: CGRect = UIScreen.main.bounds
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        CoreDataPortfolio.calculateTotalCoin { (result) in self.portfolioTotalDict = result}
        self.tableView.reloadData()
    }
    
    
    func setSegmentedView()
    {
        self.segmentedView.backgroundColor = UIColor(named: "Header Color")
        self.segmentedView.selectedSegmentContentColor = Util.defaultFont
        let sWidth = sSize.width
        segmentedView.frame.size.width = sWidth
        segmentedView.segmentStyle = .textOnly
        segmentedView.insertSegment(withTitle: "ALARMLAR",  at: 0)
        segmentedView.insertSegment(withTitle: "İzleme Listesi", at: 1);
        segmentedView.underlineSelected = true
        segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(self.segmentSelected(sender:)), for: .valueChanged)
    }
    
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        if segmentedView.selectedSegmentIndex == 1
        {
            
            self.navigationItem.title = "Watching List"
        }
        else
        {
            self.tableView.reloadData()
            self.navigationItem.title = "Alarms "
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setSegmentedView()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.decimalSeparator = "."
        self.tableView.delegate = self;self.tableView.dataSource = self;
        CoreData.getCoins { [self] (result) in
            searchCoinArray = result
            print("Count" + String(searchCoinArray.count))
        }
    }
    
    
    
    // MARK: - Table View Funcs
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 7}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 0 {height =  71}
        else if indexPath.row == 1 {height =  78}
        else if indexPath.row == 2 {height = 109}
        else if indexPath.row == 3 {height = 78}
        else if indexPath.row == 4 {height = 78}
        else if indexPath.row == 5{height = 112}
        else if indexPath.row == 6 {height = 50}
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonOperationCell", for: indexPath) as! TwoButtonOperationCell
            cell.buyButton.setTitle("AL", for: .normal)
            cell.sellButton.setTitle("SAT", for: .normal)
            cell.buyButton.addTarget(self, action: #selector(self.buyButtonClicked(sender:)), for: .touchUpInside)
            cell.sellButton.addTarget(self, action: #selector(self.sellButtonClicked(sender:)), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Toplam " + Currency.coinShortening.uppercased()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeCoin))
            cell.label.isUserInteractionEnabled = true
            cell.label.addGestureRecognizer(tap)
            cell.textField.placeholder = "Kripto Para Miktarı"
            cell.view = view
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            cell.view = view
            cell.label.text = "Tarih"
            cell.textField.placeholder = "Lütfen bir tarih seçiniz."
            createDatePicker(textField: cell.textField)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Ücret    " + Currency.currencySymbol
            cell.textField.placeholder = "Ücret"
            cell.view = view
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Kesinti      " +  Currency.currencySymbol
            cell.textField.placeholder = "Kesinti"
            cell.view = view
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            cell.label.text = "Notlar"
            cell.textField.placeholder = "Editlemek için dokunun."
            cell.view = view
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addOperationButtonCell", for: indexPath) as! AddOperationButtonCell
            cell.addOperationButton.setTitle("Portföyüme Ekle", for: .normal)
            cell.addOperationButton.addTarget(self, action: #selector(self.addButtonClicked (sender:)), for: .touchUpInside)
            return cell
        default:
            print("Hata")
        }
        return cell
    }
    
   
    // MARK: - Button Clicked Funcs
    
    @objc func buyButtonClicked(sender: UIButton!) {operationType = true}
    @objc func sellButtonClicked(sender: UIButton!) {operationType = false}

    @objc func addButtonClicked(sender: UIButton!)
    {
        let quantity = getCell2(index: 1).textField.text!
        let price = getCell2(index: 3).textField.text!
        let fee = getCell2(index: 4).textField.text!
        let note = getCell1(index: 5).textField.text!
        
        if !quantity.isEmpty && (Double(quantity) != nil) //mandatory variable
        {
            if !(getCell1(index: 2).textField.text!.isEmpty) // datec controll
            {
                if !price.isEmpty && (Double(price) != nil) //mandatory variable
                {
                    if fee.isEmpty
                    {
                        if !operationType // if this is a selling operation, we should check dict as an example if you have 3 bitcoin, you cannot sell 4 bitcoin
                        {
                            if portfolioTotalDict[Currency.coinKey] != nil // means we already have this coin look at the dict
                            {
                                let portfolioQuantity = portfolioTotalDict[Currency.coinKey]
                                if portfolioQuantity! > Double(quantity)!
                                {
                                    saveToPortfolio(coinId: Currency.coinKey, quantity: Double(quantity)!, date:  dateTimestamp, price: Double(price)!, fee: Double(fee) ?? 0, note: note, type: operationType)
                                }
                                else
                                {
                                    self.makeAlert(titleInput: "Oops!", messageInput: "You have only \(portfolioQuantity!)) \(Currency.coinKey). You can sell less than this quantity.")
                                }
                            }
                            else
                            {
                                self.makeAlert(titleInput: "Oops!", messageInput: "You have only 0 \(Currency.coinKey).")
                            }
                        }
                        else
                        {
                            saveToPortfolio(coinId: Currency.coinKey, quantity: Double(quantity)!, date:  dateTimestamp, price: Double(price)!, fee: Double(fee) ?? 0, note: note, type: operationType)
                        }
                    }
                    else
                    {
                        if Double(fee) != nil
                        {
                            if !operationType // if this is a selling operation, we should check dict as an example if you have 3 bitcoin, you cannot sell 4 bitcoin
                            {
                                if portfolioTotalDict[Currency.coinKey] != nil // means we already have this coin look at the dict
                                {
                                    let portfolioQuantity = portfolioTotalDict[Currency.coinKey]
                                    if portfolioQuantity! > Double(quantity)!
                                    {
                                        saveToPortfolio(coinId: Currency.coinKey, quantity: Double(quantity)!, date:  dateTimestamp, price: Double(price)!, fee: Double(fee) ?? 0, note: note, type: operationType)
                                    }
                                    else
                                    {
                                        self.makeAlert(titleInput: "Oops!", messageInput: "You have only \(portfolioQuantity!)) \(Currency.coinKey). You can sell less than this quantity.")
                                    }
                                }
                                else
                                {
                                    self.makeAlert(titleInput: "Oops!", messageInput: "You have only 0 \(Currency.coinKey).")
                                }
                            }
                            else
                            {
                                saveToPortfolio(coinId: Currency.coinKey, quantity: Double(quantity)!, date:  dateTimestamp, price: Double(price)!, fee: Double(fee) ?? 0, note: note, type: operationType)
                            }
                        }
                        else
                        {
                            self.makeAlert(titleInput: "Oops!", messageInput: "Please enter a valid fee.")
                        }
                    }
                }
                else {self.makeAlert(titleInput: "Oops!", messageInput: "Please enter a valid price.")}
            }
            else {self.makeAlert(titleInput: "Oops!", messageInput: "Please enter a date.")}
            
        }
        else {self.makeAlert(titleInput: "Oops!", messageInput: "Please enter a valid quantity.")}
    }
    
    @objc func donePressed()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)
        let now = Date().localDate()
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: pickerDate.date)
        dateComponents.month = calendar.component(.month, from: pickerDate.date)
        dateComponents.day = calendar.component(.day, from: pickerDate.date)
        dateComponents.hour = calendar.component(.hour, from: now)
        dateComponents.minute = calendar.component(.minute, from: now)
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let newDateTime = userCalendar.date(from: dateComponents)
        pickerDate.date = newDateTime!
        print(newDateTime!)
        getCell1(index: 2).textField.text = dateFormatter.string(from: pickerDate.date)
        dateTimestamp = Double(pickerDate.date.timeIntervalSince1970)
        self.view.endEditing(true)
    }
    
    @objc func changeCoin(sender: UITapGestureRecognizer) {self.performSegue(withIdentifier: "toCoinSelector", sender: self)}
    
    
    // MARK: - Helper Funcs
    func saveToPortfolio(coinId: String,quantity: Double, date: Double, price: Double, fee: Double, note: String, type: Bool)
    {
        CoreDataPortfolio.saveToPortfolio(coinId: coinId, quantity: quantity, date: date, price:  price, fee: fee, note: note, type: type) { (result) in
            if result
            {
                self.navigationController?.popViewController(animated: true)
                self.view.makeToast("\(Currency.coinShortening) has been added to your portfolio.", duration: 2.0, position: .center)
            }
        }
    }
    
    func getCell1(index : Int) -> OperationDateCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let operationDateCell = tableView.cellForRow(at: indexPath as IndexPath) as? OperationDateCell
        return operationDateCell!
    }
    
    func getCell2(index: Int) -> OperationInputCell
    {
        let indexPath = NSIndexPath(row: index, section: 0)
        let operationInputCell = tableView.cellForRow(at: indexPath as IndexPath) as? OperationInputCell
        return operationInputCell!
    }
    
    //creates date picker and sets its settings
    func createDatePicker(textField : UITextField)
    {
        //Date Picker
        pickerDate.maximumDate = Date()
        pickerDate.datePickerMode = .date
        pickerDate.setDate(Date(), animated: false)
        if #available(iOS 13.4, *)
        {
            pickerDate.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250.0)
            pickerDate.preferredDatePickerStyle = .wheels
        }
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneBtn], animated: true)
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerDate
    }
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
         if segue.identifier == "toCoinSelector"
         {
             let destinationVC = segue.destination as! CoinSelector
             destinationVC.searchCoinArray = self.searchCoinArray.sorted(by: {
                 $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
             })
             destinationVC.parentController = "portfolio"
         }
    }
    
    

}

extension Date
{
    func localDate() -> Date
    {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        return localDate
    }
}



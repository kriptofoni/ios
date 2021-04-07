//
//  SelectedCoinViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit
import SDWebImage
class SelectedCoinViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let coingecko = CoinGecko.init()
    
    var activityView: UIActivityIndicatorView?
    var dict : [String:NSNumber] = [:]
    @IBOutlet weak var tableView: UITableView!
    var stringArray = ["Price","Price For Btc","Change For 1 Hour","Change For 24 Hours","Change For 7 Days","Market Value","24 Hours Vol", "Circulating Supply", "Total Supply"]
    var iconNames = ["globe","reddit","twitter"]
    var socialMediaTexture = ["Website","Reddit","Twitter"]
    var currentCurrencySymbol = "$"; var currentCurrencyKey = "usd"
    var selectedSearchCoin = SearchCoin();var selectedCoin = Coin() // if the type variable is 0, we will use selectedSearchCoin instance and if the type type variable is 1, we will use selectedCoin variable
    var type = 0 // 0 means that we are coming this page from a search operation, 1 means that we are coming this page from normal currency selecting. I check that becuase we have two models as Coin and Search Coin and we need to know which one is usable or not to escape bugs.
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        showActivityIndicator()
        self.tableView.delegate = self; self.tableView.dataSource = self;
        if type == 0
        {
            
            coingecko.getCoinDetails(id: selectedSearchCoin.getId(),currencyType: currentCurrencyKey) { (result) in
                self.dict = result
                DispatchQueue.main.async{
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                }
            } onFailure: {
                print("Error: When getting coin detais.")
            }
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedSearchCoin.getName() + " " + selectedSearchCoin.getSymbol().uppercased(), imageUrl: selectedSearchCoin.getImageUrl())
            
        }
        else
        {
            coingecko.getCoinDetails(id: selectedCoin.getId(), currencyType: currentCurrencyKey) { (result) in
                self.dict = result
                DispatchQueue.main.async{
                    self.hideActivityIndicator()
                    self.tableView.reloadData()
                }
            } onFailure: {
                print("Error: When getting coin detais.")
            }
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedCoin.getName() + " " + selectedCoin.getShortening().uppercased(), imageUrl: selectedCoin.getIconViewUrl())
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if dict.count > 0
        {
            return stringArray.count + 8
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0
        if indexPath.row == 0 {height =  59}
        else if indexPath.row == 1 {height =  218}
        else if indexPath.row == 2 {height = 42}
        else if indexPath.row == 3 || indexPath.row == 4 {height = 85}
        else if indexPath.row > 4 && indexPath.row < 13 {height = 43}
        else if indexPath.row == stringArray.count + 3 {height = 50}
        else if indexPath.row == stringArray.count + 4 {height = 50}
        else if indexPath.row > stringArray.count + 4 {height = 45}
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath) as! FirstCell
            cell.leftLabel.text = currentCurrencySymbol + self.dict["current_price_for_currency"]!.stringValue
            if self.dict["price_change_percentage_24h"]!.intValue > 0{cell.rigthLabel.textColor = UIColor.green}
            else{cell.rigthLabel.textColor = UIColor.red}
            cell.rigthLabel.text = "%" + String(format: "%.3f", self.dict["price_change_percentage_24h"]!.doubleValue)
            return cell
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "secondCell", for: indexPath) as! SecondCell
            return cell
        }
        else if indexPath.row == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "thirdCell", for: indexPath) as! ThirdCell
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToTwoCell", for: indexPath) as! OneToTwoCell
            cell.leftLabel.text = stringArray[indexPath.row-3]
            if self.dict["price_change_percentage_24h"]!.intValue > 0{cell.rightLabelUp.textColor = UIColor.green}
            else{cell.rightLabelUp.textColor = UIColor.red}
            cell.rightLabelUp.text = "%" + String(format: "%.3f", self.dict["price_change_percentage_24h"]!.doubleValue)
            cell.rightLabelDown.text = currentCurrencySymbol + " " + self.dict["current_price_for_currency"]!.stringValue
            return cell
        }
        else if indexPath.row == 4
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToTwoCell", for: indexPath) as! OneToTwoCell
            cell.leftLabel.text = stringArray[indexPath.row-3]
            if self.dict["price_change_percentage_24h_bitcoin"]!.intValue > 0{cell.rightLabelUp.textColor = UIColor.green}
            else{cell.rightLabelUp.textColor = UIColor.red}
            cell.rightLabelUp.text = "%" + String(format: "%.5f", self.dict["price_change_percentage_24h_bitcoin"]!.doubleValue)
            cell.rightLabelDown.text = "BTC " + String(format: "%.3f", self.dict["current_price_for_bitcoin"]!.doubleValue)
        }
        else if indexPath.row > 4 && indexPath.row < 12
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToOneCell", for: indexPath) as! OneToOneCell
            cell.leftLabel.text = stringArray[indexPath.row-3]
            switch indexPath.row {
            case 5:
                let element = self.dict["price_change_percentage_1h_in_currency"];
                if element!.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                else {cell.rightLabel.textColor = UIColor.red}
                cell.rightLabel.text = "%" +  String(format: "%.3f", self.dict["price_change_percentage_1h_in_currency"]!.doubleValue)
                
            case 6:
                let element = self.dict["price_change_percentage_24h"];
                if element!.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                else {cell.rightLabel.textColor = UIColor.red}
                cell.rightLabel.text =  "%" +  String(format: "%.3f", self.dict["price_change_percentage_24h"]!.doubleValue)
                
            case 7:
                let element = self.dict["price_change_percentage_7d_in_currency"];
                if element!.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                else {cell.rightLabel.textColor = UIColor.red}
                cell.rightLabel.text = "%" + String(format: "%.3f", self.dict[ "price_change_percentage_7d_in_currency"]!.doubleValue)
                
            case 8:  cell.rightLabel.text = self.currentCurrencySymbol + " "  +  String(format: "%.1f", self.dict["market_cap"]!.doubleValue)
            case 9:  cell.rightLabel.text = self.currentCurrencySymbol + " "  + String(format: "%.1f", self.dict["volumeFor24H"]!.doubleValue)
            case 10: cell.rightLabel.text = self.currentCurrencySymbol + " "  + String(format: "%.1f", self.dict["circulating_supply"]!.doubleValue)
            case 11: cell.rightLabel.text = self.currentCurrencySymbol + " " + String(format: "%.1f", self.dict["total_supply"]!.doubleValue)
            default:
                print("Error: table view error. ")
                    
            }
            return cell
        }
        else if indexPath.row >= 12 && indexPath.row < 15
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCell", for: indexPath) as! SocialMediaCell
            cell.label.text = socialMediaTexture[indexPath.row - (stringArray.count + 3)]
            cell.socialMediaIcon.image = UIImage(named: iconNames[indexPath.row - stringArray.count - 3])
            return cell
        }
        else if indexPath.row == 15
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonCell", for: indexPath) as! TwoButtonCell
            return cell
        }
        else if indexPath.row ==  16
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneButtonCell", for: indexPath) as! OneButtonCell
            return cell
        }
        return cell
    }
    
    func navTitleWithImageAndText(titleText: String, imageUrl: String) -> UIView {

        // Creates a new UIView
        let titleView = UIView()

        // Creates a new text label
        let label = UILabel()
        label.text = " " + titleText
        label.sizeToFit()
        label.center = titleView.center
        label.textAlignment = NSTextAlignment.center
        // Creates the image view
        let image = UIImageView()
        let url = URL(string: imageUrl)
        image.sd_setImage(with: url) { (_, _, _, _) in}
        // Maintains the image's aspect ratio:
        let imageAspect = image.image!.size.width / image.image!.size.height

        // Sets the image frame so that it's immediately before the text:
        let imageX = label.frame.origin.x - label.frame.size.height * imageAspect
        let imageY = label.frame.origin.y

        let imageWidth = label.frame.size.height * imageAspect
        let imageHeight = label.frame.size.height

        image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)

        image.contentMode = UIView.ContentMode.scaleAspectFit

        // Adds both the label and image view to the titleView
        titleView.addSubview(label)
        titleView.addSubview(image)

        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit()

        return titleView

    }
    
    func showActivityIndicator()
    {
        activityView = UIActivityIndicatorView(style: .gray)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        if (activityView != nil)
        {
            activityView?.stopAnimating()
        }
    }
}

extension UIView {
    // MARK: - Properties
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

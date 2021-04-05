//
//  CurrencySelectorViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit
import SDWebImage

class CurrencySelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var selectedCurrency = String()
    var selectedCurrencySymbol = String()
    var currencyArray =  [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        currencyArray.remove(at: 0)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{return currencyArray.count}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        let arrayIndex = currencyArray[indexPath.row]
        
        if getCountryCode(currencyCode: arrayIndex)[0] != ""
        {
            let urlLink =  "https://www.countryflags.io/" +  getCountryCode(currencyCode: arrayIndex)[0] + "/flat/64.png"
            let url = URL(string: urlLink)
            cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            cell.label.text = arrayIndex.uppercased() + " (" + getCountryCode(currencyCode: arrayIndex)[1] + ")"
        }
        else
        {
            let urlLink =  "https://cryptoicons.org/api/icon/" +  arrayIndex + "/32"
            let url = URL(string: urlLink)
            cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            cell.label.text = arrayIndex.uppercased()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.selectedCurrency = currencyArray[indexPath.row]
        if getCountryCode(currencyCode: self.selectedCurrency)[0] != ""{self.selectedCurrencySymbol = getCountryCode(currencyCode: self.selectedCurrency)[1]}
        else{self.selectedCurrencySymbol = self.selectedCurrency.uppercased()}
        performSegue(withIdentifier: "toBackFromSelector", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let barControllers = segue.destination as! UITabBarController
        let nav = barControllers.viewControllers![0] as! UINavigationController
        let destinationViewController = nav.topViewController as? MainViewController
        destinationViewController?.currentCurrencyKey = self.selectedCurrency
        destinationViewController?.currentCurrencySymbol = self.selectedCurrencySymbol
        destinationViewController?.isAfterCurrencyChanging = true
    }
    
    func getCountryCode(currencyCode : String) -> [String]
    {
            var resultArr = ["",""]
            var countryCode = ""
            var currencySymbol = ""
            switch (currencyCode) {
                case "usd":
                    countryCode = "us";
                    currencySymbol = "$";
                    break;
                case "aed":
                    countryCode = "ae";
                    currencySymbol = "د.إ";
                    break;
                case "ars":
                    countryCode = "ar";
                    currencySymbol = "$";
                    break;
                case "aud":
                    countryCode = "au";
                    currencySymbol = "$";
                    break;
                case "bdt":
                    countryCode = "bd";
                    currencySymbol = "$";
                    break;
                case "bhd":
                    countryCode = "bh";
                    currencySymbol = "ó";
                    break;
                case "bmd":
                    countryCode = "bm";
                    currencySymbol = "$";
                    break;
                case "brl":
                    countryCode = "br";
                    currencySymbol = "R";
                    break;
                case "cad":
                    countryCode = "ca";
                    currencySymbol = "$";
                    break;
                case "chf":
                    countryCode = "li";
                    currencySymbol = "Fr";
                    break;
                case "clp":
                    countryCode = "cl";
                    currencySymbol = "$";
                    break;
                case "cny":
                    countryCode = "cn";
                    currencySymbol = "¥";
                    break;
                case "czk":
                    countryCode = "cz";
                    currencySymbol = "Kč";
                    break;
                case "dkk":
                    countryCode = "dk";
                    currencySymbol = "kr";
                    break;
                case "eur":
                    countryCode = "eu";
                    currencySymbol = "€";
                    break;
                case "gbp":
                    countryCode = "gb";
                    currencySymbol = "£";
                    break;
                case "hkd":
                    countryCode = "hk";
                    currencySymbol = "$";
                    break;
                case "huf":
                    countryCode = "hu";
                    currencySymbol = "Ft";
                    break;
                case "idr":
                    countryCode = "id";
                    currencySymbol = "Rp";
                    break;
                case "ils":
                    countryCode = "il";
                    currencySymbol = "₪";
                    break;
                case "inr":
                    countryCode = "in";
                    currencySymbol = "₹";
                    break;
                case "jpy":
                    countryCode = "jp";
                    currencySymbol = "¥";
                    break;
                case "krw":
                    countryCode = "kr";
                    currencySymbol = "₩";
                    break;
                case "kwd":
                    countryCode = "kw";
                    currencySymbol = "د";
                    break;
                case "lkr":
                    countryCode = "lk";
                    currencySymbol = "Rs";
                    break;
                case "mmk":
                    countryCode = "mm";
                    currencySymbol = "K";
                    break;
                case "mxn":
                    countryCode = "mx";
                    currencySymbol = "$";
                    break;
                case "myr":
                    countryCode = "my";
                    currencySymbol = "RM";
                    break;
                case "ngn":
                    countryCode = "ng";
                    currencySymbol = "₦";
                    break;
                case "nok":
                    countryCode = "no";
                    currencySymbol = "kr";
                    break;
                case "nzd":
                    countryCode = "nz";
                    currencySymbol = "$";
                    break;
                case "php":
                    countryCode = "ph";
                    currencySymbol = "₱";
                    break;
                case "pkr":
                    countryCode = "pk";
                    currencySymbol = "₨";
                    break;
                case "pln":
                    countryCode = "pl";
                    currencySymbol = "zł";
                    break;
                case "rub":
                    countryCode = "ru";
                    currencySymbol = "₽";
                    break;
                case "sar":
                    countryCode = "sa";
                    currencySymbol = "﷼";
                    break;
                case "sek":
                    countryCode = "se";
                    currencySymbol = "kr";
                    break;
                case "sgd":
                    countryCode = "sg";
                    currencySymbol = "$";
                    break;
                case "thb":
                    countryCode = "th";
                    currencySymbol = "฿";
                    break;
                case "try":
                    countryCode = "tr";
                    currencySymbol = "₺";
                    break;
                case "twd":
                    countryCode = "tw";
                    currencySymbol = "$";
                    break;
                case "uah":
                    countryCode = "ua";
                    currencySymbol = "₴";
                    break;
                case "vef":
                    countryCode = "ve";
                    currencySymbol = "Bs";
                    break;
                case "vnd":
                    countryCode = "vn";
                    currencySymbol = "₫";
                    break;
                case "zar":
                    countryCode = "za";
                    currencySymbol = "R";
                    break;
                default:
                    countryCode = "";
                    currencySymbol = "";
                    break;
            }
            resultArr[0] = countryCode;
            resultArr[1] = currencySymbol;
            return resultArr;
        }
    
}

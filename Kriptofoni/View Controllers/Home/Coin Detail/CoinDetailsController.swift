//
//  SelectedCoinViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit;import SDWebImage;import TinyConstraints; import Charts
class CoinDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyTypeButton: UIBarButtonItem!
    var stringArray = ["Price","Price For Btc","Change For 1 Hour","Change For 24 Hours","Change For 7 Days","Market Value","24 Hours Vol", "Circulating Supply", "Total Supply"]
    var iconNames = ["globe","reddit","twitter"]
    var socialMediaTexture = ["Website","Reddit","Twitter"]
    var currentCurrencySymbol = "$"; var currentCurrencyKey = "usd"; var currentCoinId = ""
    var values = [ChartDataEntry]();var isLineCharts = true; // if user press change the graph to candle, this bool is going to be false
    let coingecko = CoinGecko.init()
    var activityView: UIActivityIndicatorView?
    var dict : [String:Any] = [:]; var linkArray = [String](); var webSiteLink = String(); var twitterLink = String(); var redditLink = String()
    var currencyTypes = [String]()
    var selectedSearchCoin = SearchCoin();var selectedCoin = Coin() // if the type variable is 0, we will use selectedSearchCoin instance and if the type type variable is 1, we will use selectedCoin variable
    var type = 0 // 0 means that we are coming this page from a search operation, 1 means that we are coming this page from normal currency selecting. I check that becuase we have two models as Coin and Search Coin and we need to know which one is usable or not to escape bugs.
    var sSize: CGRect = UIScreen.main.bounds

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("cemcemcem")
        self.currencyTypeButton.title = currentCurrencyKey.uppercased()
        showActivityIndicator()
        self.tableView.delegate = self; self.tableView.dataSource = self;
        if type == 0
        {
            self.currentCoinId = self.selectedSearchCoin.getId()
            coingecko.getCoinDetails(id: selectedSearchCoin.getId(),currencyType: currentCurrencyKey) { (result) in
                self.dict = result
                self.coingecko.getDataForCharts(id: self.selectedSearchCoin.getId(), currency: self.currentCurrencyKey, type: "twentyFour_hours") { (chartdata) in
                    self.values = chartdata
                    DispatchQueue.main.async{
                        self.hideActivityIndicator()
                        self.tableView.reloadData()
                    }
                } onFailure: {print("Error")}
            } onFailure: {print("Error: When getting coin detais.")}
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedSearchCoin.getName() + " " + selectedSearchCoin.getSymbol().uppercased(), imageUrl: selectedSearchCoin.getImageUrl())
        }
        else
        {
            self.currentCoinId = self.selectedCoin.getId()
            coingecko.getCoinDetails(id: selectedCoin.getId(), currencyType: currentCurrencyKey) { (result) in
                self.dict = result
                self.coingecko.getDataForCharts(id: self.selectedCoin.getId(), currency: self.currentCurrencyKey, type: "twentyFour_hours") { (chartdata) in
                    self.values = chartdata
                    DispatchQueue.main.async{
                        self.hideActivityIndicator()
                        self.tableView.reloadData()
                    }
                } onFailure: {print("Error")}
            } onFailure: {print("Error: When getting coin detais.")}
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedCoin.getName() + " " + selectedCoin.getShortening().uppercased(), imageUrl: selectedCoin.getIconViewUrl())
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if dict.count > 0{return stringArray.count + 7}
        else{return 0}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 0 {height =  59}
        else if indexPath.row == 1 {height =  235}
        else if indexPath.row == 2 || indexPath.row == 3 {height = 85}
        else if indexPath.row > 3 && indexPath.row < 11 {height = 43}
        else if indexPath.row == 11 || indexPath.row == 12 || indexPath.row == 13 {height = 50}
        else if indexPath.row > 13  {height = 45}
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath) as! FirstCell
            cell.leftLabel.text = currentCurrencySymbol + Util.toPrice((self.dict["current_price_for_currency"]! as! NSNumber).doubleValue, isCoinDetailPrice: true)
            if (self.dict["price_change_percentage_24h"]! as! NSNumber).intValue > 0{cell.rigthLabel.textColor = UIColor.green}
            else{cell.rigthLabel.textColor = UIColor.red}
            cell.rigthLabel.text = "%" + String(format: "%.3f", (self.dict["price_change_percentage_24h"]! as! NSNumber).doubleValue)
            return cell
        }
        else if indexPath.row == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "secondCell", for: indexPath) as! SecondCell
            cell.chartView.delegate = self;cell.candleStickChartView.delegate = self
            switch traitCollection.userInterfaceStyle
            {
                case .light, .unspecified: cell.chartView.backgroundColor = .white; cell.candleStickChartView.backgroundColor = .white
                case .dark: cell.chartView.backgroundColor = .black; cell.candleStickChartView.backgroundColor = .white
                @unknown default: cell.chartView.backgroundColor = .white; cell.candleStickChartView.backgroundColor = .white
            }
            cell.chartView.chartDescription!.enabled = false;
            cell.chartView.dragEnabled = true;
            cell.chartView.setScaleEnabled(true)
            cell.chartView.pinchZoomEnabled = true
            cell.chartView.rightAxis.enabled = false
            cell.chartView.xAxis.labelPosition = .bottom
            cell.firstButton.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.firstButton.tag = 0
            cell.secondButton.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.secondButton.tag = 1
            cell.button24H.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.button24H.tag = 2
            cell.button1W.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside);  cell.button1W.tag = 3
            cell.button1M.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.button1M.tag = 4
            cell.button3M.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.button3M.tag = 5
            cell.button6M.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.button6M.tag = 6
            cell.button1Y.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.button1Y.tag = 7
            cell.buttonAll.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); cell.buttonAll.tag = 8
            if isLineCharts
            {
                cell.candleStickChartView.isHidden = true
                cell.chartView.isHidden = false
                let set1 = LineChartDataSet(entries: values ,label: "Prices")
                set1.drawCirclesEnabled = false
                set1.lineWidth = 1.5
                let data = LineChartData(dataSet: set1)
                data.setDrawValues(false)
                cell.chartView.data = data
            }
            else
            {
                cell.candleStickChartView.isHidden = false
                cell.chartView.isHidden = true
                let set1Candle = CandleChartDataSet(entries: values, label: "Prices")
                let dataCandle = CandleChartData(dataSet: set1Candle)
                dataCandle.setDrawValues(false)
                //cell.candleStickChartView.data = dataCandle
            }
            return cell
        }
       
        else if indexPath.row == 2
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToTwoCell", for: indexPath) as! OneToTwoCell
            cell.leftLabel.text = stringArray[indexPath.row-2]
            if (self.dict["price_change_percentage_24h"]! as! NSNumber).intValue > 0{cell.rightLabelUp.textColor = UIColor.green}
            else{cell.rightLabelUp.textColor = UIColor.red}
            cell.rightLabelUp.text = "%" + String(format: "%.3f", (self.dict["price_change_percentage_24h"]! as! NSNumber).doubleValue)
            cell.rightLabelDown.text = currentCurrencySymbol + " " + Util.toPrice((self.dict["current_price_for_currency"]! as! NSNumber).doubleValue, isCoinDetailPrice: true)
            return cell
        }
        else if indexPath.row == 3
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToTwoCell", for: indexPath) as! OneToTwoCell
            cell.leftLabel.text = stringArray[indexPath.row-2]
            if (self.dict["price_change_percentage_24h_bitcoin"]! as! NSNumber).intValue > 0{cell.rightLabelUp.textColor = UIColor.green}
            else{cell.rightLabelUp.textColor = UIColor.red}
            cell.rightLabelUp.text = "%" + String(format: "%.5f", (self.dict["price_change_percentage_24h_bitcoin"]! as! NSNumber).doubleValue)
            cell.rightLabelDown.text = "BTC " + String(format: "%.3f", (self.dict["current_price_for_bitcoin"]! as! NSNumber).doubleValue)
        }
        else if indexPath.row > 3 && indexPath.row < 11
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToOneCell", for: indexPath) as! OneToOneCell
            cell.leftLabel.text = stringArray[indexPath.row-2]
            switch indexPath.row
            {
                case 4:
                    let element = (self.dict["price_change_percentage_1h_in_currency"]! as! NSNumber);
                    if element.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                    else {cell.rightLabel.textColor = UIColor.red}
                    cell.rightLabel.text = "%" +  String(format: "%.3f", (self.dict["price_change_percentage_1h_in_currency"]! as! NSNumber).doubleValue)
                case 5:
                    let element = (self.dict["price_change_percentage_24h"]! as! NSNumber);
                    if element.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                    else {cell.rightLabel.textColor = UIColor.red}
                    cell.rightLabel.text =  "%" +  String(format: "%.3f", (self.dict["price_change_percentage_24h"]! as! NSNumber).doubleValue)
                case 6:
                    let element = (self.dict["price_change_percentage_7d_in_currency"]! as! NSNumber);
                    if element.doubleValue > 0 {cell.rightLabel.textColor = UIColor.green}
                    else {cell.rightLabel.textColor = UIColor.red}
                    cell.rightLabel.text = "%" + String(format: "%.3f", (self.dict[ "price_change_percentage_7d_in_currency"]! as! NSNumber).doubleValue)
                case 7:  cell.rightLabel.text = self.currentCurrencySymbol + " "  +  Util.toPrice((self.dict["market_cap"]! as! NSNumber).doubleValue, isCoinDetailPrice: false)
                case 8:  cell.rightLabel.text = self.currentCurrencySymbol + " "  +  Util.toPrice((self.dict["volumeFor24H"]! as! NSNumber).doubleValue, isCoinDetailPrice: false)
                case 9: cell.rightLabel.text = Util.toPrice((self.dict["circulating_supply"]! as! NSNumber).doubleValue, isCoinDetailPrice: false)
                case 10:
                    if (self.dict["total_supply"]! as! NSNumber).doubleValue == 0 { cell.rightLabel.text = "-"}
                    else {cell.rightLabel.text = Util.toPrice((self.dict["total_supply"]! as! NSNumber).doubleValue, isCoinDetailPrice: false)}
                    
               default: print("Error: table view error. ")
                        
            }
            return cell
        }
        else if indexPath.row >= 11 && indexPath.row < 14
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCell", for: indexPath) as! SocialMediaCell
            cell.label.text = socialMediaTexture[indexPath.row - 11]
            cell.socialMediaIcon.image = UIImage(named: iconNames[indexPath.row - 11])
            if indexPath.row == 12 {webSiteLink = self.dict["website"] as! String}
            else if indexPath.row == 13 {twitterLink = self.dict["twitter"] as! String}
            else if indexPath.row == 14 {redditLink = self.dict["reddit"] as! String}
            return cell
        }
        else if indexPath.row == 14
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonCell", for: indexPath) as! TwoButtonCell
            cell.addOperation.addTarget(self, action: #selector(self.operationButtonClicked(sender:)), for: .touchUpInside)
            return cell
        }
        else if indexPath.row ==  15
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneButtonCell", for: indexPath) as! OneButtonCell
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 11 && indexPath.row < 14
        {
            if indexPath.row == 11
            {
                guard let url = URL(string: webSiteLink) else { return }
                UIApplication.shared.open(url)
            }
            else if indexPath.row == 12
            {
                guard let url = URL(string: redditLink) else  { return }
                UIApplication.shared.open(url)
            }
            else if indexPath.row == 13
            {
                let newLink = "https://twitter.com/\(twitterLink)"
                guard let url = URL(string: newLink) else  { return }
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc func operationButtonClicked(sender: UIButton){self.performSegue(withIdentifier: "toOperationCoinDetails", sender: self)}
    
    @objc func tappedButton(sender : UIButton)
    {
        if sender.tag != 0 && sender.tag != 1
        {
            DispatchQueue.main.async{self.showActivityIndicator()}
            var type = ""
            switch sender.tag
            {
                case 2:type = "twentyFour_hours"
                case 3:type = "one_week_before"
                case 4:type = "one_month_before"
                case 5:type = "three_months_before"
                case 6:type = "six_months_before"
                case 7:type = "one_year_before"
                case 8:type = "all"
                default:
                    print("cem")
            }
            self.coingecko.getDataForCharts(id: self.currentCoinId, currency: self.currentCurrencyKey, type: type) { (chartdata) in
                    self.values = chartdata
                    DispatchQueue.main.async{
                        self.hideActivityIndicator()
                        self.tableView.reloadData()
                    }
                } onFailure: {print("Error")}
        }
        else
        {
            if sender.tag == 0 {self.performSegue(withIdentifier: "toFullScreen", sender: self)}
            else if sender.tag == 1
            {
                if !isLineCharts {isLineCharts = true; sender.setBackgroundImage(UIImage(named: "candlestick"), for: .normal)}
                else {isLineCharts = false; sender.setBackgroundImage(UIImage(named: "linechart"), for: .normal)}
                DispatchQueue.main.async{self.tableView.reloadData()}
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toFullScreen"
        {
            let destinationVC = segue.destination as! FullScreenChartController
            destinationVC.values = values
            destinationVC.charType = isLineCharts
            destinationVC.coinId = currentCoinId
            destinationVC.currencyKey = currentCurrencyKey
        }
        else if segue.identifier == "toCurrencySelectorFromDetails"
        {
            let destinationVC = segue.destination as! CurrencySelectorController
            destinationVC.currencyArray = currencyTypes
        }
        else if segue.identifier == "toOperationCoinDetails"
        {
            let destinationVC = segue.destination as! OperationController
            destinationVC.currencyType = self.currentCurrencyKey
            destinationVC.currencyTypes = self.currencyTypes
        }
    }
    
    /// Navigation Bar Settings
    func navTitleWithImageAndText(titleText: String, imageUrl: String) -> UIView
    {
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
        //BUGGG
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
    
    //shows spinner
    func showActivityIndicator()
    {
        if #available(iOS 13.0, *) {activityView = UIActivityIndicatorView(style: .medium)}
        else {activityView = UIActivityIndicatorView(style: .gray)}
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    //hides spinner
    func hideActivityIndicator(){if (activityView != nil){activityView?.stopAnimating()}}
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {print(entry)}
    @IBAction func currencyTypeButtonClicked(_ sender: Any){self.performSegue(withIdentifier: "toCurrencySelectorFromDetails", sender: self)}
    
    //Locks the screen before view is appeared and realease this locking before view is disappeared
    override func viewWillAppear(_ animated: Bool) {super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)}
    override func viewWillDisappear(_ animated: Bool) {super.viewWillDisappear(animated);AppUtility.lockOrientation(.all)}
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

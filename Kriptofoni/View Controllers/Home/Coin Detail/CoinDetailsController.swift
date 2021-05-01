//
//  SelectedCoinViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//



import UIKit;import SDWebImage;import TinyConstraints; import Charts; import Toast_Swift
class CoinDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyTypeButton: UIBarButtonItem!
    var stringArray = ["Price","Price For Btc","Change For 1 Hour","Change For 24 Hours","Change For 7 Days","Market Value","24 Hours Vol", "Circulating Supply", "Total Supply"]
    var iconNames = ["globe","reddit","twitter"]
    var socialMediaTexture = ["Website","Reddit","Twitter"]
    var currentCurrencySymbol = Currency.currencySymbol; var currentCurrencyKey = Currency.currencyKey; var currentCoinId = "";var chartType = "twentyFour_hours"
    var values = [ChartDataEntry]();var isLineCharts = true; // if user press change the graph to candle, this bool is going to be false
    var activityView: UIActivityIndicatorView?
    var dict : [String:Any] = [:]; var linkArray = [String](); var webSiteLink = String(); var twitterLink = String(); var redditLink = String()
    var currencyTypes = [String]()
    var selectedSearchCoin = SearchCoin();var selectedCoin = Coin() // if the type variable is 0, we will use selectedSearchCoin instance and if the type type variable is 1, we will use selectedCoin variable
    var type = 0 // 0 means that we are coming this page from a search operation, 1 means that we are coming this page from normal currency selecting. I check that becuase we have two models as Coin and Search Coin and we need to know which one is usable or not to escape bugs.
    var sSize: CGRect = UIScreen.main.bounds

    
    //Locks the screen before view is appeared and realease this locking before view is disappeared
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);AppUtility.lockOrientation(.all)
        if let parentVC = self.parent{ if let parentVC = parentVC.children[0] as? MainController {parentVC.isFirstTime = false}}//for not to fetch data over and over again every time user press back button
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        currentCurrencySymbol = Currency.currencySymbol
        currentCurrencyKey = Currency.currencyKey
        self.currencyTypeButton.title = currentCurrencyKey.uppercased()
        showActivityIndicator()
        self.tableView.delegate = self; self.tableView.dataSource = self;
        controllerStarter()
    }
    
    override func viewDidLoad(){super.viewDidLoad()}
    
    /// Starter function for view controller
    func controllerStarter()
    {
        if type == 0  //0 means that we are coming this page from a search operation
        {
            self.currentCoinId = self.selectedSearchCoin.getId()
            getData(id: self.currentCoinId, name: self.selectedSearchCoin.getName(), shortening: self.selectedSearchCoin.getSymbol(), url: self.selectedSearchCoin.getImageUrl())
        }
        else //1 means that we are coming this page from normal currency selecting
        {
            self.currentCoinId = self.selectedCoin.getId()
            getData(id: self.currentCoinId, name: self.selectedCoin.getName(), shortening: self.selectedCoin.getShortening(), url: self.selectedCoin.getIconViewUrl())
        }
    }
    
    //Gets data from coin gecko api
    func getData(id: String, name: String, shortening : String, url: String)
    {
        CoinGecko.getCoinDetails(id: id, currencyType: currentCurrencyKey) { (result) in
            self.dict = result
            CoinGecko.getDataForCharts(id: id, currency: self.currentCurrencyKey, type: self.chartType) { (chartdata) in
                self.values = chartdata
                DispatchQueue.main.async{self.hideActivityIndicator();self.tableView.reloadData()}
            }
        } 
        self.navigationItem.titleView = navTitleWithImageAndText(titleText: name + " " + shortening.uppercased(), imageUrl: url)
    }
    
    // MARK: - Table View Functions
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
            cell.leftLabel.text = currentCurrencySymbol + " " + Util.toPrice((self.dict["current_price_for_currency"]! as! NSNumber).doubleValue, isCoinDetailPrice: true)
            if (self.dict["price_change_percentage_24h"]! as! NSNumber).intValue > 0{cell.rigthLabel.textColor = UIColor.green}
            else{cell.rigthLabel.textColor = UIColor.red}
            cell.rigthLabel.text = "%" + String(format: "%.3f", (self.dict["price_change_percentage_24h"]! as! NSNumber).doubleValue)
            return cell
        }
        else if indexPath.row == 1 // Chart Cell also contains chart settings
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "secondCell", for: indexPath) as! SecondCell
            let buttons = [cell.firstButton, cell.secondButton, cell.button24H, cell.button1W, cell.button1M, cell.button3M, cell.button6M, cell.button1Y, cell.buttonAll]
            for (index,item) in buttons.enumerated() {item!.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchUpInside); item!.tag = index}
            if isLineCharts // sets line chart
            {
                cell.candleStickChartView.isHidden = true;cell.chartView.isHidden = false; cell.chartView.delegate = self;
                ChartUtil.setLineChartSettings(chartView: cell.chartView, xAxisLabelCount: cell.xAxisLabelCount, values: values, dict: dict, chartType: chartType)
            }
            else // sets candle chart
            {
                cell.candleStickChartView.isHidden = false; cell.chartView.isHidden = true; cell.candleStickChartView.delegate = self
                //let set1Candle = CandleChartDataSet(entries: values, label: "Prices")
                //let dataCandle = CandleChartData(dataSet: set1Candle)
                //dataCandle.setDrawValues(false)
            }
            return cell
        }
       
        else if indexPath.row == 2 //OneToTwoCell --> 1 label at left side and 2 label at right side of cell
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToTwoCell", for: indexPath) as! OneToTwoCell
            cell.leftLabel.text = stringArray[indexPath.row-2]
            if (self.dict["price_change_percentage_24h"]! as! NSNumber).intValue > 0{cell.rightLabelUp.textColor = UIColor.green}
            else{cell.rightLabelUp.textColor = UIColor.red}
            cell.rightLabelUp.text = "%" + String(format: "%.3f", (self.dict["price_change_percentage_24h"]! as! NSNumber).doubleValue)
            cell.rightLabelDown.text = currentCurrencySymbol + " " + Util.toPrice((self.dict["current_price_for_currency"]! as! NSNumber).doubleValue, isCoinDetailPrice: true)
            return cell
        }
        else if indexPath.row == 3 //OneToTwoCell --> 1 label at left side and 2 label at right side of cell
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
            if indexPath.row == 11 {webSiteLink = self.dict["website"] as! String}
            else if indexPath.row == 12 {twitterLink = self.dict["twitter"] as! String}
            else if indexPath.row == 13 {redditLink = self.dict["reddit"] as! String}
            return cell
        }
        else if indexPath.row == 14
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonCell", for: indexPath) as! TwoButtonCell
            cell.addOperation.addTarget(self, action: #selector(self.operationButtonClicked(sender:)), for: .touchUpInside)
            cell.favoritesButton.addTarget(self, action: #selector(self.addWatchingListButtonClicked(sender:)), for: .touchUpInside)
            return cell
        }
        else if indexPath.row ==  15
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneButtonCell", for: indexPath) as! OneButtonCell
            return cell
        }
        return cell
    }
    
    //Table view cell clicked function, user can only tap to social media cells. when user taps we direct them to the websites.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row >= 11 && indexPath.row < 14
        {
            if indexPath.row == 11
            {
                guard let url = URL(string: webSiteLink) else { return }
                UIApplication.shared.open(url) //sending user to the url
            }
            else if indexPath.row == 12
            {
                print(redditLink + "Reddit link")
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
    
    
    // MARK: - Button Clicked Funcs
    
    @IBAction func currencyTypeButtonClicked(_ sender: Any){self.performSegue(withIdentifier: "toCurrencySelectorFromDetails", sender: self)}
    @objc func operationButtonClicked(sender: UIButton){self.performSegue(withIdentifier: "toOperationCoinDetails", sender: self)}
    
    /// Adds coin to watcing list in core data.
    @objc func addWatchingListButtonClicked(sender: UIButton)
    {
        if CoreDataWatchingList.addWatchingList(id:self.currentCoinId)
        {
            self.view.makeToast("Coin has been added successfully.", duration: 2.0, position: .center)
        }
        else
        {
            self.view.makeToast("Coin is already in your watching list.", duration: 2.0, position: .center)
        }
    }
    
    @objc func tappedButton(sender : UIButton)
    {
        if sender.tag != 0 && sender.tag != 1
        {
            switch sender.tag
            {
                case 2:chartType = "twentyFour_hours"
                case 3:chartType = "one_week_before"
                case 4:chartType = "one_month_before"
                case 5:chartType = "three_months_before"
                case 6:chartType = "six_months_before"
                case 7:chartType = "one_year_before"
                case 8:chartType = "all"
                default:
                    print("cem")
            }
            DispatchQueue.main.async{self.hideActivityIndicator();self.showActivityIndicator()}
            CoinGecko.getDataForCharts(id: self.currentCoinId, currency: self.currentCurrencyKey, type: chartType) { (chartdata) in
                    self.values = chartdata
                    DispatchQueue.main.async{self.hideActivityIndicator();self.tableView.reloadData()}
                }
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
            destinationVC.charType = isLineCharts // line chart or candle chart
            destinationVC.coinId = currentCoinId
            destinationVC.dict = dict
        }
        else if segue.identifier == "toOperationCoinDetails"
        {
            let destinationVC = segue.destination as! AddToPortfolioController
            destinationVC.currencyTypes = self.currencyTypes
        }
    }
    
    // MARK: - Design Settings
    
    
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
        let imageX = label.frame.origin.x - (label.frame.size.height * imageAspect * 2 )
        let imageY = label.frame.origin.y + (label.frame.origin.y * 0.4)
        let imageWidth = label.frame.size.height * imageAspect * 1.5
        let imageHeight = label.frame.size.height * 1.5
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
    
}


//Storyboard settings for adding border to views
extension UIView
{
    // MARK: - Properties
    @IBInspectable var borderWidth: CGFloat
    {
        get {return layer.borderWidth}
        set {layer.borderWidth = newValue}
    }
    
    @IBInspectable var borderColor: UIColor?
    {
        get {return UIColor(cgColor: layer.borderColor!)}
        set {layer.borderColor = newValue?.cgColor}
    }
}


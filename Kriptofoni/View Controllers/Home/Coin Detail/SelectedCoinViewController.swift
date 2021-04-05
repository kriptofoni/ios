//
//  SelectedCoinViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit
import SDWebImage
class SelectedCoinViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tableView: UITableView!
    var stringArray = ["Q","W","E","R","T","Y","Z","U","W"]
    var socialMediaTexture = ["Website","Reddit","Twitter"]
    var selectedSearchCoin = SearchCoin();var selectedCoin = Coin() // if the type variable is 0, we will use selectedSearchCoin instance and if the type type variable is 1, we will use selectedCoin variable
    var type = 0 // 0 means that we are coming this page from a search operation, 1 means that we are coming this page from normal currency selecting. I check that becuase we have two models as Coin and Search Coin and we need to know which one is usable or not to escape bugs.
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "2000"
        if type == 0
        {
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedSearchCoin.getName() + " " + selectedSearchCoin.getSymbol().uppercased(), imageUrl: selectedSearchCoin.getImageUrl())
            self.navigationItem.prompt = selectedSearchCoin.getName() + " " + selectedSearchCoin.getSymbol().uppercased()
        }
        else
        {
            self.navigationItem.titleView = navTitleWithImageAndText(titleText: selectedCoin.getName() + " " + selectedCoin.getShortening().uppercased(), imageUrl: selectedCoin.getIconViewUrl())
            self.navigationItem.prompt = selectedCoin.getName() + " " + selectedCoin.getShortening().uppercased()
        }
        
        tableView.delegate = self; tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return stringArray.count + 8}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0
        if indexPath.row == 0 {height =  59}
        else if indexPath.row == 1 {height =  218}
        else if indexPath.row == 2 {height = 42}
        else if (2 < indexPath.row) && (indexPath.row < 3 + stringArray.count) {height = 43}
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
        else if (2 < indexPath.row) && (indexPath.row < 3 + stringArray.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneToOneCell", for: indexPath) as! OneToOneCell
            cell.leftLabel.text = stringArray[indexPath.row-3]
            return cell
        }
        else if indexPath.row > stringArray.count + 2 && indexPath.row < stringArray.count + 6
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCell", for: indexPath) as! SocialMediaCell
            return cell
        }
        else if indexPath.row == stringArray.count + 6
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonCell", for: indexPath) as! TwoButtonCell
            return cell
        }
        else if indexPath.row ==  stringArray.count + 7
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
        label.text = titleText
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

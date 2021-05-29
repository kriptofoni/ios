//
//  NewsController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 6.05.2021.
//

import UIKit
import WebKit
import ScrollableSegmentedControl

class NewsController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 0
        {
            height = 257
        }
        else
        {
            height = 155
        }
        return CGFloat(height)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "firstNewsCell", for: indexPath) as! FirstNewsCell
            //cellerhazır cell. deyip image ve title ları set edebilirsin...

            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherNewsCell", for: indexPath) as! OtherNewsCell
            return cell
        }
       
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    var sSize: CGRect = UIScreen.main.bounds
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let sWidth = sSize.width
        segmentedView.frame.size.width = sWidth
        setSegmentSettings()
        tableView.delegate = self; tableView.dataSource = self
    }
    
    func setSegmentSettings()
    {
        segmentedView.segmentStyle = .textOnly;
        segmentedView.insertSegment(withTitle: "Handpicked",at: 0);
        segmentedView.insertSegment(withTitle: "Trending"  ,at: 1);
        segmentedView.insertSegment(withTitle: "Latest"    ,
                                    at: 2);
        segmentedView.underlineSelected = true; segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(MainController.segmentSelected(sender:)), for: .valueChanged)
        self.segmentedView.backgroundColor = UIColor(named: "Header Color")
        self.segmentedView.selectedSegmentContentColor = Util.defaultFont
        
    }
    
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl)
    {
        /*
        switch sender.selectedSegmentIndex
        {
            
        }
        self.tableView.reloadData()
        */
    }

}

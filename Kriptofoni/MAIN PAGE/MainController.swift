//
//  MainController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 25.03.2021.
//

import UIKit

class MainController: UIViewController, UICollectionViewDataSource {
    
    
    let items = ["COINS","MOST INC IN 24 HOURS","MOST DEC IN 24 HOURS","MOST INC IN 7 DAYS","MOST DEC IN 7 DAYS"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        //self.collectionView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        cell.label.text! = self.items[indexPath.row]
        return cell
    }
    


    

}

//
//  ContractAndAbout.swift
//  learning
//
//  Created by Deniz Eren Gençay on 17.04.2021.
//

import UIKit
import PDFKit

class ContractAndAbout: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = Bundle.main.url(forResource: "pdf", withExtension: "pdf")
        
        if let pdfDocument = PDFDocument(url: url!){
            
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
            
        }
       
    }
    


}

//
//  PdfReaderController.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 28.01.2021.
//

import UIKit
import PDFKit


class PdfReaderController: UIViewController {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var viewMain: PDFView!
    @IBOutlet weak var label: UILabel!
    var isLocked = false //if user presses stop button, pdf is locked on the page
    var document = PDFDocument()
    var currentFileUrl = ""
    var startingPageNumber = Int64()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if currentFileUrl != ""
        {
            let libraryPath = FirebaseUtil.getPdfFromLibrary(id: currentFileUrl + ".pdf")
            let url = URL(string: libraryPath)
            document = PDFDocument(url:url!)!
        }
        if let page10 = document.page(at: Int(startingPageNumber))
        {
            viewMain.go(to: page10)
        }
        viewMain.document = document
        viewMain.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        viewMain.displayDirection = .vertical
        viewMain.autoScales = true
        viewMain.displayMode = .singlePageContinuous
        viewMain.usePageViewController(true)
        viewMain.displaysPageBreaks = true
        viewMain.maxScaleFactor = 4.0
        viewMain.minScaleFactor = viewMain.scaleFactorForSizeToFit
        viewMain.backgroundColor = UIColor.white
    }
    
    @IBAction func stopButtonAction(_ sender: Any)
    {
        
    }
    
   
    @IBAction func nextPageAction(_ sender: Any)//next page button
    {
        var currentPage = self.viewMain.currentPage?.pageRef?.pageNumber
        let validPageIndex: Int = currentPage!
        guard let targetPage = viewMain.document!.page(at: validPageIndex) else { return }
        viewMain.go(to: targetPage)
    }
    
    @IBAction func previousPageAction(_ sender: Any)//previous page button
    {
        var currentPage = self.viewMain.currentPage?.pageRef?.pageNumber
        let validPageIndex: Int = currentPage!
        guard let targetPage = viewMain.document!.page(at: validPageIndex) else { return }
        viewMain.go(to: targetPage)
    }
}

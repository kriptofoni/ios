//
//  CoopAndHelpTextViewCell.swift
//  learning
//
//  Created by Deniz Eren Gençay on 17.04.2021.
//

import UIKit

class CoopAndHelpTextViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            textView.text = "PlaceHolder"
            textView.textColor = UIColor.lightGray
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

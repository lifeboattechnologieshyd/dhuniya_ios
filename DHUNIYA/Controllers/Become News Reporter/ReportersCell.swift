//
//  ReporterDetailsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//
import UIKit

class ReportersCell: UITableViewCell {
    
    @IBOutlet weak var tamilButton: UIButton!
    @IBOutlet weak var kannadaButton: UIButton!
    @IBOutlet weak var marathiButton: UIButton!
    @IBOutlet weak var hindiButton: UIButton!
    @IBOutlet weak var teluguButton: UIButton!
    @IBOutlet weak var malayalamButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var newslanguageLbl: UILabel!
    @IBOutlet weak var tellyourselfTV: UITextView!
    @IBOutlet weak var reporternameTF: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mobilenumberTF: UITextField!
    @IBOutlet weak var uploadpictureButton: UIButton!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var mobilenumberLbl: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var reporternameLbl: UILabel!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var uncheckboxButton: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()          // Force correct size
        uploadView.addDottedBorder()
    }
    
}

//
//  PatientTableViewCell.swift
//  Observer-Assist
//
//  Created by admin on 9/3/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    @IBOutlet weak var patientName: UILabel!
    //@IBOutlet weak var location: UILabel!
    //@IBOutlet weak var status: UILabel!
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

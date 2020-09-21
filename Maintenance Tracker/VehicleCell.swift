//
//  VehicleCellTableViewCell.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/20/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//

import UIKit

class VehicleCell: UITableViewCell {

    @IBOutlet var thumbnailImage: UIImageView!
    @IBOutlet var vehicleInfoLabel: UILabel!
    @IBOutlet var additionalInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

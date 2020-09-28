//
//  MaintenanceItemCellTableViewCell.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/27/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//

import UIKit

class MaintenanceItemCell: UITableViewCell {

    
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

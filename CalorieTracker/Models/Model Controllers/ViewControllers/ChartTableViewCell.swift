//
//  ChartTableViewCell.swift
//  CalorieTracker
//
//  Created by Alex Thompson on 5/3/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        Label1.layer.cornerRadius = 20
        Label2.layer.cornerRadius = 20
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

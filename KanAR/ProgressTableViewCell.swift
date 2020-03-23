//
//  ProgressTableViewCell.swift
//  KanAR
//
//  Created by Kin Wa Lam on 22/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var charLabel: UILabel!
    @IBOutlet weak var writeCountLabel: UILabel!
    @IBOutlet weak var speakCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

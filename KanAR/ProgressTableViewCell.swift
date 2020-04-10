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
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(record: ProgressRecord) {
        let userDefaults = UserDefaults.standard
        let write = Double(record.writeCount) / Double(userDefaults.integer(forKey: "target"))
        let speak = Double(record.speakCount) / Double(userDefaults.integer(forKey: "target"))
        let progress = (write + speak) * 100
        charLabel.text = record.character
        if progress > 100 {
            progressLabel.text = "Total Progress: 100%"
        } else {
            progressLabel.text = "Total Progress: \(Int(progress.rounded(.toNearestOrAwayFromZero)))%"
        }
    }

}

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
        charLabel.text = record.character
        let userDefaults = UserDefaults.standard
        if (record.dailyRecords.filter("date = %@", Date().onlyDate!).count != 0) {
            let write = Double(record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctWriteCount) / Double(userDefaults.integer(forKey: "target") * 2)
            let speak = Double(record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctSpeakCount) / Double(userDefaults.integer(forKey: "target") * 2)
            let progress = (write + speak) * 100
            if progress > 100 {
                progressLabel.text = "Today's Progress: Finished!"
            } else {
                progressLabel.text = "Today's Progress: \(Int(progress.rounded(.toNearestOrAwayFromZero)))%"
            }
        }
    }

}

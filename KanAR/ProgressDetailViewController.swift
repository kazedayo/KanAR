//
//  ProgressDetailViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 25/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit

class ProgressDetailViewController: UIViewController {
    
    @IBOutlet weak var charLabel: UILabel!
    @IBOutlet weak var writeCountLabel: UILabel!
    @IBOutlet weak var speakCountLabel: UILabel!
    
    var char = ""
    var writeCount = 0
    var speakCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        charLabel.text = char
        writeCountLabel.text = "Total Times Wrote: \(writeCount)"
        speakCountLabel.text = "Total Times Spoke: \(speakCount)"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

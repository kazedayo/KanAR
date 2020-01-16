//
//  KanaInfoViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 16/1/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit

class KanaInfoViewController: UIViewController {
    
    @IBOutlet weak var kanaLabel: UILabel!
    @IBOutlet weak var kanaDescriptionLabel: UILabel!
    
    var kanaSet = ["Mutsu":["む","Hiragana character 'Mu'"],"Naganami":["な","Hiragana character 'Na'"],"Takao":["た","Hiragana character 'Ta'"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    //MARK: Update View Text Lables
    func setInfo(key: String) {
        kanaLabel.text = kanaSet[key]![0]
        kanaDescriptionLabel.text = kanaSet[key]![1]
        view.layoutIfNeeded()
    }
    
    //MARK: Show/Hide View w/ Animation
    
    func setViewHidden(_ hide:Bool) {
        view.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.alpha = hide ? 0 : 1
        }, completion: nil)
    }
}

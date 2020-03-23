//
//  ProgressViewController.swift
//  KanAR
//
//  Created by Kin Wa Lam on 22/3/2020.
//  Copyright © 2020 Kin Wa Lam. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var progressTableView: UITableView!
    
    let realmDBWorker = RealmDBWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTableView.delegate = self
        progressTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            count = realmDBWorker.retrieveRecords(type: "Hiragana").count
            break
        case 1:
            count = realmDBWorker.retrieveRecords(type: "Katakana").count
            break
        default:
            break
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = progressTableView.dequeueReusableCell(withIdentifier: "progressTableViewCell", for: indexPath) as! ProgressTableViewCell
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let record = realmDBWorker.retrieveRecords(type: "Hiragana")[indexPath.row]
            cell.charLabel.text = record.character
            cell.writeCountLabel.text = "Times wrote: \(record.writeCount)"
            cell.speakCountLabel.text = "Times spoke: \(record.speakCount)"
            break
        case 1:
            let record = realmDBWorker.retrieveRecords(type: "Katakana")[indexPath.row]
            cell.charLabel.text = record.character
            cell.writeCountLabel.text = "Times wrote: \(record.writeCount)"
            cell.speakCountLabel.text = "Times spoke: \(record.speakCount)"
            break
        default:
            break
        }
        return cell
    }
    
    @IBAction func switchType(_ sender: UISegmentedControl) {
        progressTableView.reloadData()
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

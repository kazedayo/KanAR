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
    @IBOutlet weak var setTargetButton: UIButton!
    @IBOutlet weak var targetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTableView.delegate = self
        progressTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = progressTableView.indexPathForSelectedRow {
            progressTableView.deselectRow(at: index, animated: true)
        }
        targetLabel.text = "Daily Target: \(UserDefaults.standard.integer(forKey: "target"))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            count = RealmDBWorker.sharedInstance.retrieveRecords(type: "Hiragana").count
            break
        case 1:
            count = RealmDBWorker.sharedInstance.retrieveRecords(type: "Katakana").count
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
            let record = RealmDBWorker.sharedInstance.retrieveRecords(type: "Hiragana")[indexPath.row]
            cell.initCell(record: record)
            break
        case 1:
            let record = RealmDBWorker.sharedInstance.retrieveRecords(type: "Katakana")[indexPath.row]
            cell.initCell(record: record)
            break
        default:
            break
        }
        return cell
    }
    
    @IBAction func switchType(_ sender: UISegmentedControl) {
        progressTableView.reloadData()
    }
    
    @IBAction func targetButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Set Your Daily Learning Target", message: "Set the number of times you aim to write/speak a Kana character correctly every day", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            textfield in
            textfield.keyboardType = .numberPad
            textfield.placeholder = "Default: 15"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in 
            let newTarget = alert.textFields![0].text
            if newTarget != "" {
                let targetValue = Int(newTarget!)!
                UserDefaults.standard.set(targetValue, forKey: "target")
                self.targetLabel.text = "Daily Target: \(targetValue)"
                self.progressTableView.reloadData()
            } else {
                UserDefaults.standard.set(15, forKey: "target")
                self.targetLabel.text = "Daily Target: \(15)"
                self.progressTableView.reloadData()
            }
        }))
        present(alert,animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetailSegue" {
            let destination = segue.destination as! ProgressDetailViewController
            let index = progressTableView.indexPathForSelectedRow?.row
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                let record = RealmDBWorker.sharedInstance.retrieveRecords(type: "Hiragana")[index!]
                destination.char = record.character
                destination.record = record
                if (record.dailyRecords.filter("date = %@", Date().onlyDate!).count != 0) {
                    destination.writeCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.writeCount
                    destination.speakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.speakCount
                    destination.correctSpeakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctSpeakCount
                    destination.correctWriteCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctWriteCount
                }
                break
            case 1:
                let record = RealmDBWorker.sharedInstance.retrieveRecords(type: "Katakana")[index!]
                destination.char = record.character
                destination.record = record
                if (record.dailyRecords.filter("date = %@", Date().onlyDate!).count != 0) {
                    destination.writeCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.writeCount
                    destination.speakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.speakCount
                    destination.correctSpeakCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctSpeakCount
                    destination.correctWriteCount = record.dailyRecords.filter("date = %@", Date().onlyDate!).first!.correctWriteCount
                }
                break
            default:
                break
            }
        }
    }
    

}

//
//  GoalTableView.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/29/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

protocol GoalPickerControllerDelegate: class {
    func itemSelectedGoal(atRow row: Int)
}

class GoalTableView: UITableViewController {
    //MARK: Properties
    
    var tableData: [String]?
    weak var delegate: GoalPickerControllerDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel?.text = tableData?[indexPath.row]
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let delegate = delegate {
            delegate.itemSelectedGoal(atRow: indexPath.row)
            dismiss(animated: true)
            
            let buttonTitle = String(format: "%lu", UInt64(indexPath.row))
            UserDefaults.standard.set(buttonTitle, forKey: "goal-name")
            print("row \(buttonTitle) selected")
        }
    }
    
    //MARK: - Actions
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true)
    }
}

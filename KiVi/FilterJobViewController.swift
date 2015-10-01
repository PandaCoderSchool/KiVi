//
//  FilterJobViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class FilterJobViewController: UIViewController {
  
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterJobViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filter = Global.filters[section] as Filter
        if !filter.isExpanded {
            switch filter.type {
            case .MultipleSwitches:
                return filter.numberOfVisibleRows! + 1
            case .DropDown:
                return 1
            case .SingleSwitch:
                return 1
            }
        }
        return filter.options.count
    }
    
    func addSwitch(cell: SwitchCell, option: Option) {
        let switchButton = UISwitch()
        cell.accessoryView = switchButton
        switchButton.on = option.isEnabled ?? false
        cell.switchLabel.text = option.name
        switchButton.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.switchLabel.textAlignment = NSTextAlignment.Left
        cell.switchLabel.textColor = .blackColor()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let filter = Global.filters[indexPath.section] as Filter
        let option = filter.options[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
        switch filter.type {
        case .DropDown:
            if filter.isExpanded {
                if option.isEnabled {
                    cell.accessoryView = UIImageView(image: UIImage(named: "Checked"))
                }
                else{
                    cell.accessoryView = UIImageView(image: UIImage(named: "Unchecked"))
                }
                cell.switchLabel.text = filter.name
            }
            else {
                cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
                cell.switchLabel.text = filter.selectedOption.name
            }
        case .MultipleSwitches:
            if filter.isExpanded {
                addSwitch(cell, option:option)
            }
            else {
                cell.switchLabel.text = "See All"
                cell.switchLabel.textAlignment = NSTextAlignment.Center
                cell.switchLabel.textColor = .darkGrayColor()
            }
        case .SingleSwitch:
            addSwitch(cell, option: option)
        }
        return cell
    }
}

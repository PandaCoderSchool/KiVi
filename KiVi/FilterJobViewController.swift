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
    }

}

extension FilterJobViewController: UITableViewDelegate, UITableViewDataSource{
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switchCell(sender.superview as! SwitchCell, value: sender.on)
    }
    
    func switchCell(switchCell: SwitchCell, value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)
        let filter = Global.filters[indexPath!.section]
        filter.options[indexPath!.row].isEnabled = value
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let filter = Global.filters[section]
        return filter.name
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Global.filters.count
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
                cell.switchLabel.text = option.name
            }
            else {
                cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
                cell.switchLabel.text = filter.selectedOption.name
            }
            cell.switchLabel.textAlignment = NSTextAlignment.Left
        case .MultipleSwitches:
            if filter.isExpanded || indexPath.row < filter.numberOfVisibleRows {
                addSwitch(cell, option:option)
                cell.switchLabel.textAlignment = NSTextAlignment.Left

            }
            else {
                cell.switchLabel.text = "See All"
                cell.switchLabel.textAlignment = NSTextAlignment.Center
                cell.switchLabel.textColor = .darkGrayColor()
                cell.accessoryView  = nil
            }
        case .SingleSwitch:
            addSwitch(cell, option: option)
            cell.switchLabel.textAlignment = NSTextAlignment.Left

        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filter = Global.filters[indexPath.section]
        switch filter.type {
        case .DropDown:
            if filter.isExpanded {
                filter.resetToFalse()
                filter.options[indexPath.row].isEnabled = true
            }
            filter.isExpanded = !filter.isExpanded
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        case .MultipleSwitches:
            if indexPath.row == filter.numberOfVisibleRows && !filter.isExpanded {
                filter.isExpanded = true
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            }
        default:
            break
        }
    }
}

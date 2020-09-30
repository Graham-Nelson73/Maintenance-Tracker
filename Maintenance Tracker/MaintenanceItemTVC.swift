//
//  MaintenanceItemTVC.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/27/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//

import UIKit
import CoreData

class MaintenanceItemTVC: UITableViewController {
    
    var vehicle: Vehicle?
    var maintenanceItems = [MaintenanceItem]()
    
    var addMaintenanceItemAC = UIAlertController()
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //handle nil vehicle, exit back to garage
        if vehicle == nil {
            _ = navigationController?.popViewController(animated: true)
        }
        
        title = "\(vehicle!.year) \(vehicle!.make!) \(vehicle!.model!)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Maintenance Item", style: .plain, target: self, action: #selector(addMaintenanceItem))
        
        tableView.rowHeight = 80
        
        numberFormatter.numberStyle = .decimal
        configureDatePicker()
        fetchMaintenanceItems()
    }
    
    func configureDatePicker(){
        //configure date picker
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        dateFormatter.dateFormat = "MM-dd-yyyy"
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    func fetchMaintenanceItems(){
        //let maintenanceItems =
        let sortedSet = vehicle!.executes?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "mileage", ascending: false), NSSortDescriptor(key: "title", ascending: false)]) as! [MaintenanceItem]
        maintenanceItems = sortedSet
        //let maintenanceItems = Array(vehicle!.executes as! Set<MaintenanceItem>)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //show alert controller to create new maintenance item and add it to the vehicle
    @objc func addMaintenanceItem(){
        addMaintenanceItemAC = UIAlertController(title: "New Maintenance Item", message: nil, preferredStyle: .alert)
        addMaintenanceItemAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Title"
            textField.autocapitalizationType = .words
        })
        addMaintenanceItemAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Mileage"
            textField.keyboardType = UIKeyboardType.numberPad
        })
        addMaintenanceItemAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Date"
            let date = Date()
            textField.text = self.dateFormatter.string(from: date)
            textField.inputView = self.datePicker
        })
        addMaintenanceItemAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addMaintenanceItemAC.addAction(UIAlertAction(title: "Save", style: .default, handler: {UIAlertAction in
            let inputtedTitle = self.addMaintenanceItemAC.textFields![0].text
            let inputtedMileage = self.addMaintenanceItemAC.textFields![1].text
            let inputtedDate = self.addMaintenanceItemAC.textFields![2].text
            //handle bad input
            if inputtedTitle == "" {
                self.badFieldInput(fieldName: "Title")
                return
            }
            if inputtedDate == "" {
                self.badFieldInput(fieldName: "Date")
                return
            }
            let newItem = MaintenanceItem(context: self.context)
            newItem.title = inputtedTitle
            if let mileage = Int(inputtedMileage ?? ""){
                newItem.mileage = Int64(mileage)
            } else {
                self.context.delete(newItem)
                do{
                    try self.context.save()
                } catch{}
                self.badMileageInput()
                return
            }
            newItem.date = self.dateFormatter.date(from: inputtedDate ?? "")
            self.vehicle?.addToExecutes(newItem)
            
            //save new item
            do{
                try self.context.save()
            } catch{}
            self.fetchMaintenanceItems()
        }))
        
        
        present(addMaintenanceItemAC, animated: true)
    }
    
    //inform user of improper input for mileage
    func badMileageInput(){
        let badYearAC = UIAlertController(title: "Incorrect Input", message: "Incorrect Input: Mileage must be an integer", preferredStyle: .alert)
        badYearAC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(badYearAC, animated: true)
    }
    
    //inform user of improper input for fieldName
    func badFieldInput(fieldName: String){
        let badFieldAC = UIAlertController(title: "Incorrect Input", message: "Field \(fieldName) can not be empty", preferredStyle: .alert)
        badFieldAC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(badFieldAC, animated: true)
    }
    
    //update text field when date is changed
    @objc func dateChanged(){
        if(addMaintenanceItemAC.textFields != nil && addMaintenanceItemAC.textFields?.count ?? 0 >= 2){
            addMaintenanceItemAC.textFields?[2].text = dateFormatter.string(from: datePicker.date)
        }
        view.endEditing(true)
    }
    
    func deleteItem(atIndex index: Int){
        let deleteItemAC = UIAlertController(title: "Delete Maintenance Item", message: "Are you sure you want to delete \(maintenanceItems[index].title ?? "")?", preferredStyle: .alert)
        deleteItemAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deleteItemAC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {UIAlertAction in
            self.context.delete(self.maintenanceItems[index])
            do{
                try self.context.save()
            } catch{}
            self.fetchMaintenanceItems()
        }))
        present(deleteItemAC, animated: true)
    }
    
    //perform sugue to detail view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = maintenanceItems[indexPath.row]
        performSegue(withIdentifier: "MaintenanceItemToDetail", sender: selectedItem)
    }
    
    //pass reference to selected vehicle to maintenance item tabel view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MaintenanceItemToDetail"{
            let destinationVC = segue.destination as! MaintenanceItemDetailVC
            destinationVC.maintenanceItem = sender as? MaintenanceItem
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maintenanceItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MaintenanceItemCell", for: indexPath) as! MaintenanceItemCell
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        var itemDateString : String
        if let itemDate = maintenanceItems[indexPath.row].date {
            itemDateString = dateFormatter.string(from: itemDate)
        } else {
            itemDateString = ""
        }
        cell.itemTitle.text = "\(maintenanceItems[indexPath.row].title ?? "")"
        //format mileage with commas
        cell.itemInfo.text = "Mileage: \(numberFormatter.string(from: NSNumber(value: maintenanceItems[indexPath.row].mileage)) ?? "")   Date: \(itemDateString)"

        return cell
    }
    
    //add action to delete on left swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.deleteItem(atIndex: indexPath.row)
            completionHandler(true)
        }
        //deleteAction.backgroundColor = .green
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
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

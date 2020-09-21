//
//  ViewController.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/19/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController{

    @IBOutlet var vehiclesTableView: UITableView!

    var vehicles = [Vehicle]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let types = ["", "Car", "Truck", "SUV", "Motorcycle", "Other"]
    let typePicker = UIPickerView()

    var addVehicleAC = UIAlertController()
    var editVehicleAC = UIAlertController()
    var editVehicleInfoAC = UIAlertController()
    
    var editingIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchVehicles()
        self.title = "Garage"
        vehiclesTableView.rowHeight = 100
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Vehicle", style: .plain, target: self, action: #selector(addVehicle))
        
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    @objc func addVehicle(){
        //fill alert with input fields
        addVehicleAC = UIAlertController(title: "Add Vehicle", message: nil, preferredStyle: .alert)
        addVehicleAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Make"
        })
        addVehicleAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Model"
        })
        addVehicleAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Year ex: 1999"
            textField.keyboardType = UIKeyboardType.numberPad
        })
        addVehicleAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Type"
            textField.inputView = self.typePicker
        })
        addVehicleAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //save vehicle to core data and refresh table view
        addVehicleAC.addAction(UIAlertAction(title: "Save", style: .default, handler: { UIAlertAction in
            let inputtedMake = self.addVehicleAC.textFields![0].text
            let inputtedModel = self.addVehicleAC.textFields![1].text
            let inputtedYear = self.addVehicleAC.textFields![2].text
            let inputtedType = self.addVehicleAC.textFields![3].text
            //handle bad input
            if inputtedMake == "" {
                self.badFieldInput(fieldName: "Make")
                return
            }
            else if inputtedModel == "" {
                self.badFieldInput(fieldName: "Model")
                return
            }
            else if inputtedYear == "" {
                self.badFieldInput(fieldName: "Year")
                return
            }
            //create new vehicle object
            let newVehicle = Vehicle(context: self.context)
            newVehicle.make = inputtedMake
            newVehicle.model = inputtedModel
            if let year = Int(inputtedYear ?? ""){
                newVehicle.year = Int64(year)
            } else {
                self.context.delete(newVehicle)
                do{
                    try self.context.save()
                } catch{}
                self.badYearInput()
                return
            }
            //default case for type, default to Car
            if (!self.types.contains(inputtedType!) || inputtedType == ""){
                newVehicle.type = "Car"
            } else {
                newVehicle.type = inputtedType
            }

            //save new vehicle
            do{
                try self.context.save()
            } catch{}
            self.fetchVehicles()
        }))
        typePicker.selectRow(0, inComponent: 0, animated: true)
        present(addVehicleAC, animated: true)
    }
    
    //give users option to add image or edit vehicle info
    func editVehicle(atIndex index: Int){
        editVehicleAC = UIAlertController(title: "Edit Vehicle", message: nil, preferredStyle: .alert)
        editVehicleAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        editVehicleAC.addAction(UIAlertAction(title: "Add Photo", style: .default, handler: { UIAlertAction in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.editingIndex = index
            self.present(imagePicker, animated: true)
        }))
        editVehicleAC.addAction(UIAlertAction(title: "Edit Vehicle Info", style: .default, handler: { UIAlertAction in
            self.editVehicleInfo(atIndex: index)
        }))
        present(editVehicleAC, animated: true)
    }
    
    //allow users to edit vehicle info
    func editVehicleInfo(atIndex index: Int){
        editVehicleInfoAC = UIAlertController(title: "Edit Vehicle Info", message: nil, preferredStyle: .alert)
        editVehicleInfoAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Make"
            textField.text = self.vehicles[index].make ?? ""
        })
        editVehicleInfoAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Model"
            textField.text = self.vehicles[index].model ?? ""
        })
        editVehicleInfoAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Year ex: 1999"
            textField.text = "\(self.vehicles[index].year)"
            textField.keyboardType = UIKeyboardType.numberPad
        })
        editVehicleInfoAC.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Type"
            textField.text = self.vehicles[index].type ?? ""
            textField.inputView = self.typePicker
        })
        editVehicleInfoAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        editVehicleInfoAC.addAction(UIAlertAction(title: "Save", style: .default, handler: { UIAlertAction in
            //create new vehicle object
            let inputtedMake = self.editVehicleInfoAC.textFields![0].text
            let inputtedModel = self.editVehicleInfoAC.textFields![1].text
            let inputtedYear = self.editVehicleInfoAC.textFields![2].text
            let inputtedType = self.editVehicleInfoAC.textFields![3].text
            //handle bad input
            if inputtedMake == "" {
                self.badFieldInput(fieldName: "Make")
                return
            }
            else if inputtedModel == "" {
                self.badFieldInput(fieldName: "Model")
                return
            }
            else if inputtedYear == "" {
                self.badFieldInput(fieldName: "Year")
                return
            }
            
            self.vehicles[index].make = inputtedMake
            self.vehicles[index].model = inputtedModel
            if let year = Int(inputtedYear ?? ""){
                self.vehicles[index].year = Int64(year)
            } else {
                self.badYearInput()
                return
            }
            //default case for type
            if (!self.types.contains(inputtedType!) || inputtedType == ""){
                self.vehicles[index].type = "Car"
            } else {
                self.vehicles[index].type = inputtedType
            }
            
            //save new vehicle
            do{
                try self.context.save()
            } catch{}
            self.fetchVehicles()
        }))
        typePicker.selectRow(types.firstIndex(of: vehicles[index].type ?? "") ?? 0, inComponent: 0, animated: true)
        present(editVehicleInfoAC, animated: true)
    }
    
    //ask user if they are sure they want to delete, then remove vehicle from core data
    func deleteVehicle(atIndex index: Int){
        let message = "Are you sure you want to delete \(self.vehicles[index].year) \(self.vehicles[index].make ?? "") \(self.vehicles[index].model ?? "")? All of its data will be lost."
        let deleteVehicleAC = UIAlertController(title: "Delete Vehicle", message: message, preferredStyle: .alert)
        deleteVehicleAC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        deleteVehicleAC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {UIAlertAction in
            //TODO delete image associated with vehicle.imagePath
            if FileManager.default.fileExists(atPath: self.vehicles[index].imagePath ?? ""){
                do{
                    try FileManager.default.removeItem(atPath: self.vehicles[index].imagePath!)
                } catch { }
            }
            self.context.delete(self.vehicles[index])
            do{
                try self.context.save()
            } catch{}
            self.fetchVehicles()
        }))
        present(deleteVehicleAC, animated: true)
    }
    
    //inform user of improper input for year
    func badYearInput(){
        let badYearAC = UIAlertController(title: "Bad Input", message: "Bad Input: Year must be an integer", preferredStyle: .alert)
        badYearAC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(badYearAC, animated: true)
    }
    
    //inform user of improper input for fieldName
    func badFieldInput(fieldName: String){
        let badFieldAC = UIAlertController(title: "Input", message: "Field \(fieldName) can not be empty", preferredStyle: .alert)
        badFieldAC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(badFieldAC, animated: true)
    }
    
    //get all stored vehicles in sorted order and refresh tableview
    func fetchVehicles(){
        do{
            let request = Vehicle.fetchRequest() as NSFetchRequest<Vehicle>
            let yearSort = NSSortDescriptor(key: "year", ascending: false)
            let makeSort = NSSortDescriptor(key: "make", ascending: false)
            let modelSort = NSSortDescriptor(key: "model", ascending: false)
            request.sortDescriptors = [yearSort, makeSort, modelSort]
            self.vehicles = try context.fetch(request)
        } catch {
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //add contents to table view cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as! VehicleCell

        cell.vehicleInfoLabel.text = "\(vehicles[indexPath.row].year) \(vehicles[indexPath.row].make ?? "") \(vehicles[indexPath.row].model ?? "") "
        
        cell.additionalInfoLabel.text = "\(vehicles[indexPath.row].type ?? "")"
        
        //set image to saved image or default
        cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.bounds.height/2
        if let url = URL(string: vehicles[indexPath.row].imagePath ?? ""){
            if let imageData = NSData(contentsOf: url){
                cell.thumbnailImage.image = UIImage(data: imageData as Data)
            } else {
                cell.thumbnailImage.image = UIImage(named: self.vehicles[indexPath.row].type!.lowercased())
                cell.thumbnailImage.tintColor = .lightGray
            }
        } else {
            cell.thumbnailImage.image = UIImage(named: (self.vehicles[indexPath.row].type ?? "").lowercased())
            cell.thumbnailImage.tintColor = .lightGray
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    //add action to edit on right swipe
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            self.editVehicle(atIndex: indexPath.row)
            completionHandler(true)
        }
        editAction.backgroundColor = .green
        let config = UISwipeActionsConfiguration(actions: [editAction])
        return config
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            self.deleteVehicle(atIndex: indexPath.row)
            completionHandler(true)
        }
        //deleteAction.backgroundColor = .green
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
}



extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(addVehicleAC.textFields != nil && addVehicleAC.textFields?.count ?? 0 >= 4){
            addVehicleAC.textFields?[3].text = types[row]
        }
        if(editVehicleInfoAC.textFields != nil && editVehicleInfoAC.textFields?.count ?? 0 >= 4){
            editVehicleInfoAC.textFields?[3].text = types[row]
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        //save path vehicle and refresh table view
        picker.dismiss(animated: true, completion: {
            self.vehicles[self.editingIndex].imagePath = imagePath.absoluteString
            do{
                try self.context.save()
            } catch{
                
            }
            self.fetchVehicles()
        })
   }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


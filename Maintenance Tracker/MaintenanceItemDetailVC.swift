//
//  MaintenanceItemDetailVC.swift
//  Maintenance Tracker
//
//  Created by Graham Nelson on 9/27/20.
//  Copyright © 2020 Graham Nelson. All rights reserved.
//

import UIKit
import CoreData

class MaintenanceItemDetailVC: UIViewController {

    //@IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemMileage: UILabel!
    @IBOutlet var itemDate: UILabel!
    @IBOutlet var itemDescription: UITextView!
    @IBOutlet var vehicleImageView: UIImageView!
    @IBOutlet var vehicleLabel: UILabel!
    
    
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    var maintenanceItem : MaintenanceItem?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO handle nil maintenanceItem
        if maintenanceItem == nil {
            _ = navigationController?.popViewController(animated: true)
        }
        
        initializeLabels()
        fillVehicleData()
    }
    
    func fillVehicleData(){
        //fill the name of the vehicle and get the associated image
        if let vehicle = maintenanceItem!.performedOn{
            vehicleLabel.text = "\(vehicle.year) \(vehicle.make ?? "") \(vehicle.model ?? "")"
            
            //get image for vehicle or default based on type
            vehicleImageView.layer.cornerRadius = vehicleImageView.bounds.height/2
            vehicleImageView.backgroundColor = .white
            vehicleImageView.layer.borderWidth = 1
            vehicleImageView.layer.borderColor = UIColor.lightGray.cgColor
            if let url = URL(string: vehicle.imagePath ?? ""){
                if let imageData = NSData(contentsOf: url){
                    //User has assigned custom image to vehicle
                    vehicleImageView.image = UIImage(data: imageData as Data)
                } else {
                    //get default image based on vehicle type
                    vehicleImageView.image = UIImage(named: vehicle.type!.lowercased())
                    vehicleImageView.tintColor = .lightGray
                }
            } else {
                vehicleImageView.image = UIImage(named: (vehicle.type ?? "").lowercased())
                vehicleImageView.tintColor = .lightGray
            }
        } else {
            vehicleLabel.text = ""
        }
    }
    
    func initializeLabels(){
        itemDescription.delegate = self
        //get the date and format it
        dateFormatter.dateFormat = "MM-dd-yyyy"
        numberFormatter.numberStyle = .decimal
        var itemDateString : String
        if let itemDate = maintenanceItem!.date {
            itemDateString = dateFormatter.string(from: itemDate)
        } else {
            itemDateString = ""
        }
        
        title = maintenanceItem!.title ?? ""
        //format milage with commas
        itemMileage.text = "Mileage: \(numberFormatter.string(from: NSNumber(value: maintenanceItem!.mileage)) ?? "")"
        itemDate.text = "Date: \(itemDateString)"
        
        //dismiss the keyboard when user taps outside of textView
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)
        //style the description text view
        itemDescription.autocapitalizationType = .sentences
        itemDescription.text = maintenanceItem!.desc ?? ""
        itemDescription.layer.cornerRadius = 15
        itemDescription.layer.borderWidth = 1
        itemDescription.layer.borderColor = UIColor.lightGray.cgColor
        
        itemDescription.layer.masksToBounds = false
        itemDescription.layer.shadowColor = UIColor.lightGray.cgColor
        itemDescription.layer.shadowOpacity = 1
        itemDescription.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        itemDescription.layer.shadowRadius = 5
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

extension MaintenanceItemDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        maintenanceItem?.desc = itemDescription.text
        do{
            try self.context.save()
        } catch{}
    }
}

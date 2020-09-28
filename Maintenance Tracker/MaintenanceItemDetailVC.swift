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

    @IBOutlet var itemTitle: UILabel!
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
        if let vehicle = maintenanceItem!.performedOn{
            vehicleLabel.text = "\(vehicle.year) \(vehicle.make ?? "") \(vehicle.model ?? "")"
            
            //get image for vehicle or default based on type
            vehicleImageView.layer.cornerRadius = vehicleImageView.bounds.height/2
            vehicleImageView.backgroundColor = .white
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
        dateFormatter.dateFormat = "MM-dd-yyyy"
        numberFormatter.numberStyle = .decimal
        var itemDateString : String
        if let itemDate = maintenanceItem!.date {
            itemDateString = dateFormatter.string(from: itemDate)
        } else {
            itemDateString = ""
        }
        
        itemTitle.text = maintenanceItem!.title ?? ""
        //format milage with commas
        itemMileage.text = "Mileage: \(numberFormatter.string(from: NSNumber(value: maintenanceItem!.mileage)) ?? "")"
        itemDate.text = "Date: \(itemDateString)"
        itemDescription.text = maintenanceItem!.desc ?? ""
        itemDescription.layer.cornerRadius = 15
        //itemDescription.backgroundColor = .lightGray
        itemDescription.layer.borderWidth = 1
        itemDescription.layer.borderColor = UIColor.lightGray.cgColor
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

extension MaintenanceItemDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        maintenanceItem?.desc = itemDescription.text
        do{
            try self.context.save()
        } catch{}
    }
}

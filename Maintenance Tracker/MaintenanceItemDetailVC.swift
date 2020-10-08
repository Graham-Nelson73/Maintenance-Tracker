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

        //If maintenance item is nil, return to previous view in navigation stack
        if maintenanceItem == nil {
            _ = navigationController?.popViewController(animated: true)
        }
        
        initializeLabels()
        fillVehicleData()
        
        //add listeners for changes in keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit{
        //remove listeners
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func fillVehicleData(){
        //fill the name of the vehicle and get the associated image
        if let vehicle = maintenanceItem!.performedOn{
            vehicleLabel.text = "\(vehicle.year) \(vehicle.make ?? "") \(vehicle.model ?? "")"
            
            //get image for vehicle or default based on type
            vehicleImageView.layer.cornerRadius = vehicleImageView.bounds.height/2
            vehicleImageView.backgroundColor = .white
            vehicleImageView.layer.borderWidth = 1
            if traitCollection.userInterfaceStyle == .light{
                vehicleImageView.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                vehicleImageView.layer.borderColor = UIColor.darkGray.cgColor
            }
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
        
        itemDescription.layer.masksToBounds = false
        if traitCollection.userInterfaceStyle == .light{
            itemDescription.layer.shadowColor = UIColor.lightGray.cgColor
            itemDescription.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            itemDescription.layer.shadowColor = UIColor.darkGray.cgColor
            itemDescription.layer.borderColor = UIColor.darkGray.cgColor
        }
        itemDescription.layer.shadowOpacity = 1
        itemDescription.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        itemDescription.layer.shadowRadius = 5
    }
    
    //shift view when keyboard appears to make textView more visible
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        //offset so that keyboard will come up to bottom of textView
        let textViewBottomEdgeOffset = view.frame.height - (itemDescription.frame.minY + itemDescription.frame.height + 10)
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -(keyboardSize.height - textViewBottomEdgeOffset )
        } else {
            view.frame.origin.y = 0
        }
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

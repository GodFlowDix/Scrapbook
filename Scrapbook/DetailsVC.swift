//
//  DetailsVC.swift
//  Scrapbook
//
//  Created by Mike Dix on 1/3/20.
//  Copyright © 2020 Mike Dix. All rights reserved.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentsText: UITextField!
    @IBOutlet weak var placeText: UITextField!
    @IBOutlet weak var monthText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenScrap = ""
    var chosenScrapId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenScrap != "" {
            
            saveButton.isHidden = true
            
            //core data
            //needed to filter results
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Scraps")
            let idString = chosenScrapId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
              let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let comment = result.value(forKey: "comment") as? String {
                            commentsText.text = comment
                        }
                        if let place = result.value(forKey: "place") as? String {
                            placeText.text = place
                        }
                        if let month = result.value(forKey: "month") as? Int {
                            monthText.text = String(month)
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                
            }
            
//            let stringUUID = chosenScrapId!.uuidString
//
//            print(stringUUID)
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            placeText.text = ""
            yearText.text = ""
            monthText.text = ""
            commentsText.text = ""
        }
        
//        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonTapped))

        //hides keyboard on tap anywhere 
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        //makes the image view tappable by users
        imageView.isUserInteractionEnabled = true
        
        //gesture recognizer for tap on image
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
   
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage  //user might not picak a image
        saveButton.isEnabled = true //save button only clickable if user selects an image
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func saveButtonTapped() {
        
    }

  
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        //returns the singleton (only) instance of the app
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newScrap = NSEntityDescription.insertNewObject(forEntityName: "Scraps", into: context)
        
        //Attributes
        
        newScrap.setValue(nameText.text!, forKey: "name")
        newScrap.setValue(commentsText.text!, forKey: "comment")
        newScrap.setValue(placeText.text!, forKey: "place")
        
        if let year = Int(yearText.text!) {
            newScrap.setValue(year, forKey: "year")
        }
        
        if let month = Int(monthText.text!) {
            newScrap.setValue(month, forKey: "month")
        }
        
        newScrap.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.6)
        
        newScrap.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        //sends message to whole app
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        //take us back to original view controller
        self.navigationController?.popViewController(animated: true)
    }
    
}

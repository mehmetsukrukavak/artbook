//
//  DetailsViewController.swift
//  ArtBook
//
//  Created by Mehmet Sukru Kavak on 13.03.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting : String = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            //CoreData'dan veri
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate (format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if  let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                            nameTextField.isEnabled = false
                        }
                        
                        if  let artist = result.value(forKey: "artist") as? String {
                            artistTextField.text = artist
                            artistTextField.isEnabled = false
                        }
                        
                        if  let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = String(year)
                            yearTextField.isEnabled = false
                        }
                        
                        if  let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            
                            imageView.image = image
                        }
                        
                    }
                }
            }catch{
                print("Error")
            }
        }
        else{
            saveButton.isHidden = true
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            
            view.addGestureRecognizer(gestureRecognizer)
            imageView.isUserInteractionEnabled = true
            
            let imageTapecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            imageView.addGestureRecognizer(imageTapecognizer)
            
        }
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isHidden = false
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        
        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success")
        } catch{
            print("Error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

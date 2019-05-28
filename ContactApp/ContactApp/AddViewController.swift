//
//  AddViewController.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController,UIImagePickerControllerDelegate {

    var managedObjectContext : NSManagedObjectContext!
   // let imagePicker = UIImagePickerController()
    
    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingViewController: self)
        manager.delegate = self as? PhotoPickerManagerDelegate
        return manager
    }()
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var streetLabel: UITextField!
    @IBOutlet weak var cityLabel: UITextField!
    @IBOutlet weak var stateLabel: UITextField!
    @IBOutlet weak var zipLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       // imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    @IBAction func save(_ sender: Any) {
        let firstname = firstNameLabel.text
        let lastname = lastNameLabel.text
        let phone = phoneNumberLabel.text
        let emaila = emailLabel.text
        let streeta = streetLabel.text
        let citya = cityLabel.text
        let statea = stateLabel.text
        let zipa = zipLabel.text
        
        print("Coming till Here")
        
        
//        let contact = NSEntityDescription.insertNewObject(forEntityName: "ContactDBC", into: managedObjectContext) as! ContactDBC
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactDBC", in: managedContext)
        let contact = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        
        contact.setValue(firstname, forKey: "firstName")
        contact.setValue(lastname, forKey: "lastName")
        contact.setValue(phone, forKey: "phoneNumber")
        contact.setValue(emaila, forKey: "email")
        contact.setValue(streeta, forKey: "streetAddress")
        contact.setValue(citya, forKey: "city")
        contact.setValue(statea, forKey: "state")
        contact.setValue(zipa, forKey: "zip")
        
        print(contact)
        
//        contact.firstName = firstname
//        contact.lastName = lastname
//        contact.phoneNumber = phone
//        contact.email = emaila
//        contact.streetAddress = streeta
//        contact.city = citya
//        contact.state = statea
//        contact.zip = zipa
        managedContext.saveChanges()
        dismiss(animated: true, completion: nil)
    }
   
    @IBAction func addImage(_ sender: Any) {
         photoPickerManager.presentPhotoPicker(animated: true)
        
        
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//
//
//        /*
//         The sourceType property wants a value of the enum named        UIImagePickerControllerSourceType, which gives 3 options:
//
//         UIImagePickerControllerSourceType.PhotoLibrary
//         UIImagePickerControllerSourceType.Camera
//         UIImagePickerControllerSourceType.SavedPhotosAlbum
//
//         */
//        present(imagePicker, animated: true, completion: nil)

    }
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            myImage.contentMode = .scaleAspectFit
//            myImage.image = pickedImage
//        }
//
//
//        /*
//
//         Swift Dictionary named “info”.
//         We have to unpack it from there with a key asking for what media information we want.
//         We just want the image, so that is what we ask for.  For reference, the available options are:
//
//         UIImagePickerControllerMediaType
//         UIImagePickerControllerOriginalImage
//         UIImagePickerControllerEditedImage
//         UIImagePickerControllerCropRect
//         UIImagePickerControllerMediaURL
//         UIImagePickerControllerReferenceURL
//         UIImagePickerControllerMediaMetadata
//
//         */
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion:nil)
//    }
    

}
extension AddViewController: PhotoPickerManagerDelegate {
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        manager.dismissPhotoPicker(animated: true, completion: nil)
//        let _ = Photo.with(image, in: context)
//        context.saveChanges()
//        manager.dismissPhotoPicker(animated: true, completion:
//            nil)
    }
}


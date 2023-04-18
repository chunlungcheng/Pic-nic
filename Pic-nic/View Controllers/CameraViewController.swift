//
//  CameraViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 3/5/23.
//

import UIKit
import FirebaseFirestore
import Firebase

class CameraViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoTaken: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    
    var hasTaken = false
    let db = Firestore.firestore()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let alertController = UIAlertController(title: "Camera unavailable", message: "Device is overheating or device is simulator", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let camRoll = UIAlertAction(title: "Choose from library", style: .default) { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            }
            
            alertController.addAction(camRoll)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
            
        } else if !hasTaken {
            hasTaken = true
            self.imagePicker.sourceType = .camera
            present(self.imagePicker, animated: true)
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn{
            locationLabel.textColor = .black
        }else{
            locationLabel.textColor = .lightGray
        }
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let image = photoTaken.image else {return}
        uploadImage(image: image)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        photoTaken.image = image
        postButton.isEnabled = true
        
    }
    
    func uploadImage(image: UIImage) {
        freezeUI()
        
        // Scale the image dimensions
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: image.size.width / 3, height: image.size.height / 3)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let scaledImage = scaledImage, let imageData = scaledImage.jpegData(compressionQuality: 0.0) else {
            unfreezeUI()
            presentErrorMessage(title: "Unable to scale image", message: "Unable to scale down image. Please try a different one")
            return
        }
        
        let location = GeoPoint(latitude: 30.2672, longitude: -97.7431) // TODO: Unhardcode from Austin
        
        let documentData: [String: Any] = [
            "imageData": imageData,
            "date": Timestamp(),
            "userID": Firebase.Auth.auth().currentUser?.uid ?? "nil",
            "location": locationSwitch.isOn ? location : "nil",
            "likeBy": [String]()
        ]
        
        db.collection("locations").document("Austin").collection("posts").addDocument(data: documentData) { error in
            self.unfreezeUI()
            
            if let error = error {
                print("Error adding document: \(error)")
                self.presentErrorMessage(title: "Unable to post", message: error.localizedDescription)
                
            } else {
                print("Document added")
                self.dismiss(animated: true)
            }
        }
    }
    
    func freezeUI() {
        spinner.startAnimating()
        self.postButton.isHidden = true
        self.locationSwitch.isEnabled = false
    }
    
    func unfreezeUI() {
        spinner.stopAnimating()
        self.postButton.isHidden = false
        self.locationSwitch.isEnabled = true
    }
    
    func presentErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}

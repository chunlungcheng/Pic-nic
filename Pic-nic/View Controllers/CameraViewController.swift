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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else if !hasTaken{
            hasTaken = true
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            camera.delegate = self
            present(camera, animated: true)
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        photoTaken.image = image
        postButton.isEnabled = true
        
    }
    
    func uploadImage(image: UIImage) {
        spinner.startAnimating()
        self.postButton.isHidden = true
        guard let imageData = image.jpegData(compressionQuality: 0.0) else { return }
        let location = GeoPoint(latitude: 30.2672, longitude: -97.7431)
        
        let documentData: [String: Any] = [
            "imageData": imageData,
            "date": Timestamp(),
            "userID": Firebase.Auth.auth().currentUser?.uid ?? "nil"
        ]
        
        db.collection("locations").document("Austin").collection("posts").addDocument(data: documentData) { error in
            self.spinner.stopAnimating()
            self.postButton.isHidden = false
            if let error = error {
                print("Error adding document: \(error)")
                self.presentErrorMessage(title: "Unable to post", message: error.localizedDescription)
                
            } else {
                print("Document added")
                self.dismiss(animated: true)
            }
        }
    }
    
    func presentErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}

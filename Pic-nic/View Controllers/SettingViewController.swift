//
//  SettingViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 4/3/23.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    let signOutSegueID = "signOutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To make the profile pic circular
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.isUserInteractionEnabled = true
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            let docRef = db.collection("users").document(userID)
            docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                // Handle the user data here
                self.firstnameTextField.placeholder = data["firstName"] as? String ?? ""
                self.lastnameTextField.placeholder = data["lastName"] as? String ?? ""
            }
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    // Handle the user data here
                    self.emailTextField.placeholder = data?["userId"] as? String ?? ""
                    let imageEncode = data?["profilePicture"] as? String ?? ""
                    if let imageData = Data(base64Encoded: imageEncode, options: .ignoreUnknownCharacters) {
                        // Create an image from the data
                        let image = UIImage(data: imageData)
                        // Use the image as needed
                        self.profilePic.image = image
                    } else {
                        print("Invalid base64 string")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            print("User not logged in")
        }
    }
    
    @IBAction func recognizeTapGesture(recognizer: UITapGestureRecognizer)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true // Enable editing
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Return back to Home screen
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    
    // Sign out and return back to Login screen
    @IBAction func signoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: signOutSegueID, sender: nil)
        } catch {
            print("Sign out error")
        }
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePic.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
}


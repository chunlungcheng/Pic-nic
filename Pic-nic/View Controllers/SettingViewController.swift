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
    var profileChanged = false
    var isInformationUpdated = false // Add a flag variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To make the profile pic circular
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        profilePic.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = false
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
                    self.emailTextField.placeholder = data?["email"] as? String ?? ""
                    if let imageData = data?["profilePicture"] as? Data {
                        if imageData.count != 0 {
                            // Create an image from the data
                            let image = UIImage(data: imageData)
                            let resizedImage = image!.resizeImage(targetSize: CGSize(width: 300, height: 300))
                            // Use the image as needed
                            self.profilePic.image = resizedImage
                        }
                    } else {
                        print("Invalid image")
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
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userID = user.uid
            let docRef = db.collection("users").document(userID)
            var isInformationUpdated = false // Add a flag variable
            let dispatchGroup = DispatchGroup() // Create a DispatchGroup
            
            if !firstnameTextField.text!.isEmpty{
                dispatchGroup.enter() // Enter the DispatchGroup
                docRef.updateData([
                    "firstName": firstnameTextField.text!
                ]) { err in
                    if let err = err {
                        let controller = UIAlertController(title:"Error", message: "\(err.localizedDescription)", preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(controller, animated: true)
                    } else {
                        isInformationUpdated = true // Set the flag to true
                    }
                    dispatchGroup.leave() // Leave the DispatchGroup
                }
            }
            
            if !lastnameTextField.text!.isEmpty{
                dispatchGroup.enter() // Enter the DispatchGroup
                docRef.updateData([
                    "lastName": lastnameTextField.text!
                ]) { err in
                    if let err = err {
                        let controller = UIAlertController(title:"Error", message: "\(err.localizedDescription)", preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(controller, animated: true)
                    } else {
                        isInformationUpdated = true // Set the flag to true
                    }
                    dispatchGroup.leave() // Leave the DispatchGroup
                }
            }
            
            if profileChanged{
                var imageData:Data!
                if let image = self.profilePic.image{
                    imageData = image.jpegData(compressionQuality: 0.1)
                    dispatchGroup.enter() // Enter the DispatchGroup
                    docRef.updateData([
                        "profilePicture": imageData!
                    ]) { err in
                        if let err = err {
                            let controller = UIAlertController(title:"Error", message: "\(err.localizedDescription)", preferredStyle: .alert)
                            controller.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(controller, animated: true)
                        }else{
                            isInformationUpdated = true // Set the flag to true
                        }
                        dispatchGroup.leave() // Leave the DispatchGroup
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { // Show success alert controller after all updates have completed
                if isInformationUpdated { // Show success alert controller only if the flag is true
                    NotificationCenter.default.post(name: Notification.Name.updateTableView, object: "")
                    let controller = UIAlertController(title:"Successfully Updated", message: "User information successfully updated", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        if !self.firstnameTextField.text!.isEmpty{
                            self.firstnameTextField.placeholder = self.firstnameTextField.text!
                            self.firstnameTextField.text = ""
                        }
                        if !self.lastnameTextField.text!.isEmpty{
                            self.lastnameTextField.placeholder = self.lastnameTextField.text!
                            self.lastnameTextField.text = ""
                        }
                    }
                    controller.addAction(okAction)
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Sign out and return back to Login screen
    @IBAction func signoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch {
            print("Sign out error")
        }
    }
    
    // Delete user account and related information from Firestore
    @IBAction func deleteButtonPressed(_ sender: Any) {
           let user = Auth.auth().currentUser
           let userID = user?.uid

           let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)

           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)

           let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
               // Delete user's data in Firestore
               let db = Firestore.firestore()
               let docRef = db.collection("users").document(userID!)
               let postCollection = db.collection("locations").document("Austin").collection("posts")
               docRef.delete { error in
                   if let error = error {
                       print("Error deleting user data:", error.localizedDescription)
                       let errorAlert = UIAlertController(title: "Error", message: "Failed to delete user data. Please try again later.", preferredStyle: .alert)
                       errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(errorAlert, animated: true, completion: nil)
                   } else {
                       print("User data deleted successfully.")
                   }
               }
               // Delete user's account in Firebase Auth
               user?.delete { error in
                   if let error = error {
                       print("Error deleting user account:", error.localizedDescription)
                       let errorAlert = UIAlertController(title: "Error", message: "Failed to delete user account. Please try again later.", preferredStyle: .alert)
                       errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(errorAlert, animated: true, completion: nil)
                   } else {
                       print("User account deleted successfully.")
                       self.performSegue(withIdentifier: "signOutSegue", sender: nil)
                   }
               }
               postCollection.getDocuments { (snapshot, error) in
                   if let error = error {
                       print("Error fetching documents: \(error)")
                       return
                   }
                   guard let documents = snapshot?.documents else { return }
                   
                   for document in documents {
                       let data = document.data()
                       let postUserID = data["userID"] as? String ?? ""
                       let documentID = document.documentID
                       if postUserID == userID{
                           postCollection.document(documentID).delete { error in
                               if let error = error {
                                   print("Error deleting user data:", error.localizedDescription)
                               }
                           }
                       }
                   }
               }
           }
           alertController.addAction(deleteAction)
           present(alertController, animated: true, completion: nil)
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
            profileChanged = true
        }
        self.dismiss(animated: true, completion: nil)
    }
}



//
//  SignUpViewController.swift
//  Pic-nic
//
//  Created by Arjun Hegde on 3/6/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var SignUpFirstNameTextField: UITextField!
    @IBOutlet weak var SignUpLastNameTextField: UITextField!
    @IBOutlet weak var SignUpConfirmPasswordTextField: UITextField!
    @IBOutlet weak var SignUpPasswordTextField: UITextField!
    @IBOutlet weak var SignUpEmailTextField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ConfirmSignUp(_ sender: Any) {
        guard let email = SignUpEmailTextField.text else { return }
        guard let password = SignUpPasswordTextField.text else { return }
        guard let confirmPassword = SignUpConfirmPasswordTextField.text else { return }
        let matchingPasswords = (password == confirmPassword)

        if(matchingPasswords && SignUpFirstNameTextField.text != nil && SignUpLastNameTextField.text != nil){
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(email)
                    print(password)
                    print(confirmPassword)
                    print("Error")
                }
                else{
                    print("Success")
                    let profilePictureImage = self.profilePictureButton.currentImage!
                    var imageData: Data
                    if profilePictureImage.pngData() != nil {
                        imageData = profilePictureImage.pngData()!
                    } else {
                        imageData = profilePictureImage.jpegData(compressionQuality: 1.0)!
                    }
                    let profilePictureEncoded = imageData.base64EncodedString()
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(authResult!.user.uid)
                    let data: [String: Any] = [
                        "firstName": self.SignUpFirstNameTextField.text!,
                        "lastName": self.SignUpLastNameTextField.text!,
                        "profilePicture": profilePictureEncoded,
                        "signupDate": Timestamp(date: Date()),
                        "userId": authResult!.user.uid
                    ]
                    userRef.setData(data)
                    self.dismiss(animated: true)
                    NotificationCenter.default.post(name: Notification.Name.updateTableView, object: "")
                }
            }
        }
    }
   
    @IBAction func profilePictureSelector(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true // Enable editing
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set the button's image to the selected image
            profilePictureButton.setImage(selectedImage, for: .normal)
            // Make the button circular
            profilePictureButton.layer.cornerRadius = min(profilePictureButton.frame.size.width, profilePictureButton.frame.size.height) / 2
            profilePictureButton.clipsToBounds = true
        }
        self.dismiss(animated: true, completion: nil)
    }
}

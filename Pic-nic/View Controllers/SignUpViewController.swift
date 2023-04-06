//
//  SignUpViewController.swift
//  Pic-nic
//
//  Created by Arjun Hegde on 3/6/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController {
    
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

        if(matchingPasswords){
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(email)
                    print(password)
                    print(confirmPassword)
                    print("Error")
                }
                else{
                    print("Success")
                    self.dismiss(animated: true)
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

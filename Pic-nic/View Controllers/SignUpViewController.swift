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
        SignUpPasswordTextField.isSecureTextEntry = true
        SignUpConfirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func ConfirmSignUp(_ sender: Any) {
        let email = SignUpEmailTextField.text
        let password = SignUpPasswordTextField.text
        let confirmPassword = SignUpConfirmPasswordTextField.text
        let firstname = SignUpFirstNameTextField.text
        let lastname = SignUpLastNameTextField.text
        if email == "" || password == "" {
            let controller = UIAlertController(title:"Error", message: "Invalid username or password", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller, animated: true)
            return
        }
        
        if firstname == "" || lastname == "" {
            let controller = UIAlertController(title:"Error", message: "Please enter firstname and lastname", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller, animated: true)
            return
        }
        
        if password != confirmPassword{
            let controller = UIAlertController(title:"Error", message: "confirm password do not match", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller, animated: true)
            return
        }
        
        Auth.auth().createUser(withEmail: email!, password: password!) {
            authResult, error in
            if let error = error as NSError? {
                let controller = UIAlertController(title:"Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            } else {
                let db = Firestore.firestore()
                let usersCollection = db.collection("users")
                let userDocRef = usersCollection.document(authResult!.user.uid)
                var imageData:Data!
                if let image = self.profilePictureButton.currentImage{
                    imageData = image.jpegData(compressionQuality: 0.1)
                }
                let userData: [String: Any] = [
                    "firstName": firstname!,
                    "lastName": lastname!,
                    "email": email!,
                    "profilePicture": imageData ?? Data(),
                    "signupDate": Timestamp(date: Date()),
                ]
                userDocRef.setData(userData) { error in
                    if let error = error {
                        print("Error adding user document: \(error)")
                    } else {
                        print("User document added with ID: \(userDocRef.documentID)")
                    }
                }
                let controller = UIAlertController(title:"Singup Successfully", message: "You have been signed up!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(okAction)
                self.present(controller, animated: true)
                NotificationCenter.default.post(name: Notification.Name.updateTableView, object: "")
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
            let resizedImage = selectedImage.resizeImage(targetSize: CGSize(width: 300, height: 300))
            profilePictureButton.setTitle("", for: .normal)
            // Set the button's image to the selected image
            profilePictureButton.setImage(resizedImage, for: .normal)
            // Make the button circular
            profilePictureButton.layer.cornerRadius = min(profilePictureButton.frame.size.width, profilePictureButton.frame.size.height) / 2
            profilePictureButton.clipsToBounds = true
            profilePictureButton.imageView?.contentMode = .scaleAspectFill
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

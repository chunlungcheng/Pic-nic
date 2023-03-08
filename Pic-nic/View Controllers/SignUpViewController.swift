//
//  SignUpViewController.swift
//  Pic-nic
//
//  Created by Arjun Hegde on 3/6/23.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var SignUpConfirmPasswordTextField: UITextField!
    @IBOutlet weak var SignUpPasswordTextField: UITextField!
    @IBOutlet weak var SignUpEmailTextField: UITextField!
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
                }
            }
        }
    }
}

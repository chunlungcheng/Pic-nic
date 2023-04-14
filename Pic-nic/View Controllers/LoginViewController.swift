//
//  LoginViewController.swift
//  Pic-nic
//
//  Created by Arjun Hegde on 3/6/23.
//

import UIKit
import Firebase

protocol LoginViewControllerDelegate: AnyObject {
    func loginViewControllerLoggedInSuccessfully(loginViewController: UIViewController?)
}

class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"
    
    @IBOutlet weak var LogInEmailTextField: UITextField!
    @IBOutlet weak var LogInPasswordTextField: UITextField!
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func LogInButton(_ sender: UIButton) {
        guard let email = LogInEmailTextField.text else {return}
        guard let password = LogInPasswordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){authResult, error in
            if let err = error {
                print(email)
                print(password)
                print("Error")
            }
            else{
                print("Success")
                self.delegate?.loginViewControllerLoggedInSuccessfully(loginViewController: self)
                NotificationCenter.default.post(name: Notification.Name.updateTableView, object: "")
            }
        }
    }
}

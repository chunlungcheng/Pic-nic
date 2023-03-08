//
//  CameraViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 3/5/23.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoTaken: UIImageView!
    var hasTaken = false
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
//        _ = navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
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
    }
}

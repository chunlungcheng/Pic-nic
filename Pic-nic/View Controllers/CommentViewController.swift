//
//  CommentViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 3/7/23.
//

import UIKit
import Firebase
import FirebaseAuth

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var commentTextFiled: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let cellIdentifier = "CommentCell"
    var commentList = [String]()
    var postBy = [String]()
    var postID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData()
        tableView.delegate = self
        tableView.dataSource = self
        commentTextFiled.placeholder = "Add a comment"
        tableView.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! CommentCell
        let row = indexPath.row
        let docRef = db.collection("users").document(postBy[row])
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // Handle the user data here
                let firstname = data?["firstName"] as? String ?? ""
                let lastname = data?["lastName"] as? String ?? ""
                cell.nameLabel.text = firstname + " " + lastname
                if let imageData = data?["profilePicture"] as? Data {
                    if imageData.count != 0 {
                        // Create an image from the data
                        let image = UIImage(data: imageData)
                        let resizedImage = image!.resizeImage(targetSize: CGSize(width: 20, height: 20))
                        // Use the image as needed
                        cell.profilePic.image = resizedImage
                        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
                        cell.profilePic.clipsToBounds = true
                        cell.profilePic.contentMode = .scaleAspectFill
                    }
                } else {
                    print("Invalid image")
                }
            } else {
                print("Document does not exist")
            }
        }
        cell.commentLabel.text = commentList[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func downloadData(){
        let postsRef = db.collection("locations").document("Austin").collection("posts").document(postID)
        postsRef.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // set name
                self.commentList = data?["comment"] as? [String] ?? [String]()
                self.postBy = data?["postBy"] as? [String] ?? [String]()
                self.tableView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let input = commentTextFiled.text{
            commentList.append(input)
            postBy.append(Auth.auth().currentUser!.uid)
            let postRef = db.collection("locations").document("Austin").collection("posts").document(postID!)
            postRef.updateData([
                "comment": commentList,
                "postBy": postBy
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            commentTextFiled.text = ""
            tableView.reloadData()
        }
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

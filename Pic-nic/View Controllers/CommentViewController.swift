//
//  CommentViewController.swift
//  Pic-nic
//
//  Created by Chun-Lung Cheng on 3/7/23.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var commentTextFiled: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "CommentCell"
    var commentList = ["default1", "default2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        commentTextFiled.placeholder = "Add a comment"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = commentList[row]
        return cell
    }
    

    @IBAction func postButtonPressed(_ sender: Any) {
        if let input = commentTextFiled.text{
            commentList.append(input)
            commentTextFiled.text = ""
            tableView.reloadData()
        }
    }
}

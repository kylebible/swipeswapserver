//
//  MyMatchesTableViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 6/1/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class MyMatchesTableViewController: UITableViewController {

    let restURL = "http://kbible.pythonanywhere.com/"
    let user = UserDefaults.standard
    var items: [Dictionary<String,Any>]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.tabBarItem.badgeColor = UIColor.black
        self.tabBarItem.image?.accessibilityFrame = CGRect(x: 0, y: 0, width: 10, height: 10)
    }
    
    func loadData() {
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let myItems = items {
            return myItems.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myStuffCell", for: indexPath) as! CustomMatchCell
        if let myItems = items  {
            let item_wanted = myItems[indexPath.row]["item_wanted"] as! [String: Any]
            let item_giving = myItems[indexPath.row]["item_giving"] as! [String: Any]
            cell.leftLabel.text = item_wanted["item_name"] as! String
            cell.rightLabel.text = item_giving["item_name"] as! String
            cell.leftImage.sd_setImage(with: URL(string: item_wanted["image_URL"] as! String))
            cell.rightImage.sd_setImage(with: URL(string: item_giving["image_URL"] as! String))
            return cell
        }
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addItem", sender: sender)
    }
    
    
    
    func getData() {
        let currUser = user.integer(forKey: "id")
        Alamofire.request(restURL+"itemrelationships/?item_wanted__owner=\(currUser)&item_giving__owner=\(currUser)", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            self.items = (json["results"] as! [Dictionary<String,Any>])
            print(self.items)
            self.tableView.reloadData()
        }
    }
    

}

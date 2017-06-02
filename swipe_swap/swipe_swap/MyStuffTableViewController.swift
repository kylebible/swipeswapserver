//
//  MyStuffTableViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class MyStuffTableViewController: UITableViewController, AddItemDelegate {
    
    let restURL = "http://kbible.pythonanywhere.com/"
    let user = UserDefaults.standard
    var items: [Dictionary<String,Any>]?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "myStuffCell", for: indexPath) as! CustomCell
        if let myItems = items  {
        cell.cellTitle.text = myItems[indexPath.row]["item_name"] as! String
        cell.cellImage.sd_setImage(with: URL(string: myItems[indexPath.row]["image_URL"] as! String))
        return cell
        }
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addItem", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let controller = nav.topViewController as! AddItemViewController
        controller.delegate = self
    }

    func cancelButtonPressed(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)

    }
    
    func addItemButtonPressed(by controller: UIViewController, data: [String]) {
        //add data to server
        dismiss(animated: true, completion: nil)
        let myData = [
        "item_name": data[0],
        "item_detail": data[1],
        "item_value": data[2],
        "image_URL": data[3],
        "owner": user.integer(forKey: "id")
        ] as [String : Any]
        postNewItem(data: myData)
        getData()
        
    }
    
    func postNewItem(data: [String: Any]) {
        Alamofire.request(self.restURL+"items/", method: .post, parameters: data, encoding: JSONEncoding(options:[])).responseJSON { response in
            let results = response.result.value as! [String : Any]
            print(results)
        }
    }
    
    func getData() {
        Alamofire.request(restURL+"items/?owner=\(user.integer(forKey: "id"))", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            self.items = (json["results"] as! [Dictionary<String,Any>])
            self.tableView.reloadData()
            print(self.items)
        }
    }

}

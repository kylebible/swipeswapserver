//
//  TradeForTableViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class TradeForTableViewController: UITableViewController {
    
    let restURL = "http://kbible.pythonanywhere.com/"
    let user = UserDefaults.standard
    var items: [Dictionary<String,Any>]?
    var delegate: TradeDelegate?
    var sender_item: [String: Any]?
    var selectedItems = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            cell.check.isHidden = true
            cell.item_id = myItems[indexPath.row]["id"] as! Int
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomCell
        if cell.check.isHidden == true {
            cell.check.isHidden = false
            cell.backgroundColor = UIColor.blue
            cell.cellTitle.textColor = UIColor.white
            cell.check.tintColor = UIColor.white
            selectedItems.append(cell.item_id)
        }
        else {
            cell.check.isHidden = true
            cell.backgroundColor = UIColor.white
            cell.cellTitle.textColor = UIColor.black
            selectedItems.remove(at: selectedItems.index(of: cell.item_id)!)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.tradeCancelButtonPressed(by: self)
    }
    
    func getData() {
        Alamofire.request(restURL+"items/?owner=\(user.integer(forKey: "id"))", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            self.items = (json["results"] as! [Dictionary<String,Any>])
            self.tableView.reloadData()
        }
    }
    
    func startTrade(item_wanted: Int, item_giving: Int) {
        print("starting trade")
        Alamofire.request(restURL+"itemrelationships/?item_wanted=\(item_wanted)&item_giving=\(item_giving)", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            if json["count"] as! Int == 1 {
                let json_dict = json["results"] as! [Dictionary<String,Any>]
                let rel_id = json_dict[0]["id"] as! Int
                self.makeMatch(relationship_id: rel_id)
            }
            else {
                self.makeRelationship(item_wanted: item_giving, item_giving: item_wanted)
            }
        }
    }
    
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        for i in selectedItems {
            let giving_id = sender_item?["id"] as! Int
            let giving_owner = sender_item?["owner"] as! Int
            print(giving_owner)
            startTrade(item_wanted: i, item_giving: giving_id)
            delegate?.tradeDoneButtonPressed(by: self)
        }
    }
    
    func makeRelationship(item_wanted: Int, item_giving: Int) {
        print("makerelationship")
        let data = [
            "item_wanted": item_wanted,
            "item_giving": item_giving
        ]
        Alamofire.request(self.restURL+"itemrelationships/", method: .post, parameters: data, encoding: JSONEncoding(options:[])).responseJSON { response in
            print(response)
        }
    }
    
    func makeMatch(relationship_id: Int) {
        print("making_match")
        let parameters: [String: Any] = [
            "match_made": "1"
            ]
        let query = restURL + "itemrelationships/\(relationship_id)/"
        Alamofire.request(query, method: .patch, parameters: parameters, encoding: JSONEncoding(options:[])).responseJSON { response in
            print(response)
        }
    }
    

}

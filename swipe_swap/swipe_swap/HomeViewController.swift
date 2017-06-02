//
//  HomeViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController, LoginDelegate, TradeDelegate {
    
    let user = UserDefaults.standard
    var items: [Dictionary<String,Any>]?
    let restURL = "http://kbible.pythonanywhere.com/"
    

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        user.removeObject(forKey: "id")
        performSegue(withIdentifier: "login", sender: sender)
    }
    
    
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func refreshButton(_ sender: Any) {
        getData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        card.isHidden = true
        self.tabBarItem.title = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let userId = user.value(forKey: "id") {
            print(userId)
        }
        else {
            performSegue(withIdentifier: "login", sender: self)
        }
        card.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.6)
        loadData()
    }
    
    func loadData() {
        getData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! LoginViewController
            controller.delegate = self
        }
        else if segue.identifier == "toTrade" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! TradeForTableViewController
            controller.delegate = self
            controller.sender_item = sender as! [String : Any]
        }
    }

    func loginComplete(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tradeCancelButtonPressed(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tradeDoneButtonPressed(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
        getData()
    }
    
    //card animation
   
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardDetail: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + (point.y)/10)
        
        if xFromCenter > 0 {
            thumbImageView.image = #imageLiteral(resourceName: "thumbs_up")
            thumbImageView.tintColor = UIColor.green
        }
        else if xFromCenter < 0 {
            thumbImageView.image = #imageLiteral(resourceName: "thumbs_down")
            thumbImageView.tintColor = UIColor.red
        }
        
        thumbImageView.alpha = abs(xFromCenter / view.center.x)
        
        if sender.state == UIGestureRecognizerState.ended {
            
            if card.center.x < 75 {
                // move to the left side of screen
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                    self.thumbImageView.alpha = 0
                })
                perform(#selector(resetCard), with: self, afterDelay: 0.3)
                return
            }
            else if card.center.x > (view.frame.width - 75) {
                // move to right side of screen
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    self.thumbImageView.alpha = 0
                })
                perform(#selector(resetCard), with: self, afterDelay: 0.3)
                if let myItems = items {
                    performSegue(withIdentifier: "toTrade", sender: myItems[myItems.count-1])
                }
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.card.center = self.view.center
                self.thumbImageView.alpha = 0
            })
            
        }
    }
    
    
    
    func resetCard() {
        let item_id = items![(items?.count)!-1]["id"] as! Int
        let item_viewed_by = items![(items?.count)!-1]["viewed_by"] as! [Int]
        itemViewed(item_id: item_id, users_viewed: item_viewed_by)
        items!.removeLast()
        if items!.count > 0 {
        if let myItems = items {
            cardTitle.text = myItems[myItems.count-1]["item_name"] as! String
            cardDetail.text = myItems[myItems.count-1]["item_detail"] as! String
            cardImage.sd_setImage(with: URL(string: myItems[myItems.count-1]["image_URL"] as! String))
        }
        self.card.center = self.view.center
        
        UIView.animate(withDuration: 0.6, delay: 0.3, animations: {
            self.card.alpha = 1
        })
        }
        else {
            refreshButton.isHidden = false
        }
        
            
    }
    
    //Server Requests
    
    func getData() {
        Alamofire.request(restURL+"items/?viewed_by=\(user.integer(forKey: "id"))&owner_id=\(user.integer(forKey: "id"))", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            self.items = (json["results"] as! [Dictionary<String,Any>])
            print(self.items)
            if (self.items?.count)! > 0 {
                self.refreshButton.isHidden = true
            if let myItems = self.items {
                self.cardTitle.text = (myItems[myItems.count-1]["item_name"] as! String)
                self.cardDetail.text = (myItems[myItems.count-1]["item_detail"] as! String)
                self.cardImage.sd_setImage(with: URL(string: myItems[myItems.count-1]["image_URL"] as! String))
            }
                self.card.isHidden = false
            }
            else {
                print("show button")
                self.refreshButton.isHidden = false
            }
            
        }
    }
    
    func itemViewed(item_id: Int, users_viewed: [Int]) {
        print(users_viewed)
        var myUsers = users_viewed
        myUsers.append(user.integer(forKey: "id"))
        let parameters: [String: Any] = [
            "viewed_by": myUsers,
        ]
        let query = restURL + "items/\(item_id)/"
        Alamofire.request(query, method: .patch, parameters: parameters, encoding: JSONEncoding(options:[])).responseJSON { response in
            print(response)
        }
    }

    
    

}

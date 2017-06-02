//
//  ViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/30/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    var user = UserDefaults.standard
    let restURL = "http://kbible.pythonanywhere.com/"
    let userURL = "http://kbible.pythonanywhere.com/users/"
    var delegate: LoginDelegate?
    
    //outlets
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    //register outlets
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var reg_userName: UITextField!
    @IBOutlet weak var reg_password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let user = userName.text {
            if let pw = password.text {
                getLogin(username: user, pw: pw)
            }
        }
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let fn = firstName.text, let ln = lastName.text, let e = email.text, let un = reg_userName.text, let pw = reg_password.text {
            let data =  [
                "first_name": fn,
                "last_name": ln,
                "email": e,
                "username": un,
                "password": pw
            ]
            checkForUsername(username: un, data: data)
        }
        
    }
    
    func postRegister(data: [String: Any]) {
        Alamofire.request(self.restURL+"users/", method: .post, parameters: data, encoding: JSONEncoding(options:[])).responseJSON { response in
            let results = response.result.value as! [String : Any]
            self.user.set(results["id"] as! Int, forKey: "id")
            self.delegate?.loginComplete(by: self)
        }
    }
    
    func getLogin(username: String, pw: String) {
        print("get")
        Alamofire.request(userURL+"?username=\(username)", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            //if this user exists
            if json["count"] as! Int != 0 {
                let jsonresultsarray = json["results"] as! NSArray
                let myResponse = jsonresultsarray[0] as! NSDictionary
                //check if passwords match
                if pw == myResponse["password"] as! String {
                self.user.set(myResponse["id"] as! Int, forKey: "id")
                self.delegate?.loginComplete(by: self)
                }
                    //alerts
                else {
                    let alert = UIAlertController(title: "Oops!", message: "Username or Password is incorrect. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: "Oops!", message: "Username or Password is incorrect. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func checkForUsername(username: String, data: [String: Any]) {
        Alamofire.request(userURL+"?username=\(username)", method: .get).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                return
            }
            //check if user already exists
            if json["count"] as! Int == 1 {
                let alert = UIAlertController(title: "User Already Exists", message: "This username is taken.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.postRegister(data: data)
            }
        }
    }

}


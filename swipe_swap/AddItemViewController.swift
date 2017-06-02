//
//  AddItemViewController.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import Alamofire

class AddItemViewController: UIViewController {
    
    var delegate: AddItemDelegate?
    var data: [String]?

    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemDetail: UITextField!
    @IBOutlet weak var imageURL: UITextField!
    @IBOutlet weak var itemValue: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        if let title = itemTitle.text, let detail = itemDetail.text, let url = imageURL.text, let value = itemValue.text {
            if title != "" && detail != "" && url != "" && value != "" {
                let data = [title,detail,value,url]
                delegate?.addItemButtonPressed(by: self, data: data)
            }
            else {
                // alert no empty fields
            }
        }
    }
    
}

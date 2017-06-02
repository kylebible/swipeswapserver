//
//  addItemDelegate.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit

protocol AddItemDelegate: class {
    func cancelButtonPressed(by controller: UIViewController)
    func addItemButtonPressed(by controller: UIViewController, data: [String])
}

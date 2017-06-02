//
//  TradeDelegate.swift
//  swipe_swap
//
//  Created by KYLE C BIBLE on 5/31/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit

protocol TradeDelegate: class {
    func tradeCancelButtonPressed(by controller: UIViewController)
    func tradeDoneButtonPressed(by controller: UIViewController)
}

//
//  LoginPanel.swift
//  ShengjiPockerGame
//
//  Created by Wttch on 2023/3/14.
//

import Foundation
import SwiftUI

class LoginPanel : BaseXibPanelView {
    @IBOutlet weak var panel : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func initView() {
        // panel.bounds = panel.frame.insetBy(dx: 10, dy: 10)
        panel.layer.cornerRadius = 12
    }
    @IBAction func cancelLogin(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}

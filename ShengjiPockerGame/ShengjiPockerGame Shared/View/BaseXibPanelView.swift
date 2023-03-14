//
//  BaseXibPanleView.swift
//  ShengjiPockerGame
//
//  Created by Wttch on 2023/3/14.
//


#if os(iOS) || os(tvOS)
import UIKit

class BaseXibPanelView : UIView {
    @IBOutlet weak var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initXibView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initXibView()
    }
    
    func initXibView() {
        let xibName = String(describing: type(of: self))
        NSLog("加载XIB文件:\(xibName)")
        Bundle.main.loadNibNamed(xibName, owner: self)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        mainView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        addSubview(mainView)
        initView()
    }
    
    open func initView() {  }
}
#endif

#if os(macOS)
import AppKit

class BaseXibPanelView : NSView {
    
}
#endif

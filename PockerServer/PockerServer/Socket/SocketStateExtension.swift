//
//  SocketStateExtension.swift
//  PockerServer
//
//  Created by Wttch on 2023/4/12.
//

import Foundation
import Network
import SwiftUI

extension NWListener.State {
    var desc : String {
        get {
            switch self {
            case .ready:
                return "已就绪..."
            case .cancelled:
                return "已取消."
            case .failed(let error):
                return "出错:\(error.localizedDescription)"
            case .setup:
                return "已初始化..."
            default:
                return "未知"
            }
        }
    }
    
    var foregroundColor : Color {
        get {
            switch self {
            case .setup:
                return Color.blue
            case .ready:
                fallthrough
            case .setup:
                return Color.green
            default:
                return Color.red
            }
        }
    }
}

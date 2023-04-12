//
//  AccountDao.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/15.
//

import Foundation

protocol AccountDao {
    func insert(_ entity : Account) -> Bool
    
    func findByUsername(username : String) -> Account?
}

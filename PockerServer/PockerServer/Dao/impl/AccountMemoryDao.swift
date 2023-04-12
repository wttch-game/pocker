//
//  AccountMemoryDao.swift
//  PockerServer
//
//  Created by Wttch on 2023/3/15.
//

import Foundation

class AccountMemoryDao : AccountDao {
    private var cache : [String : Account] = [:]
    
    init() {
        self.cache["wttch"] = Account(username: "wttch", password: "wttch")
    }
    
    func insert(_ entity: Account) -> Bool {
        if let _ = findByUsername(username: entity.username) {
            return false
        }
        
        self.cache[entity.username] = entity
        return true
    }
    
    func findByUsername(username: String) -> Account? {
        return self.cache[username]
    }
}

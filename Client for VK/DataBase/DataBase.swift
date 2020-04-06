//
//  DataBase.swift
//  Client for VK
//
//  Created by Кирилл Харузин on 06.04.2020.
//  Copyright © 2020 Кирилл Харузин. All rights reserved.
//

import Foundation
import RealmSwift

class DataBase {
    
    func save(friends: [Friends]) throws {
        let realm = try Realm()
        
        realm.beginWrite()
        realm.add(friends)
        try realm.commitWrite()
    }

    func loadFriends() -> [Friends] {
        do {
            let realm = try Realm()
            let objects = realm.objects(Friends.self)
            return Array(objects)
            
        } catch {
            return []
        }

    }
}


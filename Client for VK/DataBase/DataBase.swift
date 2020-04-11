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
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try Realm()
        print(realm.configuration.fileURL)
        realm.beginWrite()
        realm.add(friends, update: .modified)
        try realm.commitWrite()
    }

    

    func saveGroups(groups: [Groups]) throws {
            
            let realm = try Realm()
            realm.beginWrite()
            realm.add(groups, update: .modified)
            try realm.commitWrite()
        }

        
}


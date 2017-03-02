//
//  Record.swift
//  IBMQRScanner
//
//  Created by David Okun IBM on 3/1/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import Foundation
import RealmSwift

class Record: Object {
    dynamic var email = ""
    dynamic var name = ""
    dynamic var notes = ""
    
    var isUnique: Bool {
        let realm = try! Realm()
        let records = realm.objects(Record.self)
        for record in records {
            if self.email == record.email && self.name == record.name {
                return false
            }
        }
        return true
    }
}

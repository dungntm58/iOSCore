//
//  UserEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreRepository
import RxCoreDataStore
import CoreData

class UserEntity: Identifiable, Decodable, ManagedObjectBox {
    let core: UserCoreEntity
    
    var id: String { core.id ?? "" }
    
    var email: String { core.email ?? "" }
    
    var name: String { core.name ?? "" }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case name
    }
    
    required init(core: UserCoreEntity) {
        self.core = core
    }
    
    required init(from decoder: Decoder) throws {
        // Create NSEntityDescription with NSManagedObjectContext
        guard let managedObjectContext = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: String(describing: Object.self), in: managedObjectContext) else {
                throw Constant.Error.errorDecodable
        }
        core = Object(entity: entity, insertInto: managedObjectContext)
        
        // Decode
        let values = try decoder.container(keyedBy: CodingKeys.self)
        core.id = try values.decode(String.self, forKey: .id)
        core.email = try values.decode(String.self, forKey: .email)
        core.name = try values.decode(String.self, forKey: .name)
    }
}

extension UserEntity: CoreDataIdentifiable {
    typealias IDType = String
    
    static func keyPathForID() -> String { #keyPath(UserCoreEntity.id) }
}

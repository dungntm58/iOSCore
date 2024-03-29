//
//  TodoEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreRepository
import CoreDataStore
import CoreBase
import CoreData

class TodoEntity: NSObject, Decodable, ManagedObjectWrapper, Identifiable {
    
    let core: TodoCoreEntity
    
    var id: String { core.id ?? "" }
    
    var title: String { core.title ?? "" }
    
    var completed: Bool { core.completed }
    
    var owner: String { core.owner ?? "" }
    
    var createdAt: Date { core.createdAt ?? Date() }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case completed
        case owner
        case createdAt = "created"
    }
    
    convenience init(title: String) {
        let core = TodoCoreEntity()
        core.title = title
        self.init(object: core)
    }
    
    required init(object: TodoCoreEntity) {
        self.core = object
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
        core.title = try values.decode(String.self, forKey: .title)
        core.completed = try values.decode(Bool.self, forKey: .completed)
        core.owner = try values.decode(String.self, forKey: .owner)
        core.createdAt = try values.decode(Date.self, forKey: .createdAt)
    }
    
    func toLiteralDictionary() -> [String: Any] {
        return [
            "title": title
        ]
    }
    
    func toObject() -> TodoCoreEntity { core }
}

extension TodoEntity: CoreDataIdentifiable {
    typealias ID = String
    
    static func keyPathForID() -> String { #keyPath(TodoCoreEntity.id) }
}

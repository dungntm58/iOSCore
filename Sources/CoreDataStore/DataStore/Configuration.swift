//
//  Configuration.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData

public protocol CoreDataConfiguration {
    var managedObjectContext: NSManagedObjectContext { get }
    var metaManagedObjectContext: NSManagedObjectContext { get }
}

public class DefaultCoreDataConfiguration: CoreDataConfiguration {
    static public let instance = DefaultCoreDataConfiguration()

    var backManagedObjectContext: NSManagedObjectContext?
    let mainManagedObjectContext: NSManagedObjectContext

    var backMetaManagedObjectContext: NSManagedObjectContext?
    let mainMetaManagedObjectContext: NSManagedObjectContext

    private init() {
        mainMetaManagedObjectContext = {
            guard let modelURL = Bundle(for: DefaultCoreDataConfiguration.self).url(forResource: "MetaModel", withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }

            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            do {
                let psc = try createPersistentStoreCoordinator(modelURL: modelURL, storeFileName: "defaultMeta.sqlite")
                context.persistentStoreCoordinator = psc
            } catch {
                #if !RELEASE && !PRODUCTION
                print("Failed to prepare sqlite storage, data will be loss")
                #endif
            }

            return context
        }()

        mainManagedObjectContext = {
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }

            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            do {
                let psc = try createPersistentStoreCoordinator(modelURL: modelURL, storeFileName: "default.sqlite")
                context.persistentStoreCoordinator = psc
            } catch {
                #if !RELEASE && !PRODUCTION
                print("Failed to prepare sqlite storage, data will be loss")
                #endif
            }

            return context
        }()
    }

    open var managedObjectContext: NSManagedObjectContext {
        if Thread.isMainThread {
            return mainManagedObjectContext
        }
        if let context = backManagedObjectContext {
            return context
        }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainManagedObjectContext
        self.backManagedObjectContext = context
        return context
    }

    open var metaManagedObjectContext: NSManagedObjectContext {
        if Thread.isMainThread {
            return mainMetaManagedObjectContext
        }
        if let context = backMetaManagedObjectContext {
            return context
        }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainMetaManagedObjectContext
        self.backMetaManagedObjectContext = context
        return context
    }
}

func createPersistentStoreCoordinator(modelURL: URL, storeFileName: String) throws -> NSPersistentStoreCoordinator {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
        throw NSError(domain: "StoreInitialization", code: -999, userInfo: [
            NSLocalizedDescriptionKey: "Error initializing mom from: \(modelURL)"
        ])
    }

    /* The directory the application uses to store the Core Data store file.
    This code uses a file named "DataModel.sqlite" in the application's documents directory.
    */
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    let storeURL = docURL.appendingPathComponent(storeFileName)
    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options:
        [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
    ])
    return psc
}

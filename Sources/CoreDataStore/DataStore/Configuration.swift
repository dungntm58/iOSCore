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

    private(set) open var managedObjectContext: NSManagedObjectContext
    private(set) open var metaManagedObjectContext: NSManagedObjectContext

    private init() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]

        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */

        metaManagedObjectContext = {
            guard let modelURL = Bundle(for: DefaultCoreDataConfiguration.self).url(forResource: "MetaModel", withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }

            // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }

            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            do {
                let storeURL = docURL.appendingPathComponent("defaultMeta.sqlite")
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options:
                    [
                        NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true
                    ])
            } catch {
                fatalError("Error migrating store: \(error)")
            }

            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = psc

            return context
        }()

        managedObjectContext = {
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }

            // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }

            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            do {
                let storeURL = docURL.appendingPathComponent("default.sqlite")
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options:
                    [
                        NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true
                    ])
            } catch {
                fatalError("Error migrating store: \(error)")
            }

            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = psc

            return context
        }()
    }
}

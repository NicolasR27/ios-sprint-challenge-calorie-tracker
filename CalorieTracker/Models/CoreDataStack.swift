//
//  CoreDataStack.swift
//  CalorieTracker
//
//  Created by Nicolas Rios on 5/2/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import Foundation

import CoreData

class CoreDataStack {

    static let shared = CoreDataStack()

    private init() {}

    lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Calories")

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Error loading Persistent Stores: \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving context \(error)")
                context.reset()
            }
        }
    }
}

//
//  Calories+Convenience.swift
//  CalorieTracker
//
//  Created by Nicolas Rios on 5/2/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import Foundation
import CoreData

extension Calorie {
    
    var calorieRepresentation: CalorieRepresentation? {
        guard let date = date else { return nil }
        return CalorieRepresentation(calories: calories, date: date)
    }

    @discardableResult convenience init(calories: Int16,
                                        date: Date = Date(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.calories = calories
        self.date = date
    }

    @discardableResult convenience init?(calorieRepresentation: CalorieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(calories: calorieRepresentation.calories)
    }
}

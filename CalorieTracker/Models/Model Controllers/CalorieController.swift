//
//  CalorieController.swift
//  CalorieTracker
//
//  Created by Nicolas Rios on 5/2/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import Foundation
import CoreData

class CalorieController {

    @discardableResult func add(calories: Int16) -> Calorie {
        let calorieEntry = Calorie(calories: calories)
        CoreDataStack.shared.save()

        return calorieEntry
    }

    func delete(calorieEntry: Calorie) {
        CoreDataStack.shared.mainContext.delete(calorieEntry)
        CoreDataStack.shared.save()
    }
}

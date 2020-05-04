//
//  CaloriesTableViewController.swift
//  CalorieTracker
//
//  Created by Nicolas Rios on 5/2/20.
//  Copyright © 2020 Nicolas Rios. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class CaloriesTableViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var chart: Chart!

    // MARK: - Properties

    let calorieController = CalorieController()

    lazy var fetchedResultsController: NSFetchedResultsController<Calorie> = {
        let fetchRequest: NSFetchRequest<Calorie> = Calorie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: "date",
                                             cacheName: nil)
        frc.delegate = self

        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }

        return frc
    }()

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    // MARK: - IBActions

    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Calorie Intake",
                                      message: "Enter the amount of calories in the field",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Calories:"
        }

        let submit = UIAlertAction(title: "Submit", style: .default) { _ in
            if let response = alert.textFields?.first?.text, !response.isEmpty {
                let calories = Int16(response) ?? 0
                self.calorieController.add(calories: calories)
            }

            NotificationCenter.default.post(name: .updateChart, object: self)
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(submit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @objc func updateChart() {
        let calorieEntries = fetchedResultsController.fetchedObjects ?? []
        var chartEntries: [Double] = []

        for entry in calorieEntries {
            let calories = Double(entry.calories)
            chartEntries.append(calories)
        }

        chart.removeAllSeries()

        let series = ChartSeries(chartEntries)
        series.area = true
        series.color = .black
        chart.add(series)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChart()
        NotificationCenter.default.addObserver(self, selector: #selector(updateChart), name: .updateChart, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieCell", for: indexPath) as? ChartTableViewCell else { return UITableViewCell() }
        

        let calorieEntry = fetchedResultsController.object(at: indexPath)
        cell.Label1?.text = "Calories: \(calorieEntry.calories)"
        cell.Label2?.text = dateFormatter.string(from: calorieEntry.date ?? Date())
        
        cell.Label1.layer.cornerRadius = 20
        cell.Label2.layer.cornerRadius = 10

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let calorieEntry = fetchedResultsController.object(at: indexPath)
            calorieController.delete(calorieEntry: calorieEntry)
            NotificationCenter.default.post(name: .updateChart, object: self)
            tableView.reloadData()
        }
    }
}

extension CaloriesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {

        let sectionSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
        default:
            return
        }
    }
}


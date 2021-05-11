//
//  CheckStatisticsViewController.swift
//  diplomaThesis
//
//  Created by User on 11/5/21.
//

import Foundation
import UIKit
import CoreData

class CheckStatisticsViewController : UIViewController {
    
    var myFullCount : Int = 0
    var myCADCount : Int = 0
    var myRatio : Float = 0.0
    var myResult : String = "No"
    var myImage : UIImage = UIImage(named: K.finalQuestionImageName)!
//    var myBackgroundColor : UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    var myMessage : String = K.finalUndefinedMessage
    
    @IBOutlet weak var finalMessageLabel: UILabel!
    
    
    @IBOutlet weak var finalResultImageView: UIImageView!
    
    @IBOutlet weak var fullECGsLabel: UILabel!
    
    @IBOutlet weak var normalECGsLabel: UILabel!
    
    @IBOutlet weak var CADECGsLabel: UILabel!
    
    @IBOutlet weak var CADRatioLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = myBackgroundColor
//        self.view.backgroundColor = UIColor(named: K.undefinedColorName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.title = "Statistics"
        fullECGsLabel.text = String(format: "%d", myFullCount)
        normalECGsLabel.text = String(format: "%d", myFullCount - myCADCount)
        CADECGsLabel.text = String(format: "%d", myCADCount)
        CADRatioLabel.text = String(format: "%.1f%%", myRatio * 100)
        finalResultImageView.image = myImage
        finalMessageLabel.text = myMessage
        if myRatio > 0.6 {
            CADRatioLabel.textColor = UIColor.systemRed
        } else if myRatio < 0.5 {
            CADRatioLabel.textColor = UIColor.systemGreen
        } else {
            CADRatioLabel.textColor = UIColor.systemOrange
        }
        super.viewWillAppear(animated)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete All Recordings", message: "Are you sure you want to delete all recordings?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            print("Deleting items...")
            for item in recordArray {
                context.delete(item)
            }
            self.saveRecords {
                recordArray = []
            }
            var myStatistics = CADStatistics(recordArr: recordArray)
            self.myFullCount = myStatistics.getFullCount()
            self.myCADCount = myStatistics.getCADCount()
            self.myRatio = myStatistics.getRatio()
            self.myMessage = myStatistics.getFinalMessage()
            self.myImage = myStatistics.getFinalImage()
            DispatchQueue.main.async {
                self.fullECGsLabel.text = String(format: "%d",self.myFullCount)
                self.normalECGsLabel.text = String(format: "%d", self.myFullCount - self.myCADCount)
                self.CADECGsLabel.text = String(format: "%d", self.myCADCount)
                self.CADRatioLabel.text = String(format: "%.1f%%", self.myRatio * 100)
                self.finalResultImageView.image = self.myImage
                self.finalMessageLabel.text = self.myMessage
                if self.myRatio > 0.6 {
                    self.CADRatioLabel.textColor = UIColor.systemRed
                } else if self.myRatio < 0.5 {
                    self.CADRatioLabel.textColor = UIColor.systemGreen
                } else {
                    self.CADRatioLabel.textColor = UIColor.systemOrange
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Canceled")
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveRecords(completion: @escaping ()->Void = {}) {
        do {
            try context.save()
            completion()
        } catch {
            print("Error in saving the data:")
            print(error)
        }
    }
    
    func loadRecords() -> [RecordEntity] {
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        do {
            let recordArray = try context.fetch(request)
            return recordArray
        } catch {
            print("Error fetching data from context:")
            print(error)
            return []
        }
    }
    
}

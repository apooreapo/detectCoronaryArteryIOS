//
//  ViewController.swift
//  stepsTest
//
//  Created by Orestis Apostolou on 20/12/20.
//
//  This is the Controller managing the opening view of the application.

import UIKit
import HealthKit
import Charts
import CoreData

var recordArray : [RecordEntity] = [] // data struct for managing a 30sec record result
var globalTestData : [[Double]] = []
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // context for saving permanently the results of the previous analysis

/// The controller of the starting view of the application. From here the user can navigate to the rest controllers.
class ViewController: UIViewController {
    
    var ecgSamples = [[(Double,Double)]] () // the data of each 30sec ECG - first is x, second is y
    var ecgDates = [Date] () // the date of each 30sec ECG - used for identifying the record
    var indices = [(Int,Int)]() // Indices helping identify the sample
    var rawECG : [CDouble] = [] // The data of one ECG
    var rawfs : Double = 0.0 // The sampling frequency of one ECG
    
    let healthStore = HKHealthStore() // this var manages all data regarding healthkit in apple
    lazy var mainTitleLabel = UILabel()
    lazy var loadingHeartImageView = UIImageView()
    lazy var currentECGLineChart = CombinedChartView()
    lazy var contentView = UIView()
    lazy var analyzeButton = UIButton(type: .system)
    lazy var checkStatisticsButton = UIButton(type: .system)
    lazy var analyzeAllButton = UIButton(type: .system)
    lazy var smallResultImageView = UIImageView()
    // timeInterval1970 is a value giving the distance of date to a constant
    // date in 1970. In this way, we can use the date of an ECG as a primary
    // key for searching the sample. Also, we avoid possible problems of
    // using different time zones.
    var timeInterval1970 : Int64 = Int64(0)
    var pickerView = UIPickerView()
    let basicQueue = DispatchQueue(label: K.basicQueueID, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none) // A queue for executing tasks
    let basicQueue2 = DispatchQueue(label: "m2", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none) // another queue for executing tasks
    
    lazy var errorLabel = UILabel()
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        do {
            let gif = try UIImage(gifName: "loading.gif")
            DispatchQueue.main.async {
                self.loadingHeartImageView.setGifImage(gif, loopCount: -1) // Will loop forever
                self.loadingHeartImageView.startAnimating()
            }
        } catch {
            print("Error showing gif")
            self.loadingHeartImageView.isHidden = true
        }
//        self.navigationController?.setToolbarHidden(true, animated: false)
        // add title ECG
        
        // If you are trying to understand the functionality of the code, please ignore the below, they refer to the design.
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mainTitleLabel.text = "ECG"
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.font = UIFont.boldSystemFont(ofSize: 35)
        mainTitleLabel.sizeToFit()
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainTitleLabel)
        mainTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mainTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        mainTitleLabel.heightAnchor.constraint(equalTo: mainTitleLabel.heightAnchor, constant: 0).isActive = true
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.sizeToFit()
        contentView.addSubview(pickerView)
        contentView.addSubview(loadingHeartImageView)
        pickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100).isActive = true
        pickerView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 0).isActive = true
        
        
        pickerView.heightAnchor.constraint(equalTo: pickerView.heightAnchor).isActive = true
        loadingHeartImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingHeartImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loadingHeartImageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        loadingHeartImageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        loadingHeartImageView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 30).isActive = true
        
        // end of code regarding design
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        // Record array stores all the RecordEntities. A RecordEntity, is a
        // coreData Entity, meaning a dataStruct saving permanently the
        // results of the analysis of a certain 30sec ECG. A RecordEntity
        // will save the result of the analysis of an ECG: its date, and
        // its result, CAD / no CAD / Undefined.
        recordArray = loadRecords() // load the records stored in coreData
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Some code regarding the design of the View
        self.pickerView.isUserInteractionEnabled = false
        recordArray = loadRecords() // load the records stored in coreData
        pickerView.dataSource = self
        pickerView.delegate = self
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(errorLabel)
        errorLabel.text = "Error here."
        errorLabel.textAlignment = .center
        errorLabel.sizeToFit()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        errorLabel.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        errorLabel.isHidden = true
        // end of design code
        
        // The process below is multithreaded. We use the threadCounter to
        // keep the count of how many ECGs have loaded
        var threadCounter = 0
        let healthKitTypes: Set = [HKObjectType.electrocardiogramType()]
        // Request Apple to access the Health Data (the ECGs)
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (bool, error) in
            if (bool) {
                
                // Authorization completed, maybe successfully or not.
                // Apple does not have a way yet to know if auth is
                // succesfull or not.
                //
                // Probably the only reason for failing in auth is not
                // giving the app the correct permissions for getting access
                // to your data.
                
                self.getECGsCount { (ecgsCount) in
                    if ecgsCount < 1 {
                        print("You have no ecgs available")
                        DispatchQueue.main.async {
                            self.errorLabel.font = UIFont.boldSystemFont(ofSize: 15)
                            self.errorLabel.numberOfLines = 0
                            self.errorLabel.text = "You need first to record an ECG with your Apple Watch. Once you do this, return to this screen. If you do have recorder ECGs, please check the app's permissions."
                            self.errorLabel.isHidden = false
                            self.pickerView.isHidden = true
                        }
                        return
                    } else {
                        for i in 0...ecgsCount - 1 {
                            self.getECGs(counter: i) { (ecgResults,ecgDate)  in
                                DispatchQueue.main.async {
                                    self.ecgSamples.append(ecgResults)
                                    self.ecgDates.append(ecgDate)
                                    threadCounter += 1
                                    
                                    // The last thread will enter here, meaning all of them are finished
                                    if threadCounter == ecgsCount {
                                        
                                        // sort ecgs by newest to oldest
                                        
                                        var newDates = self.ecgDates
                                        newDates.sort { $0 > $1 }
                                        for element in newDates {
                                            self.indices.append((self.ecgDates.firstIndex(of: element)!,newDates.firstIndex(of: element)!))
                                        }
                                        // indices matrix is a tuple matrix with two categories
                                        // the first is the sorted indice, and the second is the raw
                                        // ecgSamples[indices[0].0] is the newest ecg

                                        
                                        self.pickerView.reloadAllComponents()
                                        print("Allowing interaction now")
                                        self.pickerView.isUserInteractionEnabled = true
                                        
                                        
                                        // the line below has use only for the first drop of the pickerView. (At the first time
                                        // picker view doesn't "see" as selected the option
                                        recordArray = self.loadRecords()
                                        self.timeInterval1970 = Int64(self.ecgDates[self.indices[0].0].timeIntervalSince1970)
//                                        self.currentRecord = self.searchRecord(self.timeInterval1970, recordArray)
                                        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[0].0], animated: true, timeInterval1970: self.timeInterval1970)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                
            } else {
                print("We had an error here: \n\(String(describing: error))")
                DispatchQueue.main.async {
                    self.errorLabel.text = "You need to allow this application to read your ECG. Please change the permissions for this app to continue."
                    self.errorLabel.font = UIFont.boldSystemFont(ofSize: 15)
                    self.errorLabel.numberOfLines = 0
                    self.errorLabel.isHidden = false
                    self.pickerView.isHidden = true
                }
            }
        }
    }
    
    
    /// Gets all available ECGs in healthStore.
    /// - Parameters:
    ///   - counter: Count of available ECGs
    ///   - completion: Function that gets triggered upon completion
    func getECGs(counter: Int, completion: @escaping ([(Double,Double)],Date) -> Void) {
        var ecgSamples = [(Double,Double)] ()
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date.distantFuture,options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]){ (query, samples, error) in
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKElectrocardiogram else {
                return
            }
            //print(mostRecentSample)
            
            
            let query = HKElectrocardiogramQuery(samples[counter] as! HKElectrocardiogram) { (query, result) in
                
                switch result {
                case .error(let error):
                    print("error: ", error)
                    self.pickerView.isHidden = true
                    self.loadingHeartImageView.stopAnimating()
                    self.loadingHeartImageView.isHidden = true
                    // Fix it!
                    
                case .measurement(let value):
                    let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                    ecgSamples.append(sample)
                    
                case .done:
                    //print("done")
                    DispatchQueue.main.async {
                        completion(ecgSamples,samples[counter].startDate)
                    }
                @unknown default:
                    print("Uknown error here")
                    self.pickerView.isHidden = true
                    self.loadingHeartImageView.stopAnimating()
                    self.loadingHeartImageView.isHidden = true
                    // Fix it!
                }
            }
            self.healthStore.execute(query)
        }
        
        // Execute the query above
        self.healthStore.execute(ecgQuery)
    }
    
    
    /// Calculates the count of available ECGs in healthStore.
    /// - Parameter completion: Function that gets triggered upon completion
    func getECGsCount(completion: @escaping (Int) -> Void) {
        var result : Int = 0
        let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil){ (query, samples, error) in
            guard let samples = samples
            else {
                return
            }
            result = samples.count
            completion(result)
        }
        self.healthStore.execute(ecgQuery)
    }
    
    /// Objective-c function that gets triggered when "Check Statistics" button is pressed.
    @objc func checkStatisticsButtonPressed() {
        print("Check Statistics!")
        recordArray = loadRecords()
        // Pressing the button sends you to another View.
        performSegue(withIdentifier: K.segueCheckStatisticsIdentifier, sender: self)
    }
    
    
    /// Objective-c function that gets triggered when "Anallyze All" button is pressed.
    @objc func analyzeAllButtonPressed() {
        let alert = UIAlertController(title: "Analyze All Recordings", message: "Are you sure you want to analyze all recordings? This may be energy and time consuming.", preferredStyle: .alert)
        let proceedAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let fs = 100 / (self.ecgSamples[0][100].1 - self.ecgSamples[0][0].1) // Sampling freq is same for all ECGs
            self.rawfs = fs
            DispatchQueue.main.async(group: .none, qos: .userInteractive, flags: .barrier) {
                self.performSegue(withIdentifier: K.segueAnalyzeAllIdentifier, sender: self)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(proceedAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    

    
    /// Objective-c function that gets triggered when "Analyze ECG" button is pressed.
    @objc func analyzeButtonPressed() {
        
        let selected = pickerView.selectedRow(inComponent: 0)
        let sz = ecgSamples[self.indices[selected].0].count
        let fs = 100 / (ecgSamples[self.indices[selected].0][100].1 - ecgSamples[self.indices[selected].0][0].1)
        var selectedECG : [CDouble] = []
        for i in 0...(sz - 1) {
            selectedECG.append(ecgSamples[self.indices[selected].0][i].0)
        }
        rawECG = selectedECG // This is going to be send through segue
        rawfs = fs
        
        // Pan Tompkins analysis for R peaks
        performSegue(withIdentifier: K.segueAnalyzeECGIdentifier, sender: self)
        
//        Uncomment below to get the raw data
//        testMatrix.append(rawECG)
//        print(testMatrix.count)
//        if testMatrix.count == 43 {
//            print("Saving to orestis_full.csv")
//            createCSVX(from: testMatrix, output: "orestis_rawData.csv")
//            print("Done getting your data.")
//        }
        
//
//        let myPanTompkins = PanTompkins(input: selectedECG, fs: fs)
//
//        let r_locations = myPanTompkins.calculateR()
//        var testOut : [(Double, Double)] = []
//        for i in 0..<Int(selectedECG.count) {
//            testOut.append((Double(selectedECG[i]), Double(i) / fs))
//        }
//        self.updateCharts(ecgSamples: testOut, animated: false, peaks: r_locations)
//        let lowerRes = interpolate(input: selectedECG, ratio: 8)
//        var testOut1 : [(Double, Double)] = []
//        for i in 0..<Int(lowerRes.count) {
//            testOut1.append((lowerRes[i], Double(8) * Double(i) / fs))
//        }
//        self.updateCharts(ecgSamples: testOut1, animated: false)
//
//        var myUltraShortAnalysis = UltraShortAnalysis(input: selectedECG, fs: fs, rLocs: r_locations)
//        myUltraShortAnalysis.getInThere()
//        let myFFT = FFTAnalysis(input: selectedECG, fs: fs)
//        let freqRes = myFFT.calculateFrequencyMetrics()
//        print(String(format:"HF Energy: %.9f", freqRes.hfEnergy ))
//        print(String(format:"LF Energy: %.9f", freqRes.lfEnergy))
//        print(String(format:"HF Peak: %.9f", freqRes.hfPeak))
//        print(String(format:"LF Peak: %.9f", freqRes.lfPeak))
//        print(String(format: "HF Percentage: %.9f", freqRes.hfPercentage))
//        print(String(format: "LF Percentage: %.9f", freqRes.lfPercentage))
//        print(String(format: "LF/ HF Ratio: %.6f", freqRes.lfhf))
        
//        myUltraShortAnalysis.calculateUltraShortMetrics(printMessage: true)
        
        
        
       
        // fs = 512.414
    }
    
    
    /// This function precedes the a segue. A segue means a transition from a view to another. It is very important, as it passes the necessary data from a the sending to the receiving view.
    /// - Parameters:
    ///   - segue: Type of segue.
    ///   - sender: The sending view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueAnalyzeECGIdentifier {
            let VCdestination = segue.destination as! AnalyzeECGViewController
            VCdestination.selectedECG = rawECG
//            VCdestination.selectedECG = removeAverage(input: rawECG)
            VCdestination.fs = rawfs
            VCdestination.basicQueue = basicQueue
//            VCdestination.currentRecord = self.currentRecord
            VCdestination.timeInterval1970 = self.timeInterval1970
        } else if segue.identifier == K.segueAnalyzeAllIdentifier {
            basicQueue2.async(group: .none, qos: .userInteractive, flags: .barrier) {
                let VCdestination = segue.destination as! AnalyzeAllViewController
                VCdestination.ecgSamples = self.ecgSamples
                VCdestination.ecgDates = self.ecgDates
                VCdestination.indices = self.indices
                VCdestination.fs = self.rawfs
                VCdestination.basicQueue = self.basicQueue
            }
        }
    }
    
    
    /// Searches if a record exists in recordArray, and returns its classification result.
    /// - Parameters:
    ///   - itemInt: The key value Int for the search.
    ///   - inside: The Array<RecordEntity> in which we search.
    /// - Returns: If the key-value exists, returns its classification result, else, it returns nil.
    func searchRecord(_ itemInt: Int64, _ inside: [RecordEntity]) -> RecordEntity? {
        for item in inside {
            if item.timeInterval1970 == itemInt {
                return item
            }
        }
        return nil
    }
    
    /// Creates and saves a simple csv as "myECG.csv. Used for testing purposes.
    /// - Parameter recArray: The array of CDoubles to be saved as .csv file
    func createCSVX(from recArray:[CDouble]) {
        
        var strings : [String] = []

        for i in 0..<recArray.count {
            strings.append(String(format: "%f", recArray[i]))
        }
        let csvString = strings.joined(separator: ",\n")


        let fileManager = FileManager.default

        do {

            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil , create: false )

            let fileURL = path.appendingPathComponent("myECG.csv")

            try csvString.write(to: fileURL, atomically: true , encoding: .utf8)
            
            print("Done writing .csv file!")
        } catch {

            print("error creating file")

        }


    }
    
    
    /// Creates and saves a simple csv as "myECG.csv. Used for testing purposes.
    /// - Parameters:
    ///   - recArray: The array of CDoubles to be saved as .csv file
    ///   - output: The path of the output.
    func createCSVX(from recArray:[[Double]], output: String) {
        
//        var strings : [String] = []
        var csvString : String = ""
        
//        for item in K.UltraShortModel.input_names_R_style {
//            csvString.append(item + ",")
//        }
//        csvString.removeLast()
//        csvString.append("\n")
        
        for dataRecord in recArray {
            for dataValue in dataRecord {
                csvString.append(String(format: "%f,", dataValue))
            }
            csvString.removeLast()
            csvString.append("\n")
        }
        
//            for i in 0..<recArray.count {
//                strings.append(String(format: "%f", recArray[i]))
//            }
//        let csvString = strings.joined(separator: ",\n")


        let fileManager = FileManager.default

        do {

            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil , create: false )

            let fileURL = path.appendingPathComponent(output)

            try csvString.write(to: fileURL, atomically: true , encoding: .utf8)
            
            print("Done writing .csv file!")
        } catch {

            print("error creating file")

        }


    }
    
    
    
    /// Normalizes an array by centering it to 0.
    /// - Parameter input: Input array of doubles.
    /// - Returns: Returns the new centered array.
    func removeAverage(input: [Double]) -> [Double] {
        let average : Double = input.avg()
        var result : [Double] = []
        for rec in input {
            result.append(rec - average)
        }
        return result
    }

    
}



//MARK: - UIPickerViewDataSource

extension ViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if ecgDates.count < 1 {
            return 1
        } else {
            return ecgDates.count
        }
    }
    
    
}

extension ViewController : UIPickerViewDelegate {
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if ecgDates.count >= 1 {
            self.timeInterval1970 = Int64(self.ecgDates[self.indices[row].0].timeIntervalSince1970)
    //        self.currentRecord = self.searchRecord(self.timeInterval1970, recordArray)
            self.updateCharts(ecgSamples: self.ecgSamples[self.indices[row].0], animated: false, timeInterval1970: self.timeInterval1970)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        if ecgDates.count < 1 {
            return "Loading"
        } else {
            return dateFormatter.string(from: ecgDates[indices[row].0])
            
        }
    }
    
}

//MARK: - Extension for updating charts

extension ViewController {
    
    
    /// Updates Charts with a new signal.
    /// - Parameters:
    ///   - ecgSamples: Our ECG to be shown. Array of tuples: first element represents the value and second the time
    ///   - animated: If true, the signal appears with a single animation
    func updateCharts(ecgSamples : [(Double,Double)], animated : Bool, timeInterval1970: Int64) {
        if !ecgSamples.isEmpty {
            self.loadingHeartImageView.isHidden = true
            self.loadingHeartImageView.stopAnimating()
            
            // add line chart with constraints
            
            currentECGLineChart.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(currentECGLineChart)
            currentECGLineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
            currentECGLineChart.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10).isActive = true
            currentECGLineChart.heightAnchor.constraint(equalToConstant: view.frame.size.width + -135).isActive = true
            
            analyzeButton.translatesAutoresizingMaskIntoConstraints = false
            analyzeButton.setTitle("Analyze ECG", for: .normal)
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(analyzeButton)
            analyzeButton.sizeToFit()
            analyzeButton.centerXAnchor.constraint(equalTo: analyzeButton.superview!.centerXAnchor).isActive = true
//            analyzeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
//            analyzeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
//            analyzeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
            analyzeButton.topAnchor.constraint(equalTo: currentECGLineChart.bottomAnchor, constant: 0).isActive = true
            analyzeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            analyzeButton.addTarget(self, action: #selector(analyzeButtonPressed), for: .touchUpInside)
            
            checkStatisticsButton.translatesAutoresizingMaskIntoConstraints = false
            checkStatisticsButton.setTitle("Check Statistics", for: .normal)
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(checkStatisticsButton)
            checkStatisticsButton.sizeToFit()
            checkStatisticsButton.centerXAnchor.constraint(equalTo: checkStatisticsButton.superview!.centerXAnchor).isActive = true
            checkStatisticsButton.topAnchor.constraint(equalTo: analyzeButton.bottomAnchor, constant: 0).isActive = true
            checkStatisticsButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            checkStatisticsButton.addTarget(self, action: #selector(checkStatisticsButtonPressed), for: .touchUpInside)
            
            smallResultImageView.translatesAutoresizingMaskIntoConstraints = false
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(smallResultImageView)
            smallResultImageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(smallResultImageView)
            smallResultImageView.leftAnchor.constraint(equalTo: analyzeButton.rightAnchor, constant: 14).isActive = true
            smallResultImageView.centerYAnchor.constraint(equalTo: analyzeButton.centerYAnchor).isActive = true
//            analyzeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
            smallResultImageView.widthAnchor.constraint(equalTo: analyzeButton.heightAnchor, multiplier: 0.33).isActive = true
            smallResultImageView.heightAnchor.constraint(equalTo: smallResultImageView.widthAnchor).isActive = true
            
            analyzeAllButton.translatesAutoresizingMaskIntoConstraints = false
            analyzeAllButton.setTitle("Analyze All", for: .normal)
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(analyzeAllButton)
            analyzeAllButton.sizeToFit()
            analyzeAllButton.centerXAnchor.constraint(equalTo: analyzeAllButton.superview!.centerXAnchor).isActive = true
            analyzeAllButton.topAnchor.constraint(equalTo: checkStatisticsButton.bottomAnchor, constant: 0).isActive = true
            analyzeAllButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            analyzeAllButton.addTarget(self, action: #selector(analyzeAllButtonPressed), for: .touchUpInside)
            
            // customize line chart and add data
            
            
            var entries = [ChartDataEntry] ()
            for i in 0...ecgSamples.count-1 {
                entries.append(ChartDataEntry(x: ecgSamples[i].1, y: ecgSamples[i].0))
            }
            let set1 = LineChartDataSet(entries: entries, label: "ECG data")
            set1.colors = [UIColor.systemRed]
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            let combinedData = CombinedChartData()
            combinedData.lineData = data
            self.currentECGLineChart.data = combinedData
//            self.currentECGLineChart.data = data
            currentECGLineChart.setVisibleXRangeMaximum(10)
            
            currentECGLineChart.rightAxis.enabled = false
            //let yAxis = currentECGLineChart.leftAxis
            if animated {
                currentECGLineChart.animate(xAxisDuration: 1.0)
            }
            
            currentECGLineChart.xAxis.labelPosition = .bottom
            
            let searchRecordResult = searchRecord(timeInterval1970, recordArray)
            if searchRecordResult != nil {
//                print(searchRecordResult?.classificationResult)
                smallResultImageView.image = UIImage(imageLiteralResourceName: K.ticImageName)
            } else {
                smallResultImageView.image = nil
            }
            
        }
        
    }
    
    
    
    /// Updates Charts with a new signal, showing its peaks.
    /// - Parameters:
    ///   - ecgSamples: Our ECG to be shown. Array of tuples: first element represents the value and second the time
    ///   - animated: If true, the signal appears with a single animation
    ///   - peaks: Array of Int, representing the peaks of the ECG
    func updateCharts(ecgSamples : [(Double,Double)], animated : Bool, peaks: [Int]) {
        if !ecgSamples.isEmpty {
            
            // add line chart with constraints
            
            currentECGLineChart.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(currentECGLineChart)
            currentECGLineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
            currentECGLineChart.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10).isActive = true
            currentECGLineChart.heightAnchor.constraint(equalToConstant: view.frame.size.width + -115).isActive = true
            
            analyzeButton.translatesAutoresizingMaskIntoConstraints = false
            analyzeButton.setTitle("Analyze ECG", for: .normal)
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(analyzeButton)
            analyzeButton.sizeToFit()
            analyzeButton.centerXAnchor.constraint(equalTo: analyzeButton.superview!.centerXAnchor).isActive = true
            analyzeButton.topAnchor.constraint(equalTo: currentECGLineChart.bottomAnchor, constant: 0).isActive = true
            analyzeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            analyzeButton.addTarget(self, action: #selector(analyzeButtonPressed), for: .touchUpInside)
            
            checkStatisticsButton.translatesAutoresizingMaskIntoConstraints = false
            checkStatisticsButton.setTitle("Check Statistics", for: .normal)
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(checkStatisticsButton)
            checkStatisticsButton.sizeToFit()
            checkStatisticsButton.centerXAnchor.constraint(equalTo: checkStatisticsButton.superview!.centerXAnchor).isActive = true
//            analyzeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
//            analyzeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
//            analyzeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
            checkStatisticsButton.topAnchor.constraint(equalTo: analyzeButton.bottomAnchor, constant: 0).isActive = true
            checkStatisticsButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            checkStatisticsButton.addTarget(self, action: #selector(checkStatisticsButtonPressed), for: .touchUpInside)
        
            smallResultImageView.translatesAutoresizingMaskIntoConstraints = false
//            analyzeButton.setTitleColor(.label, for: .normal)
//            analyzeButton.showsTouchWhenHighlighted = true
            contentView.addSubview(smallResultImageView)
            smallResultImageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(smallResultImageView)
            smallResultImageView.leftAnchor.constraint(equalTo: analyzeButton.rightAnchor, constant: 14).isActive = true
            smallResultImageView.centerYAnchor.constraint(equalTo: analyzeButton.centerYAnchor).isActive = true
//            analyzeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
            smallResultImageView.widthAnchor.constraint(equalTo: analyzeButton.heightAnchor, multiplier: 0.33).isActive = true
            smallResultImageView.heightAnchor.constraint(equalTo: smallResultImageView.widthAnchor).isActive = true
            
            // customize line chart and add data
            
            
            var entries = [ChartDataEntry] ()
            for i in 0...ecgSamples.count-1 {
                entries.append(ChartDataEntry(x: ecgSamples[i].1, y: ecgSamples[i].0))
            }
            let set1 = LineChartDataSet(entries: entries, label: "ECG data")
            set1.colors = [UIColor.systemRed]
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            
            var dataEntries2 : [ChartDataEntry] = []
            for i in 0..<peaks.count {
                let dataEntry = ChartDataEntry(x: ecgSamples[peaks[i]].1, y: ecgSamples[peaks[i]].0)
                dataEntries2.append(dataEntry)
            }

            let dataSet2 = ScatterChartDataSet(entries: dataEntries2 ,label: "R peaks")
            dataSet2.setColor(UIColor.blue)
            dataSet2.setScatterShape(.x)
            let data2 = ScatterChartData(dataSet: dataSet2)
//            self.currentECGLineChart.data = data2
            let combinedData = CombinedChartData()
            combinedData.lineData = data
            combinedData.scatterData = data2
            self.currentECGLineChart.data = combinedData
//            self.currentECGLineChart.data = data
            currentECGLineChart.setVisibleXRangeMaximum(10)
            
            currentECGLineChart.rightAxis.enabled = false
            //let yAxis = currentECGLineChart.leftAxis
            if animated {
                currentECGLineChart.animate(xAxisDuration: 1.0)
            }
            currentECGLineChart.xAxis.labelPosition = .bottom
            
            let searchRecordResult = searchRecord(timeInterval1970, recordArray)
            if searchRecordResult != nil {
                smallResultImageView.image = UIImage(imageLiteralResourceName: K.ticImageName)
            } else {
                smallResultImageView.image = nil
            }
        }
    }
}

//MARK: - Extension for saving and loading coreData.

extension ViewController {
    func saveRecords() {
        do {
            try context.save()
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




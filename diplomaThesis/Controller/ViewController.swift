//
//  ViewController.swift
//  stepsTest
//
//  Created by Orestis Apostolou on 20/12/20.
//

import UIKit
import HealthKit
import Charts
import CoreData

var globalTestData : [[Double]] = []
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

/// The controller of the starting view of the application. From here the user can navigate to the rest controllers.
class ViewController: UIViewController {
    
    var recordArray : [RecordEntity] = []
    var ecgSamples = [[(Double,Double)]] ()
    var ecgDates = [Date] ()
    var indices = [(Int,Int)]()
    var rawECG : [CDouble] = []
    var rawfs : Double = 0.0
//    var testMatrix : [[Double]] = []
    
    let healthStore = HKHealthStore()
    lazy var mainTitleLabel = UILabel()
    lazy var loadingHeartImageView = UIImageView()
//    lazy var currentECGLineChart = LineChartView()
//    lazy var currentECGLineChart = ScatterChartView()
    lazy var currentECGLineChart = CombinedChartView()
    lazy var contentView = UIView()
    lazy var analyzeButton = UIButton(type: .system)
    lazy var checkStatisticsButton = UIButton(type: .system)
    lazy var smallResultImageView = UIImageView()
    var timeInterval1970 : Int64 = Int64(0)
    var currentRecord : RecordEntity? = nil
    var pickerView = UIPickerView()
    let basicQueue = DispatchQueue(label: K.basicQueueID, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        self.recordArray = loadRecords()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordArray = loadRecords()
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
        
        
        var counter = 0
//        var test1: [CDouble] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
//        var output = implement_fft(4, &test1)
//        for i in 0..<2 {
//            print(String(format: "output[%d] = %.5f", i, output![i]))
//        }
//        let myFFT = FFTAnalysis(input: test1, fs: 10)
//        myFFT.analyzeFreqs()
        let healthKitTypes: Set = [HKObjectType.electrocardiogramType()]
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (bool, error) in
            if (bool) {
                
                //authorization completed, maybe successfully or not
                
                self.getECGsCount { (ecgsCount) in
//                    print("Result is \(ecgsCount)")
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
                                    counter += 1
                                    
                                    // the last thread will enter here, meaning all of them are finished
                                    if counter == ecgsCount {
                                        
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
                                        
                                        
                                        // the line below has use only for the first drop of the pickerView. (At the first time
                                        // picker view doesn't "see" as selected the option
                                        self.recordArray = self.loadRecords()
                                        self.timeInterval1970 = Int64(self.ecgDates[self.indices[0].0].timeIntervalSince1970)
                                        self.currentRecord = self.searchRecord(self.timeInterval1970, self.recordArray)
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
                    // Fix iiiiiiiiiiiiiiit!!!!!!!!!!!!!!!!!!!!
                    
                case .measurement(let value):
                    let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                    ecgSamples.append(sample)
                    
                case .done:
                    //print("done")
                    DispatchQueue.main.async {
                        completion(ecgSamples,samples[counter].startDate)
                    }
                }
            }
            self.healthStore.execute(query)
        }
        
        
        self.healthStore.execute(ecgQuery)
        //print("everything working here")
        //print(ecgSamples.count)
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
        self.recordArray = loadRecords()
        let myArray = self.recordArray
        var myFullCount = 0
        var myCADCount = 0
        var myRatio : Float = 0.0
        if myArray.count < 1 {
            print(myRatio)
        } else {
            for item in myArray {
                if item.classificationResult == K.UltraShortModel.positiveResult {
                    myCADCount += 1
                    myFullCount += 1
                } else if item.classificationResult == K.UltraShortModel.negativeResult {
                    myFullCount += 1
                }
            }
            myRatio = Float(myCADCount) / Float(myFullCount)
            print(myRatio)
            print(myFullCount)
        }
    }
    

    
    /// Objective-c function that gets triggered when "Analyze ECG" button is pressed.
    @objc func analyzeButtonPressed() {
        // Gets triggered when analyze button is pressed.
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueAnalyzeECGIdentifier {
            let VCdestination = segue.destination as! AnalyzeECGViewController
            VCdestination.selectedECG = rawECG
//            VCdestination.selectedECG = removeAverage(input: rawECG)
            VCdestination.fs = rawfs
            VCdestination.basicQueue = basicQueue
            VCdestination.currentRecord = self.currentRecord
            VCdestination.timeInterval1970 = self.timeInterval1970
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
    
    /// Creates and saves a smiple csv as "myECG.csv. Used for testing purposes.
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
        self.timeInterval1970 = Int64(self.ecgDates[self.indices[row].0].timeIntervalSince1970)
        self.currentRecord = self.searchRecord(self.timeInterval1970, self.recordArray)
        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[row].0], animated: false, timeInterval1970: self.timeInterval1970)
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
            currentECGLineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
            currentECGLineChart.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10).isActive = true
            currentECGLineChart.heightAnchor.constraint(equalToConstant: view.frame.size.width + -115).isActive = true
            
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
            
            let searchRecordResult = searchRecord(timeInterval1970, self.recordArray)
            if searchRecordResult != nil {
                print(searchRecordResult?.classificationResult)
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
            currentECGLineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
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
            
            let searchRecordResult = searchRecord(timeInterval1970, self.recordArray)
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




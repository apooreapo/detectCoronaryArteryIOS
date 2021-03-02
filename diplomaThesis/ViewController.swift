//
//  ViewController.swift
//  stepsTest
//
//  Created by Orestis Apostolou on 20/12/20.
//

import UIKit
import HealthKit
import Charts



class ViewController: UIViewController {
    
    var ecgSamples = [[(Double,Double)]] ()
    var ecgDates = [Date] ()
    var indices = [(Int,Int)]()
    
    let healthStore = HKHealthStore()
    lazy var mainTitleLabel = UILabel()
    lazy var currentECGLineChart = LineChartView()
    lazy var contentView = UIView()
    lazy var analyzeButton = UIButton(type: .system)
    var pickerView = UIPickerView()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
        pickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100).isActive = true
        pickerView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 0).isActive = true
        
        pickerView.heightAnchor.constraint(equalTo: pickerView.heightAnchor).isActive = true
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        
        var counter = 0
        
        let healthKitTypes: Set = [HKObjectType.electrocardiogramType()]
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (bool, error) in
            if (bool) {
                
                //authorization succesful
                
                self.getECGsCount { (ecgsCount) in
                    print("Result is \(ecgsCount)")
                    if ecgsCount < 1 {
                        print("You have no ecgs available")
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
                                        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[0].0], animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                
            } else {
                print("We had an error here: \n\(String(describing: error))")
            }
        }
    }
    
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
    
    func updateCharts(ecgSamples : [(Double,Double)], animated : Bool) {
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
            analyzeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
            analyzeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
//            analyzeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
            analyzeButton.topAnchor.constraint(equalTo: currentECGLineChart.bottomAnchor, constant: 10).isActive = true
            analyzeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            analyzeButton.heightAnchor.constraint(equalToConstant: 30.0)
            analyzeButton.addTarget(self, action: #selector(analyzeButtonPressed), for: .touchUpInside)
            
            // customize line chart and add data
            
            
            var entries = [ChartDataEntry] ()
            for i in 0...ecgSamples.count-1 {
                entries.append(ChartDataEntry(x: ecgSamples[i].1, y: ecgSamples[i].0))
            }
            let set1 = LineChartDataSet(entries: entries, label: "ECG data")
            set1.colors = [UIColor.systemRed]
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            self.currentECGLineChart.data = data
            currentECGLineChart.setVisibleXRangeMaximum(10)
            
            currentECGLineChart.rightAxis.enabled = false
            //let yAxis = currentECGLineChart.leftAxis
            if animated {
                currentECGLineChart.animate(xAxisDuration: 1.0)
            }
            
            currentECGLineChart.xAxis.labelPosition = .bottom
        }
        
    }
    
    @objc func analyzeButtonPressed() {
        print("Analyze button pressed!")
        let selected = pickerView.selectedRow(inComponent: 0)
        let sz = ecgSamples[self.indices[selected].0].count
        let fs = 100 / (ecgSamples[self.indices[selected].0][100].1 - ecgSamples[self.indices[selected].0][0].1)
        var selectedECG : [CDouble] = []
        var rPeaks : [Int32] = []
        for i in 0...(sz - 1) {
            selectedECG.append(ecgSamples[self.indices[selected].0][i].0)
        }
        print("Got here, good luck!")
//        self.createCSVX(from: selectedECG)
//        var test : [Double] = [0.01234, 0.12345, 0.23456, 0.34567, 0.45678, 0.56789, 0.67890]
//        var test2 : [CDouble] = [0.1, 0.2, 0.3, 0.4]
//        initPan(&selectedECG, Int32(sz), &rPeaks)
//        panTompkins()
//        var input2: [CDouble] = [0.000036, 0.000037, 0.000039, 0.00004, 0.000042, 0.000043,
//                0.000045, 0.000047, 0.000048, 0.00005, 0.000052, 0.000053, 0.000055, 0.000057, 0.000058, 0.000060, 0.000061, 0.000063, 0.000064, 0.000066]
        panTompkinsAlgorithm(input: selectedECG, fs: fs)
        
        
        
//        print(self.ecgSamples[self.indices[selected].0][513])
//        fs = 512.414
    }
    
    func panTompkinsAlgorithm(input: [CDouble], fs: Double){
        var coeffs : UnsafeMutablePointer<Double> // double array of b and a coeffs
        var aCoeffs : [CDouble] = []  // double array of a coeffs of butterworth filter
        var bCoeffs : [CDouble] = []  // double array of b coeffs of butterworth filter
        let lowFreq = CDouble(5.0 * 2 / fs) // 5 Hz, as a fraction of pi
        let highFreq = CDouble(15.0 * 2 / fs) // 15 Hz, as a fraction of pi
        var input2 = input // A trick to pass immutable var to C++ function
        
        // We implement a bandpass butterworth filter of 3rd degree, with cutoff
        // frequencies at 5 and 15 H`
        let degree = 3
        coeffs = bwbpCoeffs(Int32(degree), Int32(1), lowFreq, highFreq)
        for i in 0..<(2 * degree + 1) {
            bCoeffs.append(coeffs[i])
            aCoeffs.append(coeffs[i + 2 * degree + 1])
        }
        var outputs1 : UnsafeMutablePointer<Double>
        var outputs2 : UnsafeMutablePointer<Double>

        let n: Int32 = Int32(input.count)
        let na: Int32 = Int32(aCoeffs.count)
        let nb: Int32 = Int32(bCoeffs.count)
        
        // impplement zero-phase-filter
        
        outputs1 = filtfiltWrapper().filterfilter(&input2, n: n, aCoeffs: &aCoeffs, na: na, bCoeffs: &bCoeffs, nb: nb, normalize: Int32(1) )
        
//        for i in 0..<Int(n) {
//            print("Output")
//            print(String(format: "%f", outputs[i]))
//        }
        
        // Apply derivative filter
        // Original autoregressive filter: 1/[1, 2, 0, -2, -1]
        
        let factor1 : Double = fs / 8
        let derArray1 : [Double] = [1.0*factor1, 2.0*factor1, 0, -2*factor1, -1*factor1]
        var b1 = self.interpolate(inputArray:derArray1, step: Double(4.0 / (fs / 40.0)))
        let b1size = Int32(b1.count)
        var a1: [CDouble] = [1]
        outputs2 = filtfiltWrapper().filterfilter(outputs1, n: n, aCoeffs: &a1, na: 1, bCoeffs: &b1, nb: b1size, normalize: Int32(1) )
        
        //Square to get more obvious peaks
        
        for i in 0..<Int(n) {
            outputs2[i] = pow(outputs2[i], 2)
        }
        
        // convolution - moving average
        
        var ones : [CDouble] = []
        let ones1 = Int(round(fs * Double(0.15)))
        for _ in 0..<ones1 {
            ones.append(1.0 / Double(ones1))
        }
        var outputs3 : UnsafeMutablePointer<Double>
        var n2 : Int32 = Int32(0)
        outputs3 = convolve(outputs2, &ones, Int32(n), Int32(ones1), &n2)
        print("Hello convolution")
        
        
        // print result
        
        var testOut : [(Double, Double)] = []
        for i in 0..<Int(n2) {
            testOut.append((Double(outputs3[i]), Double(i) / fs))
        }
        self.updateCharts(ecgSamples: testOut, animated: false)
        
        
        
        
    }
    
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
        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[row].0], animated: false)
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

//MARK: - Helping functions

extension ViewController {
    func interpolate(inputArray: [Double], step: Double) -> [Double]{
        var inputIndex: [Double] = []
        let inputArraySize = inputArray.count
        for i in stride(from: 0.0, through: Double(inputArraySize - 1), by: step){
            inputIndex.append(i)
        }
        var output : [CDouble] = []
        for ind in inputIndex {
            let fl = Int(floor(ind))
            let ce = Int(ceil(ind))
            let down = ind - floor(ind)
            if ind == Double(inputArraySize - 1){
                output.append(CDouble(inputArray.last ?? 0.0))
            } else {
                output.append(CDouble(Double(down)*(inputArray[ce] - inputArray[fl]) + inputArray[fl]))
            }
            
        }
        return output
}
    
}





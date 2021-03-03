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
//        var rPeaks : [Int32] = []
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
        
        let rpeaks = findLocalMaxima(input: outputs3, n: Int(n2), minDist: Int(fs / 5.0))
        // minDist is 200 msec
        
        //initialize arrays for thresholds
        
//        var delay: Double = round(0.15 * fs) / 2
        var skip: Double = 0
        var m_selected_RR: Double = 0
        var mean_RR : Double = 0
        var ser_back : Int = 0
        
        let LLp = rpeaks.count
        var qrs_c = Array<Double>(repeating: 0.0, count: LLp)
        var qrs_i = Array<Int>(repeating: 0, count: LLp)
        var qrs_i_raw = Array<Int>(repeating: 0, count: LLp)
        var qrs_amp_raw = Array<Double>(repeating: 0.0, count: LLp)
        var nois_c = Array<Double>(repeating: 0.0, count: LLp)
        var nois_i = Array<Int>(repeating: 0, count: LLp)
        
        var sigl_buf = Array<Double>(repeating: 0, count: LLp)
        var noisl_buf = Array<Double>(repeating: 0, count: LLp)
        var thrs_buf = Array<Double>(repeating: 0, count: LLp)
        var sigl_buf1 = Array<Double>(repeating: 0, count: LLp)
        var noisl_buf1 = Array<Double>(repeating: 0, count: LLp)
        var thrs_buf1 = Array<Double>(repeating: 0, count: LLp)
        
        //initialize parameters for thresholds
        
        var thr_sig : Double = 0
        var thr_noise : Double = 0
        var sig_level : Double
        var noise_level : Double
        
        // We initialize threshold parameters in the first two seconds
        
        for i in 0...Int(2*fs) {
            thr_noise += outputs3[i]
            if outputs3[i] > thr_sig {
                thr_sig = outputs3[i]
            }
        }
        thr_sig /= 3.0 // thr_sig = 1/3 * max(ecg in first 2 secs)
        thr_noise /= 2.0 * Double(Int(2*fs) + 1) // thr_noise = 1/2 * mean(ecg in first 2)
        sig_level = thr_sig
        noise_level = thr_noise
        
        //initialize parameters for thresholds, bandpass filter
        
        var thr_sig1 : Double = 0
        var thr_noise1 : Double = 0
        var sig_level1 : Double
        var noise_level1 : Double
        
        // We initialize bandpass threshold parameters in the first two seconds
        
        for i in 0...Int(2*fs) {
            thr_noise1 += outputs1[i]
            if outputs1[i] > thr_sig1 {
                thr_sig1 = outputs1[i]
            }
        }
        thr_sig1 /= 3.0 // thr_sig1 = 1/3 * max(ecg in first 2 secs)
        thr_noise1 /= 2.0 * Double(Int(2*fs) + 1) // thr_noise = 1/2 * mean(ecg in first 2)
        sig_level1 = thr_sig1
        noise_level1 = thr_noise1
        
        // Thresholding and decision rule
        
        var beat_C = 0
        var beat_C1 = 0
        var noise_count = 0
        for i in 0..<LLp {
            // Locate the corresponding peak in the filtered signal
            
            var y_i : Double = 0
            var x_i : Int = 0
            
            if rpeaks[i].0 - Int(round(0.15 * fs)) >= 1 && rpeaks[i].0 <= n {
                (y_i, x_i) = maximum(input: outputs1, start: rpeaks[i].0 - Int(round(0.15 * fs)), end: rpeaks[i].0)
            } else {
                if i == 0 {
                    (y_i, x_i) = maximum(input: outputs1, start: 0, end: rpeaks[i].0)
                    ser_back = 1
                } else if rpeaks[i].0 >=  n - 1 {
                    (y_i, x_i) = maximum(input: outputs3, start: rpeaks[i].0 - Int(round(0.15 * fs)), end: Int(n2))

                }
            }
        
        
            // Update the heart rate
            
            if beat_C >= 9 {
    //            var diffRR : [Int] = []
                var tempSum1 : Int = 0
                for j in stride(from: beat_C - 9, through: beat_C - 1, by: 1) {
                    tempSum1 += (qrs_i[j+1] - qrs_i[j])
                }
                mean_RR = Double(tempSum1) / Double(9) // mean of differences
                let comp : Int = qrs_i[beat_C - 1] - qrs_i[beat_C - 2]
                
                if Double(comp) <= 0.92*mean_RR || Double(comp) >= 1.16*mean_RR {
                    // lower down thresholds to detect better in MVI
                    thr_sig *= 0.5
                    thr_sig1 *= 0.5
                } else {
                    m_selected_RR = mean_RR // the latest regular beats mean
                }
            }
            
            // calculate the mean last 8 R waves to ensure that QRS is not nil
            
            var test_m : Double
            if m_selected_RR > 0 {
                test_m = m_selected_RR
            } else if mean_RR > 0 && m_selected_RR == 0 {
                test_m = mean_RR
            } else {
                test_m = 0.0
            }
            
            if test_m > 0 {
                if rpeaks[i].0 - qrs_i[beat_C - 1] >= Int(round(1.66 * test_m)) {
                    var pks_temp : Double
                    var locs_temp : Int
                    (pks_temp, locs_temp) = maximum(input: outputs3, start: qrs_i[beat_C - 1] + Int(round(0.2 * fs)), end: rpeaks[i].0 - Int(round(0.2 * fs)))
                    locs_temp = qrs_i[beat_C - 1] + Int(round(02 * fs)) + locs_temp - 1
                    
                    if pks_temp > thr_noise {
                        beat_C += 1
                        qrs_c[beat_C - 1] = pks_temp
                        qrs_i[beat_C - 1] = locs_temp
                        // locate in filtered sig
                        var y_i_t : Double
                        var x_i_t : Int
                        if locs_temp <= Int(n) - 1 {
                            (y_i_t, x_i_t) = maximum(input: outputs1, start: locs_temp - Int(round(0.15 * fs)) - 1, end: locs_temp - 1)
                        } else {
                            (y_i_t, x_i_t) = maximum(input: outputs1, start: locs_temp - Int(round(0.15 * fs)) - 1, end: Int(n) - 1)
                        }
                        // Band pass sig threshold
                        if y_i_t > thr_noise1 {
                            beat_C1 += 1
                            qrs_i_raw[beat_C1 - 1] = locs_temp - Int(round(0.15 * fs)) + x_i_t - 1
                            qrs_amp_raw[beat_C1 - 1] = y_i_t
                            sig_level1 = 0.25 * y_i_t + 0.75 * sig_level1
                        }
                        sig_level = 0.25*pks_temp + 0.75*sig_level
                    }
                }
            }
            
            // find noise and qrs peaks
            
            if rpeaks[i].1 >= thr_sig {
                // if no qrs in 360ms of the previous qrs see if t wave
                if beat_C >= 3 {
                    if rpeaks[i].0 - qrs_i[beat_C - 1] <= Int(round(0.36 * fs)) {
                        let diff1 = diff(input: outputs3, length: Int(n2))
                        let slope1 = mean(input: diff1, start: rpeaks[i].0 - Int(round(0.075 * fs)), end: rpeaks[i].0)
                        let slope2 = mean(input: outputs3, start: qrs_i[beat_C - 1] - Int(round(0.075 * fs)), end: qrs_i[beat_C])
                        if abs(slope1) <= abs(0.5 * slope2) {
                            noise_count += 1
                            nois_c[noise_count - 1] = rpeaks[i].1
                            nois_i[noise_count - 1] = rpeaks[i].0
                            skip = 1
                            // adjust noise levels
                            noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                            noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
                        } else {
                            skip = 0
                        }
                    }
                }
                // skip is 1 when a T wave is detected
                if skip == 0 {
                    beat_C += 1
                    qrs_c[beat_C - 1] = rpeaks[i].1
                    qrs_i[beat_C - 1] = rpeaks[i].0
                
                    // bandpass filter check threshold
                    if y_i >= thr_sig1 {
                        beat_C1 += 1
                        if ser_back == 1 {
                            qrs_i_raw[beat_C1 - 1] = x_i
                        } else {
                            qrs_i_raw[beat_C1 - 1] = rpeaks[i].0 - Int(round(0.15 * fs)) + x_i - 1
                        }
                        qrs_amp_raw[beat_C1 - 1] = y_i
                        sig_level1 = 0.125 * y_i + 0.875 * sig_level1
                    }
                    sig_level = 0.125 * rpeaks[i].1 + 0.875 * sig_level
                }
            } else if thr_noise <= rpeaks[i].1 && rpeaks[i].1 < thr_sig {
                noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
            } else if rpeaks[i].1 < thr_noise {
                noise_count += 1
                nois_c[noise_count - 1] = rpeaks[i].1
                nois_i[noise_count - 1] = rpeaks[i].0
                noise_level1 = 0.125 * y_i + 0.875 * noise_level1
                noise_level = 0.125 * rpeaks[i].1 + 0.875 * noise_level
            }
            
            // adjust the threshold with SNR
            
            if noise_level != 0 || sig_level != 0 {
                thr_sig = noise_level + 0.25 * (abs(sig_level - noise_level))
                thr_noise *= 0.5
            }
            
            // adjust the threshold with SNR for bandpassed signal
            
            if noise_level1 != 0 || sig_level1 != 0 {
                thr_sig1 = noise_level1 + 0.25 * (abs(sig_level1 - noise_level1))
                thr_noise1 *= 0.5
            }
            
            // take a track of thresholds of smoothed signal
            sigl_buf[i] = sig_level
            noisl_buf[i] = noise_level
            thrs_buf[i] = thr_sig
           
            // take a track of thresholds of filtered signal
            sigl_buf1[i] = sig_level1
            noisl_buf1[i] = noise_level1
            thrs_buf1[i] = thr_sig1
            
            //reset parameters
            skip = 0
            ser_back = 0
            
        }
        print("It's time...")
        for ii in qrs_i_raw {
            print(ii)
        }
        for jj in qrs_i {
            print(jj)
        }
        
        
        
        
        
        
        
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
    func interpolate(inputArray: [Double], step: Double) -> [CDouble]{
        // Make a 1-d linear interpolation on an array, with selected step
        
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
    
    func findLocalMaxima(input: UnsafeMutablePointer<Double>, n: Int, minDist: Int) -> [(Int,CDouble)]{
        // A function that returns the local maxima of an input.
        // input: The input signal
        // n: The length of the signal
        // minDist: The minimum allowed distance between successive peaks in samples
        
        var peaks : [(Int, CDouble)] = []
        if n > 2 {
            for i in 1..<(n-1) {
                if input[i] > input[i-1] && input[i] > input[i+1] {
                    // We have a local maximum, now check distance
                    if peaks.isEmpty {
                        peaks.append((i, input[i]))
                    } else if i > minDist + peaks.last!.0 {
                        peaks.append((i, input[i]))
                    } else {
                        if input[i] > peaks.last!.1 {
                            peaks.removeLast()
                            peaks.append((i, input[i]))
                        }
                    }
                    
                }
            }
        }
        return peaks
    }
    
    func maximum(input: UnsafeMutablePointer<Double>, start: Int, end: Int, ignoreStart: Bool = true) -> (Double, Int){
        var tempMax : Double = 0.0
        var tempMaxInd : Int = 0
        for j in stride(from: start, through: end, by: 1) {
            if tempMax < input[j] {
                tempMax = input[j]
                tempMaxInd = j
            }
        }
        if ignoreStart {
            tempMaxInd -= start
        }
        if end < start {
            print("Error in maximum, end must be higher than the start")
            print(String(format: "Start: %d", start))
            print(String(format: "End: %d", end))
        }
        return (tempMax, tempMaxInd)
    }
    
    func maximum(input: [Double], start: Int, end: Int) -> (Double, Int){
        var tempMax : Double = 0.0
        var tempMaxInd : Int = 0
        for j in stride(from: start, through: end, by: 1) {
            if tempMax < input[j] {
                tempMax = input[j]
                tempMaxInd = j
            }
        }
        if end < start {
            print("Error in maximum, end must be higher than the start")
            print(String(format: "Start: %d", start))
            print(String(format: "End: %d", end))
        }
        return (tempMax, tempMaxInd)
    }
    
    func mean(input: [Double], start: Int, end: Int) -> Double{
        // Returns the mean of input, only including values from start through end
        var tempSum : Double = 0.0
        if end >= start {
            for j in stride(from: start, through: end, by: 1) {
                tempSum += input[j]
            }
            return tempSum / Double(end - start + 1)
        } else {
            print("Error in average, end must be higher than start.")
            print(String(format: "Start: %d", start))
            print(String(format: "End: %d", end))
            return 0.0
        }
    }
    
    func mean(input: UnsafeMutablePointer<Double>, start: Int, end: Int) -> Double{
        // Returns the mean of input, only including values from start through end
        var tempSum : Double = 0.0
        if end >= start {
            for j in stride(from: start, through: end, by: 1) {
                tempSum += input[j]
            }
            return tempSum / Double(end - start + 1)
        } else {
            print("Error in average, end must be higher than start.")
            print(String(format: "Start: %d", start))
            print(String(format: "End: %d", end))
            return 0.0
        }
    }
    
    func diff(input: [Double], length: Int) -> [Double] {
        var res : [Double] = []
        for i in 0..<length - 1 {
            res.append(input[i+1] - input[i])
        }
        // returns an array of length - 1 elements
        return res
    }
    
    func diff(input: UnsafeMutablePointer<Double>, length: Int) -> [Double] {
        var res : [Double] = []
        for i in 0..<length - 1 {
            res.append(input[i+1] - input[i])
        }
        // returns an array of length - 1 elements
        return res
    }
    
    

    
}





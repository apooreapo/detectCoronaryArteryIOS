//
//  K.swift
//  diplomaThesis
//
//  Created by Apostolou Orestis on 24/3/21.
//
//  A file including all constants in the project.

import Foundation


/// A file including all constants in the project.
struct K {
    static let segueAnalyzeECGIdentifier : String = "analyzeECG"
    static let segueAnalyzeAllIdentifier : String = "analyzeAll"
    static let segueCheckStatisticsIdentifier : String = "checkStatistics"
    static let segueLoadMore : String = "loadMore"
    static let basicQueueID : String = "basicQueue"
    static let helpingQueueID : String = "helpingQueue"
    static let ticImageName : String = "tic.png"
    static let CADColorName : String = "CADColor"
    static let noCADColorName : String = "NoCADColor"
    static let undefinedColorName : String = "UndefinedCADColor"
    static let finalCADImageName : String = "cad_final"
    static let finalNoCADImageName : String = "no_cad_final"
    static let finalQuestionImageName : String = "question_final"
    static let finalCADMessage : String = "You show some signs of CAD."
    static let finalNoCADMessage : String = "You show no signs of CAD!"
    static let finalUndefinedMessage : String = "The algorithm result is uncertain.\nPlease check some more ECGs."
    static let finalSmallNumberMessage : String = "The result is undefined.\nPlease check at least 10 ECGs."
    
    struct UltraShortModel {
        static let input_names : [String] = ["SDRR", "AverageHeartRate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HRMaxMin", "LFEnergy", "LFEnergyPercentage", "HFEnergy", "HFEnergyPerentage", "PoincareSD1", "PoincareSD2", "PoincareRatio", "PoincareEllipsisArea", "MeanApproximateEntropy", "StdApproximateEntropy", "MeanSampleEntropy", "StdSampleEntropy", "LFPeak", "HFPeak", "LFHFRatio"]
        static let input_names_R_style : [String] = ["SDRR", "Average.Heart.Rate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HR.max...HR.min", "LF.Energy", "LF.Energy.Percentage", "HF.Energy", "HF.Energy.Percentage", "Poincare.sd1", "Poincare.sd2", "Poincare.ratio", "Poincare.Ellipsis.Area", "Mean.Approximate.Entropy", "Standard.Deviation.of.Approximate.Entropy", "Mean.Sample.Entropy", "Standard.Deviation.of.Sample.Entropy", "LF.Peak", "HF.Peak", "LF.HF.Energy"]
        
        static let input_mean_values : [Double] = [260.837233, 73.764933, 39.056172, 18.083052, 0.110014, 29.211243, 0.186182, 13.008474, 0.000006, 0.011177, 0.000012, 0.022042, 20.554573, 48.745293, 2.777099, 3982.354109, 0.375404, 0.041101, 0.287958, 0.042700, 0.106875, 0.261495, 1.032443]
        static let input_std_values: [Double] = [1263.254101, 14.435702, 24.239003, 12.848319, 0.168593, 21.047730, 0.074654, 7.060699, 0.000035, 0.027656, 0.000059, 0.049045, 14.785053, 31.288907, 1.533726, 5552.921004, 0.136439, 0.038277, 0.152203, 0.042640, 0.028149, 0.074705, 1.542319]
        static let positiveResult : String = "Yes"
        static let negativeResult : String = "No"
        static let errorResult : String = "Error"
        static let smallNumberResult : String = "NumberError"
    
        static let CADImageName : String = "health_test-512-CAD-veggies"
        static let noCADImageName : String = "health_test-512-noCAD"
        static let noResultImageName : String = "health_test-512-question"
        static let noCADResultMessage : String = "It seems that this ECG shows no signs of Coronary Artery Disease!"
        static let CADResultMessage : String = "Hmm, it seems that this ECG shows some signs of Coronary Artery Disease. Please try to repeat the process with more recordings. If this result continues to show up, maybe it's time for some broccoli!"
        static let noResultMessage : String = "We seem to have a problem calculating your results. Please try again with another sample."
        static let badQualityMessage : String = "It seems that the quality of the recording is not that good. Please try again with another recording."
        
        static let PCAComponents : [[Double]] =  [[-0.0155892326, -0.229583911, 0.316197518, 0.348438196, 0.32619897, 0.357311258, -0.211620195, 0.138266551, -0.0128931748, -0.0176500571, -0.0249501447, -0.0484049684, 0.356748024, 0.280235112, -0.0761602985, 0.336968681, -0.195306815, -0.0787953116, -0.197605861, -0.0955139763, 0.0508135633, -0.041200902, 0.0477897844],
            [0.0445642049, 0.203770793, 0.208163838, 0.0550237958, 0.000202500141, 0.0199767261, -0.122445528, 0.331270569, 0.155008477, 0.180639941, 0.17494203, 0.20889018, 0.0168800973, 0.233745181, 0.250534881, 0.120341568, 0.322363643, 0.384919437, 0.310016995, 0.40021411, 0.0944293275, -0.0284381243, -0.0619749464],
            [0.177278401, -0.0864334618, -0.0832557619, 0.0322052233, 0.0491235806, 0.0457157271, 0.111774496, -0.154401433, 0.489831491, 0.446394422, 0.463217788, 0.387980043, 0.043550154, -0.114339524, -0.162143326, -0.014686928, -0.10354958, -0.117003641, -0.0941402835, -0.111541073, -0.0551532181, -0.0888259605, 0.0993479933],
            [0.0384756278, -0.0891291336, 0.203904738, -0.194115009, -0.255919767, -0.224194571, -0.197029597, 0.1555056, 0.0850939533, 0.130037211, -0.0244236488, -0.0200942968, -0.22833128, 0.288424914, 0.528432861, -0.0474229222, -0.297381183, -0.101099849, -0.299575081, -0.143009588, -0.188565776, -0.179727404, 0.117809455],
            [0.0269275362, -0.164058782, -0.0427761379, 0.0145962787, 0.0452850354, 0.0336057016, 0.0194232852, -0.163831225, 0.0334112782, 0.217435959, -0.278356067, -0.262124884, 0.0358672445, -0.0571394915, -0.0897306628, -0.000957317495, 0.112395216, 0.21217408, 0.11342918, 0.217668595, -0.242228299, -0.414069111, 0.620245525],
            [0.567985516, -0.0631371006, 0.0573812332, 0.0734895321, 0.0227984829, 0.0317066178, 0.255799486, -0.0551584206, -0.0380760178, -0.0993714376, -0.0139760068, -0.0782084887, 0.0269379775, 0.0453205674, 0.0355962524, 0.0946315351, -0.0352994639, 0.141160784, -0.0277068609, 0.124051317, -0.646396553, 0.221935446, -0.244256176],
            [0.476171387, 0.372685657, 0.002318786, 0.0309298161, 0.00641875201, -0.00164826879, 0.127313365, 0.272889369, 0.111612319, 0.0578965116, -0.079003971, -0.262394243, -0.00302994263, 0.00269735138, 0.0107378803, 0.0163934515, -0.00720203923, -0.171726706, 0.00530131725, -0.162939314, 0.314690977, 0.329268747, 0.433374208],
            [-0.490062592, -0.103672659, 0.0366584763, -0.0114306116, 0.0107603067, -0.00023365995, -0.0380912899, -0.0628339884, 0.163626598, 0.128001914, 0.0132309567, -0.0417369916, -2.79167643e-05, 0.0393360681, 0.0721270576, 0.0212412065, 0.0306115922, 0.0182639832, 0.0487906613, 0.032118764, -0.288532959, 0.727301092, 0.270044974],
            [-0.327730719, 0.393589106, 0.0368821142, 0.100293909, 0.0352762009, 0.0414776351, 0.30827215, 0.26880126, 0.105471148, -0.0593648138, 0.0811515058, -0.109687246, 0.0395088696, 0.0277999615, 0.0145853898, 0.127733365, 0.154782249, -0.336248512, 0.195471079, -0.268318728, -0.405361129, -0.302203109, -0.0318433947],
            [0.0654958681, 0.0116075498, -0.105169256, -0.0118025293, 0.001787341, 0.0127950053, -0.574055628, 0.130162364, 0.449623734, 0.0746441423, -0.0649936861, -0.454599815, 0.0177294277, -0.112342961, -0.188914908, -0.201670229, 0.0706966988, -0.0396854641, 0.0611329558, -0.0270156198, -0.122804197, -0.0105441375, -0.321840277],
            [-0.218742581, 0.0182503524, 0.0338374005, 0.0233198326, -0.0264288801, -0.019910245, 0.521979622, -0.00649913068, 0.365440401, 0.0865751271, -0.086660635, -0.375655746, -0.0242690539, 0.0329944841, 0.0137924082, 0.0945507311, -0.247328042, 0.288945261, -0.270866904, 0.190655803, 0.247480521, -0.0412529628, -0.242333578],
            [-0.023814826, -0.000234015229, -0.024264291, -0.0222799067, 0.00222905277, -0.00165823648, -0.077106863, 0.023785315, 0.117963738, -0.64184257, 0.611347178, -0.174825903, -0.00704499521, -0.0360015657, -0.00546162695, -0.0679230581, -0.0952959073, 0.151447682, -0.097884172, 0.144649549, -0.0369898288, -0.0711038131, 0.294459329]]

    }
}

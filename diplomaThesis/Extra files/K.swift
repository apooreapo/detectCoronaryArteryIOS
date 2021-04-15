//
//  K.swift
//  diplomaThesis
//
//  Created by User on 24/3/21.
//

import Foundation


/// A file including all constants in the project.
struct K {
    static let segueAnalyzeECGIdentifier : String = "analyzeECG"
    static let segueLoadMore : String = "loadMore"
    static let basicQueueID : String = "basicQueue"
    static let helpingQueueID : String = "helpingQueue"
    
    struct UltraShortModel {
        static let input_names : [String] = ["SDRR", "AverageHeartRate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HRMaxMin", "LFEnergy", "LFEnergyPercentage", "HFEnergy", "HFEnergyPerentage", "PoincareSD1", "PoincareSD2", "PoincareRatio", "PoincareEllipsisArea", "MeanApproximateEntropy", "StdApproximateEntropy", "MeanSampleEntropy", "StdSampleEntropy", "LFPeak", "HFPeak", "LFHFRatio"]
        static let input_names_R_style : [String] = ["SDRR", "Average.Heart.Rate", "SDNN", "SDSD", "pNN50", "RMSSD", "HTI", "HR.max...HR.min", "LF.Energy", "LF.Energy.Percentage", "HF.Energy", "HF.Energy.Percentage", "Poincare.sd1", "Poincare.sd2", "Poincare.ratio", "Poincare.Ellipsis.Area", "Mean.Approximate.Entropy", "Standard.Deviation.of.Approximate.Entropy", "Mean.Sample.Entropy", "Standard.Deviation.of.Sample.Entropy", "LF.Peak", "HF.Peak", "LF.HF.Energy"]
        
        static let input_mean_values : [Double] = [332.667853, 73.831289, 39.158230, 18.888569, 0.119700, 30.505067, 0.189077, 13.150197, 0.000017, 0.015178, 0.000023, 0.025713, 21.459233, 48.271345, 2.712748, 4179.538407, 0.418022, 0.041360, 0.349318, 0.048279, 0.107741, 0.257443, 1.261402]
        static let input_std_values: [Double] = [1485.774291, 14.609442, 24.671579, 14.393699, 0.181992, 23.728926, 0.078652, 7.545351, 0.0001, 0.037111, 0.00011, 0.062399, 16.648792, 31.108626, 1.546339, 5853.908687, 0.169011, 0.036954, 0.230366, 0.047572, 0.028105, 0.074010, 2.177852]
        static let positiveResult : String = "Yes"
        static let negativeResult : String = "No"
        static let errorResult : String = "Error"
        static let CADImageName : String = "health_test-512-CAD-veggies"
        static let noCADImageName : String = "health_test-512-noCAD"
        static let noResultImageName : String = "health_test-512-question"
        static let noCADResultMessage : String = "Well done, it seems that this ECG shows no signs of Coronary Artery Disease!"
        static let CADResultMessage : String = "Hmm, it seems that this ECG shows some signs of Coronary Artery Disease. Maybe it's time for some broccoli!"
        static let noResultMessage : String = "We seem to have a problem calculating your results. Try again with another sample."
        
        static let PCAComponents : [[Double]] =  [[-0.00986091241,-0.192500288,0.345349517,0.358556894,0.336978092,0.36428995,-0.224509546,0.193388116,0.00350831283,0.00407680422,-0.00513293634,-0.0200800032,0.363568374,0.305595735,-0.0696431141,0.357052566,-0.10234162,-0.0274011116,-0.0893429972,-0.0347229449,0.0376472964,-0.0274739506,-0.00128447743],
        [0.124316943,0.212901508,0.10804906,0.0363460642,-0.00863793474,0.0042194778,-0.00880184495,0.250273427,0.20335052,0.241371189,0.236378896,0.250687848,0.00118641857,0.118041055,0.175610783,0.0551523742,0.380845642,0.365394904,0.369425482,0.421775093,-0.0156886315,-0.0217062006,-0.0602120366],
        [0.146387273,-0.183956437,-0.166673071,0.102688824,0.138436649,0.130483816,0.203230545,-0.274001233,0.345630795,0.356852425,0.32809932,0.262588854,0.131389333,-0.244451468,-0.382701507,-0.00670482662,0.0307836756,-0.209173985,0.0697411796,-0.123493472,-0.111066517,-0.0697099374,0.157776027],
        [-0.0227552122,-0.0571482081,0.134835473,-0.150117671,-0.170994372,-0.158301194,-0.207029815,0.101331526,0.215292089,0.252429061,0.314028695,0.329732564,-0.161052035,0.2097319,0.355172132,-0.0401332659,-0.354268571,-0.0694794941,-0.363571624,-0.182253423,0.0977242266,-0.165594203,-0.0165839047],
        [0.0342848025,0.182258569,-0.0844434749,0.0462688506,0.0622852754,0.054845206,0.0271350293,0.0440852454,-0.205221263,-0.203502536,0.287895063,0.345766943,0.0549358425,-0.113803305,-0.191127293,-0.012840706,-0.055775273,-0.028983187,-0.067796151,-0.0472958531,0.441484385,0.39376608,-0.497385382],
        [-0.20763267,0.231538639,-0.032522758,0.00162934158,0.0281333762,0.0092274617,0.0153204062,0.15061462,0.166069201,0.152893671,-0.0718974547,-0.120553997,0.0110334933,-0.036511139,-0.0556006653,-0.0135109326,-0.00127100153,0.00260261801,-0.0135851683,-0.025022737,0.623650542,0.22205653,0.603296866],
        [0.623317131,0.177352458,0.084859399,0.0153724288,-0.0353876033,-0.0230935886,0.136996318,0.179734063,0.07575471,0.000366181052,0.000302062914,-0.11586926,-0.0300895162,0.0930527724,0.158938417,0.0495639481,-0.0622968066,-0.202398573,-0.023812981,-0.175505992,-0.263651299,0.543778032,0.147843088],
        [-0.654821776,-0.101471748,0.0292326164,-0.0213482637,-0.00906389006,-0.0103856995,-0.101299759,-0.0395234989,0.219951791,0.0601764876,0.0752308988,0.00149078693,-0.00679797916,0.040382231,0.0886422892,0.000783932154,0.0819532096,-0.0904450145,0.0911939421,-0.0423191764,-0.345827569,0.573867596,-0.0804135987],
        [-0.18860953,0.48704084,-0.00829906457,0.0494541107,0.0288445095,0.0253342401,0.109310128,0.340883824,0.152248672,-0.0197133167,0.0172160292,-0.111195862,0.0250513196,-0.0191231155,0.0177875022,0.028746763,0.138106804,-0.457168413,0.184106339,-0.344987798,-0.0557228276,-0.353247259,-0.218716068],
        [0.208194094,-0.0937504187,-0.0824116236,-0.0441454972,-0.00660797538,-0.0115501557,-0.42150553,0.00114774111,0.525873778,0.153018958,-0.213794813,-0.382949177,-0.00750423068,-0.0814842802,-0.136623059,-0.163917329,-0.00330984978,0.0516602931,-0.012633702,0.0292565383,0.194404703,0.0591573883,-0.414421424],
        [-0.13797327,0.263837651,-0.013341207,0.0727056358,0.0432540422,0.0353660235,0.527836668,0.0948510684,0.236912983,0.0884402965,-0.0759814254,-0.139532771,0.0315874841,-0.0355013112,-0.128894915,0.107853997,-0.338725585,0.393380672,-0.390131474,0.14685014,-0.157203976,-0.00823586094,-0.165622139],
        [0.00979365638,-0.30030468,0.170922074,-0.0220112401,-0.0534255637,-0.0397529983,0.511292445,-0.312646771,0.216240239,-0.0990576959,0.0137508952,-0.161533346,-0.0465666426,0.199652653,0.32769601,0.232216058,0.123788778,-0.134067818,0.167143221,-0.0354451875,0.361985083,-0.000390458651,-0.191578651]]
    }
}

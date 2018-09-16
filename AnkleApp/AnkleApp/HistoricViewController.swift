//
//  HistoricViewController.swift
//  AnkleApp
//
//  Created by John Du on 1/11/17.
//  Copyright © 2017 John Du. All rights reserved.
//

import Cocoa
import Charts

class HistoricViewController: NSViewController {
    
    let pastWeek: [String] = ["2017-11-1", "2017-10-31", "2017-10-30", "2017-10-29", "2017-10-28",
                              "2017-10-27", "2017-10-26"]
    @IBOutlet var dayLabel: NSTextField!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet var exerTime: NSTextField!
    @IBOutlet var sitTime: NSTextField!
    var todayExerTime: Int = 0; var todaySitTime: Int = 0;
    var dayIndex: Int = 0 {
        didSet {
            changeDay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.noDataText = "There is no data for this graph."
        
        changeDay()
    }

    func setChart(dataLabels: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataLabels.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]), data:dataLabels[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        let chartData = BarChartData()
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Seconds")
        chartData.addDataSet(chartDataSet)
        
        self.barChartView.xAxis.labelCount = self.chartXVals().count
        self.barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return self.chartXVals()[Int(value)] }
        barChartView.data = chartData
        
    }
    
    func chartXVals() ->[String] {
        return ["Sitting", "Exercising"]
    }
    
    func changeDay(){
        if(dayIndex==1) {
            exerTime.stringValue = "00:04:10"
            sitTime.stringValue = "00:11:08"
            
            var types = ["Sitting", "Exercising"]
            let v = [Double(668), Double(250)]
            
            
            setChart(dataLabels: types, values: v)
        } else if (dayIndex == 0) {
            exerTime.stringValue = formatTime(time:TimeInterval(todayExerTime));
            sitTime.stringValue = formatTime(time:TimeInterval(todaySitTime));
            
            var types = ["Sitting", "Exercising"]
            let v = [Double(todaySitTime), Double(todayExerTime)]
            
            
            setChart(dataLabels: types, values: v)
        } else if (dayIndex==2){
            exerTime.stringValue = "00:01:42"
            sitTime.stringValue = "00:5:19"
            
            var types = ["Sitting", "Exercising"]
            let v = [Double(319), Double(102)]
            
            
            setChart(dataLabels: types, values: v)
        } else {
            exerTime.stringValue = "00:00:00"
            sitTime.stringValue = "00:00:00"
            
            var types = ["Sitting", "Exercising"]
            let v = [Double(0), Double(0)]
            
            
            setChart(dataLabels: types, values: v)
        }
        dayLabel.stringValue = pastWeek[dayIndex]
        
        /*let dayUrl = NSURL(string: "http://spark-au.australiasoutheast.cloudapp.azure.com:8080/spark/cushionList/1fcb8a4f7c671a154f793c6cc0bfcde1/"+pastWeek[dayIndex]);
        let dayRequest = NSMutableURLRequest(url:dayUrl! as URL);
        dayRequest.httpMethod = "GET"
        let dayRequestTask = URLSession.shared.dataTask(with: dayRequest as URLRequest) {
            data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(String(describing: responseString))")
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    //print(convertedJsonIntoDict)
                    /*if let cushion = convertedJsonIntoDict["value"] as? Int {
                        print(String(Date().timeIntervalSinceReferenceDate)+" cushion: \(cushion)")
                        DispatchQueue.main.async() {
                            self.cushState = cushion
                        }
                    }*/
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        dayRequestTask.resume()*/
        
    }
    
    func formatTime(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

extension HistoricViewController {
    // Storyboard instantiation
    static func freshController(s: Int, e: Int) -> HistoricViewController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "HistoricViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? HistoricViewController else {
            fatalError("Why cant I find HistoricViewController? - Check Main.storyboard")
        }
        viewcontroller.todaySitTime = s; viewcontroller.todayExerTime = e;
        return viewcontroller
    }
}

extension HistoricViewController {
    //Actions
    @IBAction func previous(_ sender: NSButton) {
        if (dayIndex < 6) {
            dayIndex+=1
        }
    }
    
    @IBAction func next(_ sender: NSButton) {
        if (dayIndex > 0) {
            dayIndex-=1
        }
    }
    
    @IBAction func quit(_ sender: NSButton) {
        dismissViewController(self)
    }
}

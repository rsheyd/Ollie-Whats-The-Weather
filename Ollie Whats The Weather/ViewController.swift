//
//  ViewController.swift
//  Ollie Whats The Weather
//
//  Created by Roman Sheydvasser on 3/24/18.
//  Copyright © 2018 RLabs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var whatToWear: UITextView!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var todayHotTempLbl: UILabel!
    @IBOutlet weak var todayColdTempLbl: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourlyLineChart: LineChartView!
    let formatter = DateFormatter()
    let dateFormatter = DateFormatter()
    var clockTimer = Timer()
    var tempRefreshTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        clockTimer.invalidate()
        tempRefreshTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runClockTimer()
        runTempRefreshTimer()
    }
    
    func runTempRefreshTimer() {
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        updateTempsAndDate()
        // update temperature every 30 minutes
        tempRefreshTimer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: (#selector(ViewController.updateTempsAndDate)), userInfo: nil, repeats: true)
    }
    
    func runClockTimer() {
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        updateClock()
        // update clock every 60 seconds
        clockTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: (#selector(ViewController.updateClock)), userInfo: nil, repeats: true)
    }
    
    @objc func updateClock() {
        //this is run every 60 seconds
        let currentDateTime = Date()
        timeLabel.text = formatter.string(from: currentDateTime)
        print(whatToWear.text)
    }
    
    func setHourlyChart(hours: [String], temps: [Double]){
        hourlyLineChart.setLineChartData(xValues: hours, yValues: temps, label: "Hourly")
        
        hourlyLineChart.noDataText = "You need to provide data for the chart."
        hourlyLineChart.xAxis.drawAxisLineEnabled = false
        hourlyLineChart.xAxis.labelPosition = .bottom
        hourlyLineChart.leftAxis.drawAxisLineEnabled = false
        hourlyLineChart.rightAxis.drawAxisLineEnabled = false
        hourlyLineChart.legend.enabled = false
        hourlyLineChart.chartDescription?.enabled = false
        hourlyLineChart.xAxis.drawGridLinesEnabled = false
        hourlyLineChart.leftAxis.drawGridLinesEnabled = false
        hourlyLineChart.rightAxis.drawGridLinesEnabled = false
        hourlyLineChart.leftAxis.drawLabelsEnabled = false
        hourlyLineChart.rightAxis.drawLabelsEnabled = false
        hourlyLineChart.xAxis.labelFont = UIFont.systemFont(ofSize: 19)
        
        DispatchQueue.main.async {
            self.hourlyLineChart.notifyDataSetChanged()
        }
    }

    @objc func updateTempsAndDate() {
        Weather.shared.getCurrentTemp() { currentTemp, condition in
            self.currentTempLbl.text = currentTemp
            self.condition.text = condition
            Weather.shared.getTodayTemps() { low, high in
                self.todayHotTempLbl.text = high
                self.todayColdTempLbl.text = low
                self.recommendClothing(currentTemp, low, high)
            }
        }

        Weather.shared.getHourly() { hourlyForecasts in
            var temps: [Double] = []
            var hours: [String] = []
            for hour in hourlyForecasts {
                temps.append(hour.temp)
                guard var hourNum = Int(hour.time) else { continue }
                if hourNum > 12 { hourNum = hourNum - 12 }
                var ampmHour = String(hourNum) + hour.ampm
                if ampmHour == "0AM" { ampmHour = "12AM" }
                hours.append(ampmHour)
            }
            self.setHourlyChart(hours: hours, temps: temps)
        }
        
        let currentDate = Date()
        dateLabel.text = dateFormatter.string(from: currentDate)
    }
    
    func recommendClothing(_ current: String, _ low: String, _ high: String) {
        guard let low = Int(low), let high = Int(high), let current = Int(current) else {
            whatToWear.text = "Could not get the high and low temperatures."
            return
        }
        
        var midTemp = 999
        
        if current < low {
            midTemp = current
        } else {
            midTemp = (low + high) / 2
        }
        
        var wear = ""
        switch midTemp {
        case 80..<120: wear = "See if it's okay to wear shorts"
        case 70..<80: wear = "Long-sleeve shirt, or button down over an undershirt"
        case 60..<70: wear = "Light jacket/hoodie"
        case 50..<60: wear = "Light jacket + 1-2 thin layers"
        case 40..<50: wear = "Medium coat + 1-2 thin layers"
        case 30..<40: wear = "Medium coat, light hat, light gloves, light scarf"
        case 20..<30: wear = "Heavy coat, hat, gloves, scarf"
        case -100..<20: wear = "It is way cold, consider leggings and shit"
        default: wear = "I did not take into account this temperature..."
        }
        whatToWear.text = wear
    }
    
    @IBAction func changeApiKeyPressed(_ sender: Any) {
        self.present(Weather.shared.changeApiKey(), animated: true) {
            self.updateTempsAndDate()
        }
    }
}


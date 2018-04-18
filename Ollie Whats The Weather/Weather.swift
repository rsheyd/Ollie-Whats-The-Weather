//
//  Weather.swift
//  Ollie Whats The Weather
//
//  Created by Roman Sheydvasser on 3/29/18.
//  Copyright © 2018 RLabs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Weather {
    static let shared = Weather()
    
    var apiKey = ""
    let baseUrl = "https://api.wunderground.com/api/"
    
    var todayHigh: String?
    var todayLow: String?
    
    struct hourForecast {
        let temp: Double
        let time: String
        let ampm: String
    }
    
    private init() {
        loadApiKey()
    }
    
    func loadApiKey() {
        if let apiKey = UserDefaults.standard.string(forKey: "apiKey"), !apiKey.isEmpty {
            self.apiKey = apiKey
        }
    }
    
    func changeApiKey() -> UIAlertController {
        let alert = UIAlertController(title: "API Key", message: "Enter Wunderground API key.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "API Key"
        })
        alert.textFields?.first?.text = apiKey
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let apiKey = alert.textFields?.first?.text {
                print("Your API key: \(apiKey)")
                UserDefaults.standard.set(apiKey, forKey: "apiKey")
                self.apiKey = apiKey
            }
        }))
        return alert
    }

    func getCurrentTemp(completion: @escaping (String, String) -> Void) {
        let currentConditionsUrl = baseUrl + "\(apiKey)/conditions/q/11215.json"
        Alamofire.request(currentConditionsUrl).responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                print(json)
                let weatherData = json["current_observation"]
                if let currentTemp = weatherData["temp_f"].int,
                    let condition = weatherData["weather"].string {
                    print("current temp: \(currentTemp)")
                    completion(String(currentTemp), condition)
                }
            }
        }
    }
    
    func getTodayTemps(completion: @escaping (String, String) -> Void) {
        let forecastUrl = baseUrl + "\(apiKey)/forecast/q/11215.json"
        Alamofire.request(forecastUrl).responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                let weatherData = json["forecast"]["simpleforecast"]["forecastday"][0]
                if let low = weatherData["low"]["fahrenheit"].string,
                    let high = weatherData["high"]["fahrenheit"].string {
                    completion(low, high)
                }
            }
        }
    }
    
    func getHourly(completion: @escaping ([hourForecast]) -> Void) {
        let hourlyUrl = baseUrl + "\(apiKey)/hourly/q/11215.json"
        var hourForecasts: [hourForecast] = []
        Alamofire.request(hourlyUrl).responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                if let hourArr = json["hourly_forecast"].array {
                    for hour in 1...14 {
                        if hour % 2 == 0,
                            let temp = hourArr[hour]["temp"]["english"].string,
                            let time = hourArr[hour]["FCTTIME"]["hour"].string,
                            let ampm = hourArr[hour]["FCTTIME"]["ampm"].string,
                            let tempDouble = Double(temp) {
                            hourForecasts.append(hourForecast(temp: tempDouble, time: time, ampm: ampm))
                        }
                    }
                    completion(hourForecasts)
                } 
            }
        }
    }
}

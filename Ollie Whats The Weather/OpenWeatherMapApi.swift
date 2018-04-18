//
//  OpenWeatherMapApi.swift
//  Ollie Whats The Weather
//
//  Created by Roman Sheydvasser on 3/27/18.
//  Copyright © 2018 RLabs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class OpenWeather {
    
    let apiKey = ""
    
    func getNewTempFromOpenWeather() {
        //current conditions
        Alamofire.request("https://api.openweathermap.org/data/2.5/weather?zip=11215,us&units=imperial&APPID=\(apiKey)").responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                print(json)
            }
        }
        
        //16 day forecast
        Alamofire.request("https://api.openweathermap.org/data/2.5/forecast/daily?zip=11215&units=imperial&APPID=\(apiKey)").responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                print(json)
            }
        }
    }
    
    func getNewTempFromYahoo() {
        let baseUrl = "https://query.yahooapis.com/v1/public/yql?q="
        let yql_query = "select * from weather.forecast where woeid in (select woeid from geo.places(1) where text=\"brooklyn, ny\")"
        guard let valid_yql_query = yql_query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        let url = baseUrl + valid_yql_query + "&format=json"
        Alamofire.request(url).responseJSON { response in
            if let data = response.data,
                let json = try? JSON(data: data) {
                print("JSON: \(json)") // serialized json response
                let weatherData = json["query"]["results"]["channel"]["item"]
                if let currentTemp = weatherData["condition"]["temp"].string {
                    print("current temp: \(currentTemp)")
                    //self.currentTempLbl.text = currentTemp
                }
                
                if let todayHigh = weatherData["forecast"][0]["high"].string {
                    print("high temp: \(todayHigh)")
                    //self.todayHotTempLbl.text = todayHigh
                }
                
                if let todayLow = weatherData["forecast"][0]["low"].string {
                    print("low temp: \(todayLow)")
                    //self.todayColdTempLbl.text = todayLow
                }
            }
        }
    }
}

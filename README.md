# Ollie-Whats-The-Weather
Swift iOS weather/what to wear dashboard app.

Requires a Wunderground API key.

Retrieves new weather data every 30 minutes and has a working clock.

<img src="https://i.imgur.com/i1PUo5l.png" width="450">

Clothing temperature ranges (based on midpoint between high/low temp for the day, or current temp if that's lower than today's low):

        case 80..<120: wear = "See if it's okay to wear shorts"
        case 70..<80: wear = "Long-sleeve shirt, or button down over an undershirt"
        case 60..<70: wear = "Light jacket/hoodie"
        case 50..<60: wear = "Light jacket + 1-2 thin layers"
        case 40..<50: wear = "Medium coat + 1-2 thin layers"
        case 30..<40: wear = "Medium coat, light hat, light gloves, light scarf"
        case 20..<30: wear = "Heavy coat, hat, gloves, scarf"
        case -100..<20: wear = "It is way cold, consider leggings and shit"
        default: wear = "I did not take into account this temperature..."

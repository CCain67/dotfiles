#!/bin/bash

KEY="${OPENWEATHER_API_KEY}"
CITY="4513583"

# fetch the weather data in one line of pure chaos
weather_data=$(curl -s "http://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=$CITY&units=imperial")

# this requires the jq package to be installed
icon=$(echo "$weather_data" | jq -r '.weather[0].icon')
feels_like=$(echo "$weather_data" | jq -r '.main.feels_like')
temp=$(echo "$weather_data" | jq -r '.main.temp')
city=$(echo "$weather_data" | jq -r '.name')
country=$(echo "$weather_data" | jq -r '.sys.country')
humidity=$(echo "$weather_data" | jq -r '.main.humidity')
wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')
weather=$(echo "$weather_data" | jq -r '.weather[0].main')

echo "$icon $feels_like $temp $city $country $humidity $wind_speed $weather"

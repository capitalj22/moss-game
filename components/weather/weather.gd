extends Node

class_name Weather

@export var weatherType: WeatherManager.WeatherTypes = WeatherManager.WeatherTypes.NONE;
@export var windDirection: Vector2 = Vector2(0, 0);
@export var windSpeed: float = 0.0;
@export var intensity: float = 0.0;

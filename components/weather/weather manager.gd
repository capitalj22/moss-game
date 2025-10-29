extends Node2D

enum WeatherTypes {
	NONE,
	RAIN,
	LEAVES,
	SNOW
}

@export var weatherType: WeatherTypes = WeatherTypes.NONE;

var weather: Weather = Weather.new();

signal weatherChanged;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weather.intensity = 0;
	weather.windDirection = Vector2(0, 0);
	weather.windSpeed = 0;
	weather.weatherType = WeatherTypes.NONE;
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	

	if Input.is_key_pressed(KEY_KP_ADD):
		weather["intensity"] += 0.01
		weatherChanged.emit(weather)
	if Input.is_key_pressed(KEY_KP_SUBTRACT):
		weather["intensity"] -= 0.01
		weatherChanged.emit(weather)
	pass

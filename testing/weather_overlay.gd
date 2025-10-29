extends Sprite2D

func on_weather_changed(weather: Weather):
	print(weather)
	self.modulate.a = weather.intensity * 0.1;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WeatherManager.weatherChanged.connect(on_weather_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

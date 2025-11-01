extends GPUParticles2D




var seasonAssets = {
	SeasonManager.Seasons.WINTER:
		{
			"texture": preload("res://sprites/environment/particles/snow_1.png"),
			"material": preload("res://components/seasons/snow.tres"),
			"speed": 1.0,
			"amount": 200
		},
	SeasonManager.Seasons.FALL:
		{
			"texture": preload("res://sprites/environment/particles/leaf.png"),
			"material": preload("res://components/seasons/leaves.tres"),
			"speed": 1.0,
			"amount": 100
		},
	SeasonManager.Seasons.SUMMER:
		{
			"texture": preload("res://sprites/environment/particles/rain.png"),
			"material": preload("res://components/seasons/rain.tres"),
			"speed": 2.0,
			"amount": 500
		},
		
}

func on_weather_changed(weather: Weather):
	var mat: ParticleProcessMaterial = self.process_material;
	amount = weather.intensity * 100;
	mat.directional_velocity_max = weather.intensity
	mat.direction = Vector3(weather.intensity, weather.intensity, 0)
	
	
func on_season_changed(season: SeasonManager.Seasons):
	if seasonAssets.has(season):
		var assets = seasonAssets[season];
		texture = assets.texture;
		process_material = assets.material;
		amount = assets.amount;
		speed_scale = assets.speed
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SeasonManager.seasonChanged.connect(on_season_changed)
	WeatherManager.weatherChanged.connect(on_weather_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends GPUParticles2D




var seasonAssets = {
	SeasonManager.Seasons.WINTER:
		{
			"texture": preload("res://sprites/environment/particles/snow_1.png"),
			"material": preload("res://components/seasons/snow.tres")
		},
	SeasonManager.Seasons.FALL:
		{
			"texture": preload("res://sprites/environment/particles/leaf.png"),
			"material": preload("res://components/seasons/leaves.tres")
		},
	SeasonManager.Seasons.SUMMER:
		{
			"texture": preload("res://sprites/environment/particles/rain.png"),
			"material": preload("res://components/seasons/rain.tres")
		},
		
}

func on_weather_changed(weather: Weather):
	var mat: ParticleProcessMaterial = self.process_material;
	amount = weather.intensity * 100;
	mat.directional_velocity_max = weather.intensity
	mat.direction = Vector3(weather.intensity, weather.intensity, 0)
	
	
func on_season_changed(season: SeasonManager.Seasons):
	if seasonAssets.has(season):
		texture = seasonAssets[season].texture;
		process_material = seasonAssets[season].material;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SeasonManager.seasonChanged.connect(on_season_changed)
	WeatherManager.weatherChanged.connect(on_weather_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

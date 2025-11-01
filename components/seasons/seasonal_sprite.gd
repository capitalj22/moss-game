@icon("res://addons/custom_nodes/icon_season_sprite.svg")
extends Sprite2D

@export var summerTexture: Texture2D;
@export var fallTexture: Texture2D;
@export var winterTexture: Texture2D;

func on_season_changed(season: SeasonManager.Seasons):
	match(season):
		SeasonManager.Seasons.SUMMER:
			texture = summerTexture;
		SeasonManager.Seasons.FALL:
			texture = fallTexture;
		SeasonManager.Seasons.WINTER:
			texture = winterTexture;
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SeasonManager.seasonChanged.connect(on_season_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

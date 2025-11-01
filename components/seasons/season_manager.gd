extends Node2D

enum Seasons {
	SUMMER,
	FALL,
	WINTER
}
@export var season: Seasons = Seasons.SUMMER;

signal seasonChanged;

func changeSeason(newSeason: Seasons):
	season = newSeason;
	seasonChanged.emit(newSeason)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_7"):
		changeSeason(Seasons.SUMMER)
	if Input.is_action_just_pressed("debug_8"):
		changeSeason(Seasons.FALL)
	if Input.is_action_just_pressed("debug_9"):
		changeSeason(Seasons.WINTER)
	pass

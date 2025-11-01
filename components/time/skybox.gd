extends Parallax2D



@onready var day_sky: Sprite2D = $"day sky"
@onready var night_sky: Sprite2D = $"night sky"
@onready var sunrise: Sprite2D = $sunrise
@onready var stars: Sprite2D = $stars

@export var dayCurve: Curve;
@export var nightCurve: Curve;
@export var sunriseCurve: Curve;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tod = TimeOfDayManager.timeOfDay;
	day_sky.modulate.a = dayCurve.sample_baked(tod)
	night_sky.modulate.a = nightCurve.sample_baked(tod)
	sunrise.modulate.a = sunriseCurve.sample_baked(tod)
	stars.modulate.a = nightCurve.sample(tod)
	stars.offset = Vector2(tod * 10, tod * 10)
	pass

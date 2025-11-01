extends Node2D

@export var onCurve: Curve = preload("res://components/time/lampOverTime.curve.tres");
@onready var illumination: PointLight2D = $illumination
@onready var onSprite: Sprite2D = $on

@export var illuminationSources: Array[PointLight2D] = [];

var isOn = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if onCurve.sample_baked(TimeOfDayManager.timeOfDay) > 0.2:
		turn_on()
	else:
		turn_off();
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if onCurve.sample_baked(TimeOfDayManager.timeOfDay) > 0.2:
		if !isOn:
			turn_on()
	else:
		if (isOn):
			turn_off();
	
func turn_off():
	isOn = false;
	onSprite.visible = false;
	var onTween = create_tween().tween_property(illumination, "energy", 0, 0.1)
	
	for source in illuminationSources:
		var srcOnTween = create_tween().tween_property(source, "energy", 0, 0.1)
	
func turn_on():
	isOn = true;
	onSprite.visible = true;
	for source in illuminationSources:
		var onTween = create_tween().tween_property(source, "energy", 2, 0.1)
		
	var srcOnTween = create_tween().tween_property(illumination, "energy", 2, 0.1)

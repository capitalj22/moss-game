extends Node
@export var fogOverTime: Curve = preload("res://components/weather/fog/fog-over-time.curve.tres")

var density = 1;
var amount = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	amount = fogOverTime.sample_baked(TimeOfDayManager.timeOfDay)
	
	update();
	pass
	
func update():
	self.modulate.a = density * amount;

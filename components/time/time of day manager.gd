extends Node

var timeOfDay = 9;
var daySpeed = 0.05;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timeOfDay += delta * daySpeed;
	
	if timeOfDay >= 24:
		timeOfDay = 0;
		
	pass

extends PointLight2D

@export var darknessCurve: Curve;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_darkness(darknessCurve.sample_baked(TimeOfDayManager.timeOfDay))
	pass

func update_darkness(amt):
	self.energy = amt

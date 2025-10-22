extends Sprite2D

class_name EnemyColorMod;
@export var flashTime = 0.1;

func flash() -> void:
	self.self_modulate = Color(255, 255, 255, 1);
	var flash = create_tween().tween_property(self, "self_modulate", Color(0, 0, 0, 0), flashTime)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

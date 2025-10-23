extends Camera2D

var shakeStrength = 0;

func on_player_damaged():
	shake(10);

func on_player_attacked():
	shake(2);
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_first_node_in_group("player").damaged.connect(on_player_damaged)
	get_tree().get_first_node_in_group("player").hit_connected.connect(on_player_attacked)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_1"):
		shake(10);
		
	if (shakeStrength > 0):
		shakeStrength = lerpf(shakeStrength, 0, 5 * delta)
		
		offset = Vector2(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength))
	pass

func shake(amt: float):
	shakeStrength = amt;

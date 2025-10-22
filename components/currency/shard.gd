extends RigidBody2D

class_name Shard;

var player: Sherma;

var hasBeenCollected = false;
var hasSettled = false;
var pickupTimer = 0;

func checkForPlayer():
	if get_tree().get_nodes_in_group("player"):
		player = get_tree().get_nodes_in_group("player")[0]
		
func on_picked_up():
	queue_free();
	
func goToPlayer() -> void:
	var twPickup = create_tween().tween_property(self, "global_position", Vector2(player.global_position.x, player.global_position.y - 20), 0.1).set_ease(Tween.EASE_IN)
	twPickup.finished.connect(on_picked_up)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	angular_velocity = 3.0;

	linear_velocity = Vector2(randf_range(-100, 100), randf_range(-50, -300))
	
func _process(delta: float) -> void:
	checkForPlayer()
	
	pickupTimer += delta;
	if (pickupTimer >= 1):
		hasSettled = true;
	
	if (player):
		if (hasSettled && !hasBeenCollected && (player.global_position - global_position).length() < 60):
			goToPlayer()
			hasBeenCollected = true;
	
func _physics_process(delta: float) -> void:
	if (!hasBeenCollected):
		pass;

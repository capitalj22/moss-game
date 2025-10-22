extends Camera2D

@export var Player: Node2D;
var targetPosition: Vector2;
var tween: Tween;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zoom = Vector2(1.2, 1.2);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Player:
		var xOffset = 0;
		if (Player.get_node("sprite").flip_h):
			xOffset = 20;
		else:
			xOffset = -20;
		var groundCast: RayCast2D = Player.get_node("groundCast")
		var skyCast: RayCast2D = Player.get_node("skyCast")
		
		var maxY = Player.global_position.y;
		var minY = Player.global_position.y;
		
		if (groundCast.is_colliding() && groundCast.get_collider().name == "floor"):
			maxY = groundCast.get_collision_point().y - 60;
			
		if (skyCast.is_colliding() && skyCast.get_collider().name == "ceiling"):
			maxY = skyCast.get_collision_point().y + 100;
		
		targetPosition = Vector2(Player.global_position.x + xOffset, clamp(Player.global_position.x, minY, maxY));
		moveTowardsTargetPosition()

	pass

func moveTowardsTargetPosition():
	global_position = global_position.move_toward(targetPosition, 2)
	#global_position = global_position.move_toward(targetPosition, 1)
	#global_position = targetPosition

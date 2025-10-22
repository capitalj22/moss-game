extends Node2D

class_name EnemyReact;

@export var enemy: CharacterBody2D;
@export var animationPlayer: AnimationPlayer;
@export var animation: String
# probably change this to a min and max, consider x and y variants?
@export var recoilAmount: float = 600;

var hasDied = false;
var launchLeft = false;
var velocity: Vector2;
var recoilTimer = 0;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die(delta):
	if (!hasDied):
		enemy.collision_layer = 2;
		var rot = create_tween();
		rot.tween_property(enemy, "rotation_degrees", 180, 0.8).set_trans(Tween.TRANS_SINE)
	
		if launchLeft:
			enemy.velocity = Vector2(300, -350);
		else:
			enemy.velocity = Vector2(-300, -350);
			
		enemy.move_and_collide(enemy.velocity * delta)
			
		hasDied = true;
	else:
		enemy.velocity += enemy.get_gravity() * delta;
		
		var collision = enemy.move_and_collide(velocity * delta)
		
		if collision:
			var length = enemy.velocity.length();
			enemy.velocity = enemy.velocity.bounce(collision.get_normal()).normalized() * (length * 0.75);
			
func recoil(delta, angle: float, normal: Vector2) -> bool:
	if (recoilTimer < 0.3):
		recoilTimer += delta;
	
		var velocity = Vector2.from_angle(deg_to_rad(angle)) * -400
		velocity += enemy.get_gravity() * delta;
			
		var collision = enemy.move_and_collide(velocity * delta)
		
		return true;
	else:
		recoilTimer = 0;
		return false;
	
		

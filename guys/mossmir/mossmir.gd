extends CharacterBody2D

@onready var mossmir: Node2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player: Sherma;
@export var moveCurve: Curve;

var HP = 2;
const SPEED = 130;
const ATTACK_SPEED = 200;
var moveTween: Tweener;
var initialPosition: Vector2;
var rnd = RandomNumberGenerator.new();
var collisionNormal: Vector2;
var collisionAngle: float;

@export var FOLLOWRange = 450;
@export var detectRange = 350;


var isMovingLeft = false;

enum States {
	HOVER,
	DEAD,
	ATTACK,
	FOLLOW,
	SEARCH,
	STUN,
	BOUNCE,
	DAMAGED,
	HIT,
	RECOVER
}


var states = {
	States.HOVER: {"animation": "flutter"},
	States.DEAD: {"animation": "dead"},
	States.FOLLOW: {"animation": "flutter"},
	States.SEARCH: {"animation": "flutter"},
	States.STUN: {"animation": "flutter"},
	States.ATTACK: {"animation": "attack"},
	States.DAMAGED: {"animation": "recoil"},
	States.BOUNCE: {"animation": "recoil"},
	States.HIT: {"animation": "flutter"},
	States.RECOVER: {"animation": "flutter"},
}

var state: States;

func tween_curve(v):
	return moveCurve.sample_baked(v)
	
	
func after_state_tween(tweenState: States):
	if state == States.DEAD:
		return;
	match(tweenState):
		States.BOUNCE:
			changeState(States.RECOVER)
		States.STUN:
			changeState(States.RECOVER)
			
func after_stun():
	changeState(States.RECOVER);

func after_recover():
	changeState(States.HOVER);
	
func after_bounce():
	changeState(States.HOVER)

func changeState(newState):
	var previousState = state;
	state = newState;
	
	if (newState != previousState):
		animation_player.play(states[newState].animation)
	match newState:
		States.BOUNCE:
			velocity.y = -200;
			var t = create_tween().tween_property(self, "velocity:y", 0, 0.4).set_ease(Tween.EASE_OUT)
			t.finished.connect(Callable(self, "after_state_tween").bind(States.BOUNCE))
		States.DAMAGED:
			print(HP)
			HP -= 1;
			
			if (HP <= 0):
				changeState(States.DEAD)
			pass;
		States.FOLLOW:
			pass;
		States.DEAD:
			print("DIED")
			$"enemyHitbox".queue_free();
			$"lootDropper".dropAll();
			self.z_index = -1;
			self.set_collision_layer_value(1, false)
			self.set_collision_mask_value(1, false)
			self.set_collision_layer_value(2, true)
			self.set_collision_mask_value(4, true)
			pass;
		States.HOVER:
			pass;
		States.STUN:
			moveTween = get_tree().create_tween().tween_property(self, "global_position", Vector2(global_position.x + rnd.randi_range(15, -15), global_position.y - rnd.randi_range(30, 60)), 0.3)
			moveTween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			moveTween.connect("finished", after_stun)
		States.RECOVER:
			velocity = Vector2(0, 0);
			moveTween = get_tree().create_tween().tween_property(self, "velocity:y", rnd.randi_range(-200, -350), rnd.randf_range(0.3, 0.6))
			moveTween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			moveTween.connect("finished", after_recover)
			pass;			
			


			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	changeState(States.HOVER)
	animation_player.play("flutter")

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		States.FOLLOW:
			if should_attack():
				changeState(States.ATTACK)
			elif checkForPlayer():
				changeState(States.FOLLOW)
			else:
				changeState(States.HOVER)
		States.HOVER:
	
			if checkForPlayer():
				changeState(States.FOLLOW)
	pass
	
func _physics_process(delta: float) -> void:
	match state:
		States.DEAD:
			if !is_on_floor():
				velocity += get_gravity() * delta;
				move_and_collide(velocity * delta);
				
		States.FOLLOW:
			move_and_collide(velocity * delta);
			velocity = global_position.direction_to(Vector2(player.global_position.x, player.global_position.y - 100)) * SPEED
		States.ATTACK:
			velocity += get_gravity() * delta;
			var collision = move_and_collide(velocity * delta);
			if (collision):
				collisionAngle = collision.get_angle()
				collisionNormal = collision.get_normal()
				changeState(States.BOUNCE)
		States.STUN:
			pass;
		States.BOUNCE:
		
			move_and_collide(velocity * delta);
		States.RECOVER:
			move_and_collide(velocity * delta)
			pass;
		States.DAMAGED:
			if $physEnemyReact.recoil(delta, collisionAngle, collisionNormal):
				pass;
			else:
				changeState(States.RECOVER)
			
	
	isMovingLeft = velocity.x < 0;
	if isMovingLeft:
		$"Sprite2D".flip_h = true;
	else:
		$"Sprite2D".flip_h = false;
		
	
func pogo():
	pass;
		
func on_hit(normal: Vector2, point: Vector2): 
	if (state == States.DEAD):
		return
		
	collisionAngle = rad_to_deg(global_position.angle_to_point(player.global_position))
	collisionNormal = normal;
	changeState(States.DAMAGED)
	
	
func checkForPlayer() -> bool:
	if (player):
		var distanceToCheck = FOLLOWRange if state == States.FOLLOW else detectRange;
		
		$playerSeekCast.target_position = global_position.direction_to(player.global_position) * distanceToCheck;
		
		return $"playerSeekCast".is_colliding() && $"playerSeekCast".get_collider() is Sherma
	return false;

func should_attack() -> bool:
	if (player):
		if (abs(global_position.x - player.global_position.x) < 10):
			return true;
	return false;

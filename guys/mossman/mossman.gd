extends CharacterBody2D

class_name Mossman

@onready var mossmir: Node2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player: Sherma;
@export var moveCurve: Curve;
@export var isFacingLeft = false;

var HP = 2;

const SPEED = 30;
const RUN_SPEED = 50;
var currentSpeed = 0;
const ATTACK_SPEED = 200;
var moveTween;
var initialPosition: Vector2;
var rnd = RandomNumberGenerator.new();
var collisionNormal: Vector2;
var collisionAngle: float;
var transitionTimer: float;
var nextState: States;

@export var FOLLOWRange = 250;
@export var detectRange = 150;


var isMovingLeft = false;

enum States {
	TRANSITION,
	WALK,
	DEAD,
	SITTING,
	ATTACK,
	FOLLOW,
	SEARCH,
	DAMAGED,
	HIT,
}


var states = {
	States.WALK: {"animation": "walk"},
	States.SITTING: {"animation": "sitting"},
	States.DEAD: {"animation": "die"},
	States.FOLLOW: {"animation": "run"},
	States.SEARCH: {"animation": "walk"},
	States.ATTACK: {"animation": "attack"},
	States.DAMAGED: {"animation": "recoil"},
	States.HIT: {"animation": "walk"},
}

var transitionStates = {
	States.SITTING: { 
		States.WALK: {"animation": "sitting_rise", "backwards": false, "time": 0.3}, 
		States.FOLLOW: {"animation": "sitting_rise", "backwards": false, "time": 0.3}, 
	},
	States.WALK: { States.SITTING: {"animation": "sitting_rise", "backwards": true, "time": 0.3}},
}

var state: States = States.SITTING;

func tween_curve(v):
	return moveCurve.sample_baked(v)
	
	
func after_state_tween(tweenState: States):
	if state == States.DEAD:
		return;
	match(tweenState):
		States.ATTACK:
			changeState(States.FOLLOW)
		
func transitionToState(newState):
	var previousState = state;
	nextState = newState;
	
	if transitionStates[previousState] && transitionStates[previousState][newState]:
		var transitionState = transitionStates[previousState][newState];
		var animationToPlay = transitionState.animation;

		transitionTimer = transitionState.time;
		if transitionState.backwards:
			animation_player.play_backwards(animationToPlay)  
		else: 
			animation_player.play(animationToPlay)
	else:
		transitionTimer = 0.3;
	changeState(States.TRANSITION)
	
func changeState(newState):
	var previousState = state;
	state = newState;
	
	if (newState != previousState && newState != States.TRANSITION):
		animation_player.play(states[newState].animation)
	match newState:
		States.ATTACK:
			moveTween = create_tween().tween_property(self, "currentSpeed", 20, 0.3).set_ease(Tween.EASE_OUT)
			moveTween.finished.connect(Callable(self, "after_state_tween").bind(States.ATTACK))
		States.DAMAGED:
			print(HP)
			HP -= 1;
			
			if (HP <= 0):
				changeState(States.DEAD)
			pass;
		States.FOLLOW:
			currentSpeed = 30;
			moveTween = create_tween().tween_property(self, "currentSpeed", 100, 0.5).set_ease(Tween.EASE_IN)
		
			pass;
		States.DEAD:
			moveTween = create_tween();
			print("DIED")
			$"enemyHitbox".queue_free();
			$"lootDropper".dropAll();
			self.z_index = -1;
			self.set_collision_layer_value(1, false)
			self.set_collision_mask_value(1, false)
			self.set_collision_layer_value(2, true)
			self.set_collision_mask_value(4, true)
			pass;
		States.WALK:
			moveTween = create_tween().tween_property(self, "currentSpeed", 30, 0.2).set_ease(Tween.EASE_IN)

			pass;
		
			


			
func _ready() -> void:
	changeState(States.SITTING)
	flip();

func _process(delta: float) -> void:
	match state:
		States.TRANSITION:
			transitionTimer -= delta;
			if transitionTimer <= 0:
				changeState(nextState)
				
				
		States.SITTING:
			if randi_range(0, 10000) == 1:
				changeState(States.WALK)
			if randi_range(0, 10000) == 1:
				animation_player.play("sitting_lean")
			if checkForPlayer():
				# add check for if player is behind
				transitionToState(States.FOLLOW)
		States.FOLLOW:
			if should_attack():
				changeState(States.ATTACK)
			elif checkForPlayer():
				changeState(States.FOLLOW)
			else:
				changeState(States.WALK)
		States.WALK:
			if randi_range(0, 10000) == 1:
				changeState(States.SITTING)
			if checkForPlayer():
				changeState(States.FOLLOW)
	pass
	
func _physics_process(delta: float) -> void:

	match state:
		States.SITTING:
			if !is_on_floor():
				velocity += get_gravity() * delta;
				move_and_slide()
			pass
		States.WALK:
			if !is_on_floor():
				velocity += get_gravity() * delta;
				
			velocity.x = currentSpeed;
			move_and_slide()
		States.DEAD:
			if !is_on_floor():
				velocity += get_gravity() * delta;
				
				move_and_collide(velocity * delta);
				
		States.FOLLOW:
			velocity = global_position.direction_to(Vector2(player.global_position.x, player.global_position.y)) * currentSpeed
			velocity.y = 0;
			
			if !is_on_floor():
				velocity += get_gravity();
				
			move_and_slide();
		States.ATTACK:
			velocity = global_position.direction_to(Vector2(player.global_position.x, player.global_position.y)) * currentSpeed
			
			#changeState(States.WALK)
			#velocity += get_gravity() * delta;
			##var collision = move_and_collide(velocity * delta);
			##if (collision):
				##collisionAngle = collision.get_angle()
				##collisionNormal = collision.get_normal()
				##changeState(States.BOUNCE)
		#States.STUN:
			#pass;
		#States.BOUNCE:
		#
			#move_and_collide(velocity * delta);
		#States.RECOVER:
			#move_and_collide(velocity * delta)
			#pass;
		States.DAMAGED:
			if $physEnemyReact.recoil(delta, collisionAngle, collisionNormal):
				pass;
			else:
				changeState(States.WALK)
			
	
	isMovingLeft = velocity.x < 0;
	isFacingLeft = isMovingLeft;
	flip();
		

func flip():
	if isFacingLeft:
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
		if (abs(global_position.x - player.global_position.x) < 40):
			return true;
	return false;

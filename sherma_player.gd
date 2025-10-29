extends CharacterBody2D
class_name Sherma

@export var debug = false;

signal damaged;
signal hit_connected;

@onready var timer: Timer = $Timer

enum States {
	ASCENDING,
	DAMAGED,
	IDLE, 
	WALK,
	RUN,
	DASH,
	JUMP,
	DASH_JUMP,
	CHANT,
	FALL,
	MANTLE,
	GUARD,
	POGO,
	LOOKING_UP
	}
	
enum AttackStates {
	NONE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	ATTACKUP,
	PARRY,
	POGO
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# change to group
@onready var scene_wall: Area2D = $"../Scene Transitions/scene_wall"

var iframeCooldown = 0;
var HP = 4;
var rnd = RandomNumberGenerator.new();
var timeSinceAttack = 0;
var state: States = States.IDLE
var attackState = AttackStates.NONE;
var actionTimer = 0;
@export var BASE_SPEED = 200.0
const DASH_SPEED = 400;
const ATTACK_TIME = 0.35;
const COYOTE_TIME = 0.2;

@export var JUMP_TIME = 0.2;
@export var jumpVelocity = -400;

var damageNormal;
var jumpTimer = 0;
var wasOnFloor = false;
var coyoteActive = false;
var coyoteTimer = 0;
var currentMantlePosition = null;
var currentMantleDirection = null;
var inMantleZone = false;

var isHoldingDown = false;
var isHoldingUp = false;
var isHoldingJump = false;
var isHoldingLeft = false;
var isHoldingRight = true;


var queuingAttack = false;

const states = {
	States.IDLE: {"animation": "idle", "loopAnim": "idle"},
	States.ASCENDING: {"animation": "ascending", "loopAnim": "ascending"},
	States.DAMAGED: {"animation": "damaged", "loopAnim": "idle"},
	States.WALK: {"animation": "walk", "loopAnim": "walk"},
	States.RUN: {"animation": "run", "loopAnim": "run"},
	States.DASH: {"animation": "run_fast", "loopAnim": "run_fast"},
	States.DASH_JUMP: {"animation": "jump", "loopAnim": "falling"},
	States.CHANT: {"animation": "chant", "loopAnim": "chant"},
	States.FALL: {"animation": "falling", "loopAnim": "falling"},
	States.MANTLE: {"animation": "mantle", "loopAnim": "idle"},
	States.GUARD: {"animation": "guard", "loopAnim": "guarding"},
	States.JUMP: {"animation": "jump", "loopAnim": "falling"},
	States.POGO: {"animation": "jump", "loopAnim": "falling"},
	States.LOOKING_UP: {"animation": "look_up", "loopAnim": "looking_up"}
}
const attacks = {
	AttackStates.NONE: {"time": 0, "animation": null, "next": AttackStates.ATTACK, "castPoint": Vector2(0, 0), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)},
	AttackStates.ATTACK: {"time": 0.4, "animation": "attack", "next": AttackStates.ATTACK2, "castPoint": Vector2(-43, 0), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)}, 
	AttackStates.ATTACK2: {"time": 0.4, "animation": "attack_2", "next": AttackStates.ATTACK3, "castPoint": Vector2(-43, 0), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)},
	AttackStates.ATTACK3: {"time": 0.5, "animation": "attack_3", "next": AttackStates.ATTACK, "castPoint": Vector2(-43, 0), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)},
	AttackStates.ATTACKUP: {"time": 0.3, "animation": "attack_up", "next": AttackStates.ATTACK, "castPoint": Vector2(0, -48), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)},
	AttackStates.PARRY: {"time": 0.4, "animation": "parry", "next": null, "castPoint": Vector2(-30, 0), 
	"pogo": false, "hurtboxPosition": Vector2(0, 0)},
	AttackStates.POGO: {"time": 0.3, "animation": "pogo", "next": AttackStates.ATTACK, "castPoint": Vector2(0, 30), 
	"pogo": true, "hurtboxPosition": Vector2(0, -9)},
};


const JUMP_VELOCITY = -200.0

func init():
	$"light4".visible = true;
	$"Parallax2D/light2".visible = true;
	$"Parallax2D/light3".visible = true;
func ascend():
	var move_tween = create_tween().tween_property(self, "global_position", Vector2(global_position.x, global_position.y - 30), 1).set_ease(Tween.EASE_IN)
	timer.wait_time = 1;
	timer.one_shot = true;
	timer.connect("timeout", finishAscent)
	timer.start()
	set_state(States.ASCENDING);

func finishAscent():
	set_state(States.IDLE)
	
func is_attacking():
	return attackState != AttackStates.NONE
	
func on_mantle_entered(left: bool, pos: Vector2):	
	inMantleZone = true;
	currentMantlePosition = pos;
	currentMantleDirection = 1 if left else -1;

func on_mantle_exited():
	inMantleZone = false;
	
func on_scene_wall_exited(body: Node2D):
	if (body is Sherma):
		if self.global_position.x < scene_wall.global_position.x:
			$Camera2D.limit_right = scene_wall.global_position.x;
			$Camera2D.limit_left = -100000;
			
		else:
			$Camera2D.limit_right = 100000;
			$Camera2D.limit_left = scene_wall.global_position.x;
			
func on_anim_finished(anim_name: String):
	#print(anim_name)
	pass;
	#if attackState == AttackStates.NONE:
	#animation_player.play(states[state].loopAnim)
	
func on_pogo(material: String = ""):
	if material == "metal":
		$"AttackAudio2".pitch_scale = rnd.randf_range(0.7, 0.9);
		$"AttackAudio2".play()
	#$"AttackAudio3".play()
	
	set_state(States.POGO)
	

func on_hitbox_entered(area: Area2D):
	 
	if area.has_meta("isEnemyHitbox"):
		damageNormal = (global_position - area.global_position).normalized();
		takeDamage();
	
func _ready() -> void:
	init();
	$"attack_collision".pogo.connect(on_pogo)
	
	$"hurtbox".area_entered.connect(on_hitbox_entered)
	var mantles = get_tree().get_nodes_in_group("mantles");
	for mantle in mantles:
		mantle.entered.connect(on_mantle_entered)
		mantle.exited.connect(on_mantle_exited)
	animation_player.animation_finished.connect(on_anim_finished)
	
	#scene_wall.body_exited.connect(on_scene_wall_exited);
		 
func set_attack_state(newState: AttackStates) -> void:
	var previousState = attackState;				
	if newState != previousState:
		actionTimer = 0;
		attackState = newState;
		$"attack_collision".target_position = attacks[newState].castPoint;
		$"attack_collision".set_meta("pogo", attacks[newState].pogo);
		$"hurtbox".position = attacks[newState].hurtboxPosition;
		
		if ($sprite.flip_h):
			$attack_collision.target_position.x *= -1;
		
		match attackState:
			AttackStates.NONE:
				$"attack_collision".set_deferred("enabled", false)
				animation_player.play(states[state].loopAnim)
				timeSinceAttack = 0;
			AttackStates.ATTACK:
				$"AttackAudio".pitch_scale = rnd.randf_range(0.7, 0.8);
				$"AttackAudio".play()

				animation_player.play(attacks[AttackStates.ATTACK]["animation"])
			AttackStates.ATTACK2:
				$"AttackAudio".pitch_scale = rnd.randf_range(0.8, 0.9);
				$"AttackAudio".play()

				animation_player.play(attacks[AttackStates.ATTACK2]["animation"])
			AttackStates.ATTACK3:
				$"AttackAudio".pitch_scale = 0.8;
				$"AttackAudio".play()

				animation_player.play(attacks[AttackStates.ATTACK3]["animation"])
			AttackStates.ATTACKUP:
				$"AttackAudio".pitch_scale = 0.5;
				$"AttackAudio".play()

				animation_player.play(attacks[AttackStates.ATTACKUP]["animation"])
			AttackStates.PARRY:
				$"AttackAudio2".pitch_scale = rnd.randf_range(1.1, 1.3);

				$"AttackAudio2".play()
				$"AttackAudio3".play()
				
				animation_player.play(attacks[AttackStates.PARRY]["animation"])
			AttackStates.POGO:
				animation_player.play(attacks[AttackStates.POGO]["animation"])
	
	
func set_state(newState: States) -> void:
	var playAnimation = func(animation):
		if attackState == AttackStates.NONE:
			animation_player.play(animation)
		pass;
		
	var previousState = state;
	state = newState;
	if newState != previousState:
		if debug: print(newState);

		# transition
		match previousState:
			States.GUARD:
				animation_player.play_backwards("guard")
			States.DAMAGED:
				iframeCooldown = 0.3;
				#Engine.time_scale = 1.0

		match state:
			States.ASCENDING:
				playAnimation.call("ascending")

				#var et = create_tween().tween_property(self, ).set_ease(Tween.EASE_OUT);

			States.DAMAGED:
				Engine.time_scale = 0.3;
				var et = create_tween().tween_property(Engine, "time_scale", 1.0, 0.3).set_ease(Tween.EASE_OUT);
				playAnimation.call("damaged")
				actionTimer = 0;
			States.POGO:
				jumpTimer = 0;
			States.IDLE:
				playAnimation.call("idle")
			States.WALK:
				playAnimation.call("walk")
			States.RUN:
				playAnimation.call("run")
			States.DASH:
				playAnimation.call("run_fast")
			States.CHANT:
				playAnimation.call("chant")
			States.FALL:
				playAnimation.call("falling")
			States.JUMP:
				jumpTimer = 0;
				playAnimation.call("jump")
			States.DASH_JUMP:
				jumpTimer = 0;
				playAnimation.call("jump")
			States.MANTLE:
				playAnimation.call("mantle")
			States.GUARD:
				playAnimation.call("guard")
			States.LOOKING_UP:
				playAnimation.call("look_up")
			
	
	
func queueAttack():
	if debug:
		print("queue attack")
	queuingAttack = true;
	
	
func get_gravity2(isJumping, isDashJumping) -> Vector2:
	if !isJumping:
		return get_gravity()
	else:
		return Vector2(0, jumpVelocity) if isJumping else Vector2(0, jumpVelocity * 1.25)
	
	
	
	
func _physics_process(delta: float) -> void:
	if iframeCooldown > 0:
	
		iframeCooldown -= delta;
	
	if state == States.DAMAGED:
		actionTimer += delta;
		
		if (actionTimer < 0.2):
			return;
			velocity = damageNormal * -1 * 60
			move_and_collide(velocity * delta)
		else:
			set_state(States.IDLE)
			
	
	if state == States.ASCENDING:
		move_and_slide();
		return;
	if state != States.MANTLE && inMantleZone:
		if currentMantleDirection > 0 && isHoldingRight || currentMantleDirection < 0 && isHoldingLeft:
			set_state(States.MANTLE)
			return;
	# check current state to determine if other actions can be taken:
	if state == States.MANTLE:
		if global_position.y > currentMantlePosition.y - 5:
			global_position.y = max(global_position.y - (delta * 500), currentMantlePosition.y - 5);
			#move_and_slide();
			return;
		elif (currentMantleDirection > 0 && global_position.x < currentMantlePosition.x + 10) ||(currentMantleDirection < 0 && global_position.x > currentMantlePosition.x - 10):
			global_position.x = min(global_position.x + (delta * 200 * currentMantleDirection), currentMantlePosition.x + (10 * currentMantleDirection));
			#move_and_slide()
			return;
		
	
	var isFalling = not is_on_floor() && velocity.y > 0;
	
	if wasOnFloor && !is_on_floor():
		coyoteTimer = 0;
		coyoteActive = true;
	
	if (coyoteActive):
		coyoteTimer += delta;
		if (coyoteTimer >= COYOTE_TIME):
			coyoteActive = false;
	
	
	var isJumping = false;
	# Handle jump.
	if Input.is_action_just_pressed("jump_p1") and (is_on_floor() || coyoteActive):
		isJumping = true;
		isHoldingJump = true;
		
		
	if Input.is_action_just_released("jump_p1"):
		isHoldingJump = false;
		
		
	var isChanting = Input.is_action_pressed("transform_p1");
	var isGuarding = Input.is_action_pressed("guard_p1");
	var isParrying = false;
	
	if isGuarding:
		if Input.is_action_pressed("parry_p1"):
			isParrying = true;

	var pressedAttack = Input.is_action_just_pressed("attack_p1")
	var verticalDirection = Input.get_axis("move_down_p1", "move_up_p1");
	
	if (verticalDirection <= -0.3):
		isHoldingDown = true;
	else:
		isHoldingDown = false;
		
	if (verticalDirection >= 0.3):
		isHoldingUp = true;
	else:
		isHoldingUp = false;

	if !is_attacking():
		timeSinceAttack += delta;
		
	#if attacking, check if attack is done
	if is_attacking():
		var time = attacks[attackState].time
		
		if actionTimer >= 0.05 && actionTimer < 0.5:
			$"attack_collision".set_deferred("enabled", true)
		else:
			$"attack_collision".set_deferred("enabled", false)
			
		if (pressedAttack && !queuingAttack && actionTimer >= time - 0.15):
			queueAttack();
		if actionTimer < time:
			actionTimer += delta;
		elif queuingAttack:
			if isHoldingUp:
				set_attack_state(AttackStates.ATTACKUP)
			elif isHoldingDown && !is_on_floor():
				set_attack_state(AttackStates.POGO)
			else:
				print ("next attack", attackState)
				set_attack_state(attacks[attackState].next)
				
			queuingAttack = false;
		else:
			set_attack_state(AttackStates.NONE);
		
		if isGuarding && actionTimer > 0.2 && attackState != AttackStates.PARRY:
			set_attack_state(AttackStates.NONE)
	# pressed attack and not attacking
	elif pressedAttack:
		if isHoldingUp:
			set_attack_state(AttackStates.ATTACKUP)
		elif isHoldingDown && !is_on_floor():
			set_attack_state(AttackStates.POGO)
		else:
			set_attack_state(AttackStates.ATTACK)
		
				
	elif isParrying:
		set_attack_state(AttackStates.PARRY)
		
	var direction := Input.get_axis("move_left_p1", "move_right_p1")
	
	isHoldingRight = direction > 0;
	isHoldingLeft = direction < 0;
	
	var isWalking = abs(direction) > 0.3 && is_on_floor();
	var isRunning = isWalking && abs(direction) > 0.5;
	var isDashing = Input.is_action_pressed("roll_p1") && isRunning;
	var isDashJumping = isJumping && isDashing;
	var isChilling = is_on_floor() && abs(direction) <= 0.3;
	
	if abs(direction)>= 0.3:
		if !is_attacking():
			if direction < 0:
				$sprite.flip_h = false
				$"swordCast".target_position.x = -48
			else:
				$sprite.flip_h = true;
				$"swordCast".target_position.x = 48
		
		if !isChanting && !isGuarding:
			velocity.x = direction * BASE_SPEED
			if (isDashing || state == States.DASH_JUMP):
				velocity.x = direction * DASH_SPEED;
				
		# adjust sprite	
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
	
	if not is_on_floor():
		wasOnFloor = false;
	else:
		wasOnFloor = true;
		
	

	if state == States.POGO:
		velocity.y = JUMP_VELOCITY * 2.5;
		set_state(States.FALL)
	elif isGuarding:
		set_state(States.GUARD)
	elif isDashJumping:
		set_state(States.DASH_JUMP)
		velocity.y = JUMP_VELOCITY;
	elif isJumping:
		set_state(States.JUMP)
		velocity.y = JUMP_VELOCITY
	elif isFalling:
		set_state(States.FALL)
	elif isChanting:
		set_state(States.CHANT)
	elif isDashing:
		set_state(States.DASH)
	elif isRunning:
		set_state(States.RUN)
	elif isWalking:
		set_state(States.WALK)
	elif isChilling:
		if isHoldingUp:
			set_state(States.LOOKING_UP)
		else:
			set_state(States.IDLE)
		
	if (isHoldingJump):
		if jumpTimer < JUMP_TIME:
			jumpTimer += delta;
		else:
			isHoldingJump = false;
			isJumping = false;
	
	
		
	velocity += get_gravity2(isHoldingJump, isDashJumping) * delta
		
	move_and_slide()
	
	#if get_slide_collision_count():
		#for collisionIndex in range(get_slide_collision_count()):
			#var collision = get_slide_collision(collisionIndex)
			#if collision.get_collider().name != "Floor":
				#print(collision.get_collider().name)
			#if collision.get_collider().has_meta("isEnemyHitbox"):
				#takeDamage()
				
				
func takeDamage():
	# iframe:
	
	if (state != States.DAMAGED && iframeCooldown <= 0):
		HP = HP - 1;
		damaged.emit();
		set_state(States.DAMAGED)

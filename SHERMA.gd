extends CharacterBody2D

var playerNo = 1;
var isGuarding = false;
var isMoving = false;
var isRolling = false;
var isContinuouslyRolling = false;
var isHoldingRoll = false;
var isFacingLeft = false;
var isFacingDown = false;
var rollCooldown = 0;
var rollCount = 0;
var currentSpeed = 0;
var isJumping = false;
var airborne = false;
var jumpCooldown = 0;
var jumpStrength = 0;
var isSticking = false;
var isStickingNormal;
var isDetaching = false;
var detachingTimer = 0;
var isMantling = false;
var mantleTargetHeight: float;
var mantleDirection;

var isHoldingLeft = false;
var isHoldingRight = false;

var currentMantleZone = null;

# replace with animation priority system
var isPlayingHighPriorityAnimation;


const MAX_SPEED = 60;
const MAX_ROLLING_SPEED = 300;
const MAX_JUMPING_SPEED = 300;
const BASE_SPEED = 35;

@onready var mantle_zone: Area2D = $"../LevelCollision/Mantles/mantleZone"
@onready var sprite: AnimatedSprite2D = $sprite
@onready var mantles: Node2D = $"../LevelCollision/Mantles"


	

func startRolling():
	isRolling = true;
	currentSpeed = min(MAX_ROLLING_SPEED, currentSpeed + 400);
	sprite.play("roll")
	pass;

func finishRolling():
	sprite.play("idle")
		
	isRolling = false;
	currentSpeed = max(MAX_SPEED, currentSpeed)
	rollCount = 0;
	rollCooldown = 0;
	
func jumpOffWall(delta):
	
	unstick();
	isDetaching = true;
	
	sprite.rotation_degrees = 0;
	if (isStickingNormal.x > 0):
		isFacingLeft = true;
		velocity.x = (2000 * delta);
	else:
		isFacingLeft = false;
		velocity.x = (-2000 * delta);
	sprite.play("jump_up")
	
	currentSpeed = 200;

func jump(delta):
	if !jumpCooldown:
		jumpStrength = 0;
		sprite.play("jump")
		isJumping = true;
		velocity.y -= 4000 * delta;
		
		
func guard():
	sprite.play("guard")
	pass;
	
func parry():
	sprite.play("attack_1")
	pass
	
func on_animation_finished():
	isPlayingHighPriorityAnimation = false;
	if (!isGuarding && !airborne && !isMantling && !isRolling && !isHoldingRoll):
		sprite.play("idle")

	

func on_animation_changed():
	if sprite.get_animation() == "jump_down" || sprite.get_animation() == "roll" || sprite.get_animation() == "mantle":
		isPlayingHighPriorityAnimation = true;

func mantle(isLeft: bool, targetPosition: float):
	print("MANTLING")
	sprite.stop();
	sprite.play("mantle")
	isMantling = true;
	mantleDirection = "left" if isLeft else "right";
	#unstick();
	mantleTargetHeight = targetPosition;
	
func on_mantle_zone_entered(isLeft: bool, targetPosition: float, pstate: String):
	print("mantle zone entered")
	
	if (pstate == "exit"):
		currentMantleZone = null;
	elif (pstate == "enter"):
		currentMantleZone = [isLeft, targetPosition]
	
	
	
func _ready() -> void:
	
	#for mantle in mantles.get_children():
		#mantle.playerStateChanged.connect(on_mantle_zone_entered)
		
	velocity = Vector2(0, 280);
	sprite.animation_finished.connect(on_animation_finished)
	sprite.animation_changed.connect(on_animation_changed)
	
func queue(move: String):
	pass;

func stick_move(amt, delta):
	sprite.play("crawl")
	
	if (amt < 0):
		isFacingDown = false;
		sprite.flip_h = isStickingNormal.x > 0;
	else: 
		isFacingDown = true;
		sprite.flip_h = isStickingNormal.x < 0;
	
	currentSpeed =  70;
	
func move(amt, delta):
	var wasFacing = isFacingLeft;
	
	if (amt < 0):
		isFacingLeft = true
		sprite.flip_h = false;
	if (amt > 0):
		isFacingLeft = false
		sprite.flip_h = true;
	
	if isFacingLeft != wasFacing:
		currentSpeed = BASE_SPEED;
	
	if (airborne && !isSticking):
		currentSpeed = min(currentSpeed + abs(amt) * 200 * delta, MAX_JUMPING_SPEED)
	elif (!isGuarding && !isSticking):
		var newSpeed = max(currentSpeed, MAX_SPEED);
		currentSpeed = newSpeed;
		isMoving = true;
		if (!isRolling && is_on_floor()):
			if (!isPlayingHighPriorityAnimation):
				sprite.play("crawl")
		
		
func _physics_process(delta: float) -> void:
		
	var input_up = "move_up_p%s" % playerNo
	var input_down = "move_down_p%s" % playerNo
	var input_left = "move_left_p%s" % playerNo
	var input_right = "move_right_p%s" % playerNo
	var dir_y := Input.get_axis(input_up, input_down)
	var dir_x := Input.get_axis(input_left, input_right)
	
	# handle right as well by checking normal
	
	if currentMantleZone != null && !isMantling && is_on_wall():
		print(currentMantleZone[1])
		var isBelowMantleZone = self.global_position.y > currentMantleZone[1]
		if (isBelowMantleZone && currentMantleZone[0] == true && isHoldingRight || !currentMantleZone[0] == false && isHoldingLeft):
			mantle(currentMantleZone[0], currentMantleZone[1])
		
	if (isSticking && !is_on_wall()):
		unstick();
		
	if (isMantling):
		if position.y <= mantleTargetHeight:
			isMantling = false;
			currentSpeed = 200;
			velocity.y = 100;
			isFacingLeft = false if mantleDirection == "left" else true;
		else:
			velocity.y = -100;
		move_and_slide()
		pass;
			
	# land
	if (airborne && is_on_floor()):
		#sprite.play("jump_down")
		jumpCooldown = 0.05;
	
	airborne = !is_on_floor();
	if (isRolling):
		rollCount += delta;
		
		if rollCount > 0.5:
			if (!isHoldingRoll):
				finishRolling();
			else:
				sprite.play("roll_cont")
				isContinuouslyRolling = true;
		if (isContinuouslyRolling):
			currentSpeed = min(MAX_ROLLING_SPEED, currentSpeed + 10);
			
			
	if (jumpCooldown > 0):
		jumpCooldown = max(0, jumpCooldown - delta)
	if (rollCooldown > 0):
		rollCooldown = max(0, rollCooldown - delta)
		
	if (abs(dir_x) > 0.3 && !isSticking):
		move(dir_x, delta)
		isHoldingLeft = dir_x > 0;
		isHoldingRight = dir_x < 0;
	else:
		isHoldingLeft = false;
		isHoldingRight = false;
		isMoving = false;
	
	if (isSticking && abs(dir_y) > 0.3):
		stick_move(dir_y, delta)
	
	if Input.is_action_pressed("roll_p%s" % playerNo):
		isHoldingRoll = true;
		if !isRolling && !rollCooldown: 
			startRolling()
			
	else: 
		isHoldingRoll = false;
		isContinuouslyRolling = false;
	
	if Input.is_action_pressed("guard_p%s" % playerNo):
		if (!isGuarding):
			guard()
			isGuarding = true;
	else:
		if isGuarding:
			sprite.play_backwards("guard")
			isGuarding = false;
	
	if Input.is_action_pressed("parry_p%s" % playerNo):
		parry()
	
	
	var wallNormal = get_wall_normal();
	

	#if (is_on_wall() && is_on_floor() && (isHoldingLeft && wallNormal.x < 0) || (isHoldingRight && wallNormal.x > 0)):
		#stick(wallNormal);
		
	#if (is_on_wall_only() && !isSticking && !isDetaching):
		#stick(wallNormal)
		
		
	if Input.is_action_pressed("jump_p%s" % playerNo):
		if (isSticking):
			jumpOffWall(delta);
		if (!isJumping && is_on_floor()):
			jump(delta)
		elif (jumpStrength < 0.3):
			jumpStrength += delta;
			velocity.y = -200;
		else:
			isJumping = false;
			#jumpStrength = 0;
		
	else:
		isJumping = false;
			
			
	
	
	addCurrentSpeed()
	rest(delta);
	move_and_slide()
	
	if (isDetaching):
		detachingTimer += delta;
		if (detachingTimer > 0.3):
			isDetaching = false;
			detachingTimer = 0;
	
	
	#for i in self.get_slide_collision_count():
		#var collision = self.get_slide_collision(i)
	#
		#
		#if (airborne && abs(collision.get_normal().x) > 0 && !isSticking):
			#stick(collision.get_normal().x)
			
			

func stick(wallNormal):
	sprite.play("idle");
	isStickingNormal = wallNormal;
	
	if wallNormal.x > 0:
		sprite.rotation_degrees = 90;
		sprite.offset.x = 6;
		
	else: 
		sprite.rotation_degrees = 270;
		sprite.offset.x = -6;
		
	isSticking = true;
	velocity.y = 0;
	velocity.x = 0;

func unstick():
	if (isSticking):
		sprite.rotation_degrees = 0;
		sprite.offset.x = 0
		sprite.offset.y = 0;
	isSticking = false;
		
func addCurrentSpeed():
	if (isSticking):
		if (isFacingDown):
			velocity.y = currentSpeed;
		else:
			velocity.y = currentSpeed * -1;
	if (!isFacingLeft):
		velocity.x = currentSpeed;
	else:
		velocity.x = currentSpeed * -1;

func rest(delta):
	if not is_on_floor() && !isSticking:
		if (!isJumping):
			velocity += get_gravity() * delta
		if (currentSpeed > MAX_JUMPING_SPEED):
			currentSpeed -= 10;
	else:
		if currentSpeed > MAX_SPEED && !isRolling:
			currentSpeed = max(0, currentSpeed - 500 * delta);
		else:
			currentSpeed = max(0, currentSpeed - 500 * delta);

extends CharacterBody2D

class_name MossGrub

var shard = preload("res://components/currency/shard.tscn")

@export var test: bool;
@export var player: Node2D;

const ATTACK_TIME = 1;
const ATTACK_COOLDOWN = 1;

var isMovingLeft = true;
const SPEED = 80.0
var state = "WALK"
var actionTimer = 0;
var attackCooldownTimer = 0;
var pauseLength = 0;
var rnd = RandomNumberGenerator.new();
var queuedAnimation;
var hp = 2;
var launchLeft = 0;
var readyToLaunch = false;
var collisionAngle: float;
var collisionNormal: Vector2;

func pogo():
	pass;
	
func _ready():
	
	
	$sprite.animation_finished.connect(on_animation_finished)
	changeState("WALK");

func take_damage(playerPos):
	if state != "DEAD":
		hp -= 1;
		
		if (hp <= 0):
			changeState("DEAD")
		
			launchLeft = global_position.x - playerPos.x > 0;
		else:
			changeState("DAMAGED")

#States
func changeState(newState):
	actionTimer = 0;
	var previousState = state;
	
	if (newState == "WALK"):
		if (previousState == "PAUSE"):
			$sprite.play_backwards("pause")
			queueAnimation("walk")
		else:
			$sprite.play("walk");
			
		state = "WALK";
	if (newState == "ATTACK"):
		$sprite.play("attack")
		state = "ATTACK";
	if (newState == "RETREAT"):
		state = "RETREAT";
		$sprite.play("idle")
	if (newState == "PAUSE"):
		$sprite.play("pause")
		pauseLength = rnd.randf_range(3, 10);
		state = "PAUSE"
	if (newState == "PAUSESHORT"):
		pauseLength = rnd.randf_range(0.2, 0.6);
		state = "PAUSE"
	if (newState == "DEAD"):
		$"enemyHitbox".queue_free();
		
		var numberOfShards = rnd.randi_range(1, 4);
		
		for i in range(numberOfShards):
			var shardInstance: Shard = shard.instantiate()	
			shardInstance.linear_velocity = Vector2(rnd.randf_range(-10, 10), rnd.randf_range(-30, -10))
			add_child(shardInstance)
		state = "DEAD"
		self.z_index = -1;
		#print(self.self_modulate)
		#var dieTween = create_tween().tween_property($"sprite", "self_modulate", Color(0.169, 0.169, 0.169, 0.761), 0.5)
		
		self.set_collision_layer_value(1, false)
		self.set_collision_mask_value(1, false)
		self.set_collision_layer_value(2, true)
		self.set_collision_mask_value(4, true)
		$sprite.play("dead")
	if (newState == "DAMAGED"):
		state = "DAMAGED"
		#hp = hp - 1;
	
		

#Animation	
func on_animation_finished():
	if (queuedAnimation):
		$sprite.play(queuedAnimation);
		queuedAnimation = null;

func queueAnimation(animation):
	queuedAnimation = animation;


	
func checkForPlayer() -> bool:
	if (player):
		var canSeePlayer = false;
		var distanceToPlayer = global_position.x - player.global_position.x;
		var heightDifference = abs(global_position.y - player.global_position.y);
		var inRange = abs(distanceToPlayer) < 60 && heightDifference < 12;

		if (isMovingLeft):
			canSeePlayer = distanceToPlayer < 0 && inRange;
		elif (!isMovingLeft):
			canSeePlayer = distanceToPlayer > 0 && inRange;
		if (canSeePlayer):
			return(true)
		else:
			return(false)
	return false;
			
func _process(delta: float) -> void:
	pass;
	
		
func on_hit(normal: Vector2, point: Vector2): 
	if (state == "DEAD"):
		return;
		
	collisionAngle = global_position.angle_to_point(point)
	collisionNormal = normal;
	hp -= 1;
	
	if (hp <= 0):
		changeState("DEAD")
		readyToLaunch = true;
		launchLeft = global_position.x - normal.x > 0;
	else:
		changeState("DAMAGED")
				
		
func _physics_process(delta: float) -> void:
	#cooldowns
	if (!is_on_floor()):
		velocity += get_gravity() * delta;
			
	if (state == "DEAD"):
		$"physEnemyReact".die(delta)
		return;
	
	if (attackCooldownTimer > 0):
		attackCooldownTimer = max(0, attackCooldownTimer - delta);
	
	if (state == "DAMAGED"):
		if $"physEnemyReact".recoil(delta, collisionAngle, collisionNormal):
			pass;
		else:
			changeState("RETREAT")
			
	#ATTACK
	if (state == "ATTACK"):
		actionTimer += delta;
		if (actionTimer < 0.5):
			if (isMovingLeft):
				velocity.x = 100;
			else:
				velocity.x = -100;
			move_and_slide()

		else:
			changeState("RETREAT")
			attackCooldownTimer = 3;
	#PAUSE
	if (state == "PAUSE"):
		velocity.x = 0;
		actionTimer += delta;
		if (actionTimer < pauseLength):
			if (checkForPlayer() && !attackCooldownTimer):
				changeState("ATTACK")
		else:
			changeState("WALK")
		
		move_and_slide();
	
	if (state == "RETREAT"):
		actionTimer += delta;
			
		if (actionTimer < 0.3):
			if (isMovingLeft):
				velocity.x = -60;
			else:
				velocity.x = 60;
			move_and_slide()

		else:
			changeState("PAUSESHORT")
		
	#WALK
	if (state == "WALK"):
		#if (is_on_floor() && rnd.randi_range(1, 500) == 2):
			#changeState("PAUSE")
			#pass;
			
		if (checkForPlayer() && !attackCooldownTimer):
			changeState("ATTACK")
			
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		if (!$"platformCast".is_colliding() || is_on_wall()):
			isMovingLeft = !isMovingLeft;
			$sprite.flip_h = !isMovingLeft;
			$platformCast.target_position = Vector2(34, 18) if isMovingLeft else Vector2(-34, 18)
		
		
		if (isMovingLeft):
			velocity.x = SPEED;
		else:
			velocity.x = SPEED * -1;
			
		move_and_slide()
		
		

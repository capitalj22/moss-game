extends Area2D

class_name EnemyHurtbox

@export var hurtCooldown = 0.3;
@export var enemy: CharacterBody2D;
@export var enemyColorMod: EnemyColorMod;

var canGetHit = true;
var hurtCDTimer = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!canGetHit):
		hurtCDTimer += delta;
		if (hurtCDTimer >= hurtCooldown):
			canGetHit = true;
			hurtCDTimer = 0;
			self.set_deferred("disabled", false)

	pass
	
func on_hit(normal: Vector2, point: Vector2):
	if canGetHit:
		enemy.on_hit(normal, point);
		if (enemyColorMod):
			enemyColorMod.flash();
		canGetHit = false;
		self.set_deferred("disabled", true)
		

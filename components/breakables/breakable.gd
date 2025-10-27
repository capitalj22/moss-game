extends Area2D

class_name Breakable

var isBroken = false;
@export var sprite_variations: Array[Texture2D] = [];
@onready var sprite: AnimatedSprite2D = $sprite
@onready var idle_sprite: Sprite2D = $idleSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	sprite.visible = false;
	idle_sprite.texture = sprite_variations[randi_range(0, sprite_variations.size() - 1)]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func destroy():
	if !isBroken:
		isBroken = true;
		idle_sprite.visible = false;
		sprite.visible = true;
		sprite.play("break")
	
	

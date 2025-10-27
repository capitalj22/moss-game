extends Area2D

@export var pxSet: ParallaxSet;
@export var from: int;
@export var to: int;

@export var sprites: Array[Sprite2D]

var isPlayerInside = false;

var alphaTween;

func shine():
	for sprite in sprites:
		var shineTween = create_tween().tween_property(sprite, "modulate", Color(2.433, 2.433, 2.433), 0.5).set_delay(0.3).set_ease(Tween.EASE_IN)
		
	
func dim():
	for sprite in sprites:
		var shineTween = create_tween().tween_property(sprite, "modulate", Color(1, 1, 1), 0.5).set_delay(0.3).set_ease(Tween.EASE_IN)
	
# Called when the node enters the scene tree for the first time.
func on_body_entered(body: Node2D):
	if body is Sherma:
		isPlayerInside = true
		shine();

		
func on_body_exited(body: Node2D):
	if body is Sherma:
		isPlayerInside = false
		#alphaTween = create_tween().tween_property($light, "energy", 0, 0.2)
		dim();
	
	
func _ready() -> void:
	self.body_entered.connect(on_body_entered)
	self.body_exited.connect(on_body_exited)
	
func _process(delta: float) -> void:
	if isPlayerInside:
		if Input.is_action_just_pressed("move_up_p1"):
			pxSet.shiftDown()
		if Input.is_action_just_pressed("move_down_p1"):
			pxSet.shiftUp()
			
		
		

extends Node2D

@export var relativeParent: Node2D;
@export var pxSet: ParallaxSet;

var isPlayerInside = false;
var alphaTween;

func on_body_entered(body: Node2D):
	if body is Sherma:
		var isPlayerInside = true;
		if relativeParent.get_index() > pxSet.activeLayer:
			alphaTween = create_tween().tween_property(self, "modulate:a", 0, 0.5).set_delay(0.3).set_ease(Tween.EASE_IN)
		pass;
		
func on_body_exited(body: Node2D):
	if body is Sherma:
		alphaTween = create_tween().tween_property(self, "modulate:a", 1, 0.2)
		pass;
	
func _ready() -> void:
	self.body_entered.connect(on_body_entered)
	self.body_exited.connect(on_body_exited)


func _process(delta: float) -> void:
	pass

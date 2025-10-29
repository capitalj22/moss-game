extends Node2D

class_name ParallaxSetLayer

@export var autoHideWhenBehind = false;
@export var pxSet: ParallaxSet;
@export var layer: int;
@export var initialHeight = 0.0;

var isVisible = true;
var visibleTween;

func on_active_layer_changed(activeLayer: int):
	pass;
	if isVisible && autoHideWhenBehind && activeLayer < layer:
		isVisible = false;
		visibleTween = create_tween().tween_property(self, "modulate:a", 0, 0.5).set_ease(Tween.EASE_OUT)
	elif !isVisible:
		isVisible = true;
		visibleTween = create_tween().tween_property(self, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pxSet.activeLayerChanged.connect(on_active_layer_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@icon("res://addons/custom_nodes/icon_cpx.svg")
extends Parallax2D
class_name ControlledPx2D

@export var relativeScrollScale: float = 0.01
@export var autoHide = false;

var scrollScaleTween;
var scaleTween;
var offsetTween;

var layerScale;
var scrollTime;
var yOffset;
	
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update(newYOffset, newLayerScale, newScrollTime): 
	layerScale = newLayerScale;
	scrollTime = newScrollTime
	yOffset = newYOffset
	
	tweenLayer()

func tweenLayer():
	scrollScaleTween = create_tween().tween_property(self, "scroll_scale", Vector2(layerScale, layerScale), scrollTime).set_ease(Tween.EASE_IN)
	scaleTween = create_tween().tween_property(self, "scale", Vector2(layerScale, layerScale), scrollTime).set_ease(Tween.EASE_IN)
	offsetTween = create_tween().tween_property(self, "scroll_offset:y", yOffset, scrollTime).set_ease(Tween.EASE_IN)

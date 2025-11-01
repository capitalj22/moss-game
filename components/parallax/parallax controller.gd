extends Node2D

@export var layers: Array[PxLayer];
@export var player: Sherma;
@export var camera: Camera2D;
@export var activeLayer = 0;

@export var scrollScale = 0.15;
@export var scrollTime = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layerToSet = activeLayer;
	activeLayer = null;
	
	change_active_layer(layerToSet)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_1"):
		var newActiveLayer = clamp(activeLayer + 1, 0, layers.size() - 1)
		change_active_layer(newActiveLayer)
	if Input.is_action_just_pressed("debug_2"):
		var newActiveLayer = clamp(activeLayer - 1, 0, layers.size() - 1)
		change_active_layer(newActiveLayer)
	pass

func change_active_layer(newActiveLayer):
	if newActiveLayer == activeLayer:
		return;
		
	activeLayer = newActiveLayer;
	var baseZPosition = layers[activeLayer].zPosition;
	
	for layerIndex in range(layers.size()):
		#consider telling each layer which index it is
		layers[layerIndex].update(newActiveLayer, layerIndex, scrollScale, scrollTime, baseZPosition)
	camera.shake(4)

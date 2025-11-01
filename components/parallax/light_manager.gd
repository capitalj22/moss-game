@icon("res://addons/custom_nodes/icon_lightmanager.svg")
extends Node2D

class_name pxLightManager;

@export var lights: Array[PointLight2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func updateLightRange(range):
	for light in lights:
		light.range_z_min = range - 2
		light.range_z_max = range + 1

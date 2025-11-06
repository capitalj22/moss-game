@icon("res://addons/custom_nodes/icon.svg")
extends Node2D
class_name PxLayer

@export var zPosition: float = 0.0;
@export var autohide = false;
@export var backgroundLayers: Array[ControlledPx2D] = [];
@export var floor: StaticBody2D;
@export var centerLayer: ControlledPx2D;
@export var foregroundLayers: Array[ControlledPx2D] = [];
@export var baseDepth = 1.0;
@export var worldHeight = 0.0;
@export var blurDistance: int;
@export var fogCurve: Curve;
@export var fog: Sprite2D;
@export var lightManager: pxLightManager;
@export var compactnessCurve: Curve;

const COMPACTNESS_CURVE = preload("res://components/parallax/compactness.curve.tres")

var amIInTheForeground = false;
var amIInTheBackground = false;
var amITheCurrentLayer = false;

func _ready():
	self.position = Vector2(0, worldHeight * -1)
		

func update(newActiveLayer, myIndex, scrollScale: float, scrollTime: float, baseZPosition: float):
	amIInTheForeground = myIndex > newActiveLayer;
	amIInTheBackground = myIndex < newActiveLayer;
	amITheCurrentLayer = myIndex == newActiveLayer;
	
	var relativeDistance = myIndex - newActiveLayer;
	var distance = abs(myIndex - newActiveLayer);
	var realDistance = self.zPosition - baseZPosition;
	var compactnessFactor = 1;
	
	
	if realDistance != 0.0:
		compactnessFactor = 1 / abs(realDistance / 3)	
	
	if fog:
		fog.visible = amIInTheBackground;
		if fogCurve:
			fog.density = fogCurve.sample_baked(distance * 0.5)

	
	if (blurDistance && distance >= blurDistance):
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
	
	floor.set_collision_layer_value(4, myIndex == newActiveLayer)
	
	if amIInTheForeground && autohide:
		visible = false;
	else:
		visible = true;
		
	z_index = (myIndex - newActiveLayer) + 1
	
	if lightManager:
		lightManager.updateLightRange(z_index)
		
	var centerZPosition = zPosition - baseZPosition
	var centerScrollScale = 1 + centerZPosition * scrollScale * 0.1;
	var offsetFactor =  (centerZPosition * scrollScale * 0.1) * worldHeight * -1
	
	if amITheCurrentLayer: 
		offsetFactor = 0;
	
	centerLayer.update(offsetFactor, centerScrollScale, scrollTime, baseZPosition, false);
	update_background_layers(centerScrollScale, scrollTime, compactnessFactor, offsetFactor, scrollScale, baseZPosition)
	update_foreground_layers(centerScrollScale, scrollTime, compactnessFactor, offsetFactor, scrollScale, baseZPosition)
		

func update_background_layers(baseScale, scrollTime, compactnessFactor, offsetFactor, scrollScale, baseZPosition):
	var cumulativeScale = baseScale;
	
	for layerIndex in range(backgroundLayers.size()):
		var layer: ControlledPx2D = backgroundLayers[layerIndex]
		var distanceFromCenter = abs(baseZPosition - layer.relativeZPosition);
		var compactness = COMPACTNESS_CURVE.sample_baked(distanceFromCenter);
		var layerScale = cumulativeScale - (layer.relativeZPosition * 0.1 * compactness);
		
		print(layer, compactness)		
		
		cumulativeScale = layerScale;
		var yOffset = offsetFactor;
		
		layer.update(yOffset, layerScale, scrollTime, baseZPosition, amIInTheForeground);
		
func update_foreground_layers(baseScale, scrollTime, compactnessFactor, offsetFactor, scrollScale, baseZPosition):
	var cumulativeScale = baseScale;
	
	for layerIndex in range(foregroundLayers.size()):
		var layer: ControlledPx2D = foregroundLayers[layerIndex]
		var distanceFromCenter = abs(baseZPosition - layer.relativeZPosition);
		var compactness = COMPACTNESS_CURVE.sample_baked(distanceFromCenter);
		var layerScale = cumulativeScale + (layer.relativeZPosition * 0.1 * compactness);
		
		cumulativeScale = layerScale;
		var yOffset = offsetFactor;
		
		layer.update(yOffset, layerScale, scrollTime, baseZPosition, amIInTheForeground);

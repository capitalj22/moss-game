extends Node2D

class_name ParallaxSet;

@export var scrollFactor = 0.1;
@export var scrollTime = 0.5;

@onready var layer_1: Parallax2D = $layer_1/fg
@onready var layer_2: Parallax2D = $layer_2/fg
@onready var layer_3: Parallax2D = $layer_3/fg

@onready var layers = [
	{ "node": $layer_0, "px": $layer_0/fg, "floor": $layer_0/fg/Floor, "fg_layers": $"layer_0/foreground_layers", "bg_layers": $"layer_0/background_layers" },
	{ "node": $layer_1, "px": $layer_1/fg, "floor": $layer_1/fg/Floor, "fg_layers": $"layer_1/foreground_layers", "bg_layers": $"layer_1/background_autohide/background_layers" },
	{ "node": $layer_2, "px": $layer_2/fg, "floor": $layer_2/fg/Floor, "fg_layers": $"layer_2/foreground_layers", "bg_layers": $"layer_2/background_layers" },
	{ "node": $layer_3, "px": $layer_3/fg, "floor": $layer_3/fg/Floor, "fg_layers": $"layer_3/foreground_layers", "bg_layers": $"layer_3/background_layers" },
]


@export var player: Sherma;
@export var camera: Camera2D;
@export var activeLayer = 1;

signal activeLayerChanged;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for layer in layers:
		var layerNode: Node2D = layer.node;
		
		if layerNode is ParallaxSetLayer:
			print(layerNode);
			layerNode.position = Vector2(0, layerNode.initialHeight * -1);
		else:
			layerNode.position = Vector2(0, 0);
			
	updateLayers();
	
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_1"):
		shiftUp()
		
		
	if Input.is_action_just_pressed("debug_2"):
		shiftDown()
		
		
	
	
func shiftUp():
	activeLayer = clampi(activeLayer + 1, 0, 4)
	updateLayers("up");
	camera.shake(10)
	
	
func shiftDown():
	activeLayer = clampi(activeLayer - 1, 0, 4)
	updateLayers("down");
	camera.shake(10)

func updateLayers(direction = "up"):
	activeLayerChanged.emit(activeLayer);
	
	if direction == "down":
		player.ascend();
	var zoom = 1.3 - (activeLayer * 0.1)
	var zoomtween = create_tween().tween_property(camera, "zoom", Vector2(zoom, zoom), scrollTime)
	for index in range(layers.size()):
		var layer = layers[index];
		var zindex = index - activeLayer;
		var node: Node2D = layer.node;
		#node.z_index = zindex;
		
		match zindex:
			-1:
				node.get_node("fog").self_modulate.a = 0.2
			0:
				node.get_node("fog").self_modulate.a = 0.1
		
		if zindex > 0:
			node.get_node("fog").self_modulate.a = 0.1
			
		if zindex < -1:
			node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		else: 
			node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			
			
		var floor: StaticBody2D = layer.floor;
		var fg_layers: Node2D = layer.fg_layers;
		var bg_layers: Node2D = layer.bg_layers;
		
		#floor.position.y = (activeLayer - index) * -30
		
		floor.set_collision_layer_value(4, index == activeLayer)
		floor.set_collision_layer_value(10, false)
		floor.set_collision_layer_value(11, false)
		floor.set_collision_layer_value(12, false)
		floor.set_collision_layer_value(10 + index, true)
		
		floor.modulate.a = (1 if index == activeLayer else 0.2)
		
		var scroll_scale = 1 + ((index - activeLayer) * scrollFactor);
		var scale = 1 + ((index - activeLayer) * scrollFactor);
		
		var sstween = create_tween().tween_property(layer.px, "scroll_scale", Vector2(scroll_scale, scroll_scale), scrollTime).set_ease(Tween.EASE_OUT)
		var scaletween = create_tween().tween_property(layer.px, "scale", Vector2(scale, scale), scrollTime).set_ease(Tween.EASE_IN)
		
		var changeZindex = func(): node.z_index = zindex;
		
		if (direction == "up"):
			changeZindex.call()
		else:
			sstween.finished.connect(changeZindex)
		
		
		for layerIndex in range(fg_layers.get_children().size()):
			var px: Parallax2D = fg_layers.get_child(layerIndex)
			var pxScale = scale + 0.025 + (layerIndex * 0.015)
			
			
			var pxScrollScaleTween = create_tween().tween_property(px, "scroll_scale", Vector2(pxScale, pxScale), scrollTime).set_ease(Tween.EASE_IN)
			var pxScaleTween = create_tween().tween_property(px, "scale", Vector2(pxScale, pxScale), scrollTime).set_ease(Tween.EASE_IN)
			var pxOffsetTween = create_tween().tween_property(px, "scroll_offset:y", (layerIndex + 1) * -5, scrollTime).set_ease(Tween.EASE_IN)
		
		var numberOfBgLayers = bg_layers.get_children().size();
		
		for layerIndex in range(numberOfBgLayers):
			var px: Parallax2D = bg_layers.get_child(numberOfBgLayers - layerIndex - 1)
			#if index > activeLayer:
				#px.modulate.a = 0.4;
			#else:
				#px.modulate.a = 1;
			var pxScale = scale - ((layerIndex + 1) * 0.05)
			
			
			var pxScrollScaleTween = create_tween().tween_property(px, "scroll_scale", Vector2(pxScale, pxScale), scrollTime).set_ease(Tween.EASE_IN)
			var pxScaleTween = create_tween().tween_property(px, "scale", Vector2(pxScale, pxScale), scrollTime).set_ease(Tween.EASE_IN)
			var pxOffsetTween = create_tween().tween_property(px, "scroll_offset:y", (pxScale) * 10 + 15, scrollTime).set_ease(Tween.EASE_IN)
			
			pass;
	

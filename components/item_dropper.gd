extends Node2D

@export var items: Dictionary[String, ItemDropperResource] = {}

func dropAll():
	for item in items.keys():
		drop(item)
		
func drop(item: String):
	var itemToDrop = items[item];
	var numberOfItems = randi_range(itemToDrop.minItems, itemToDrop.maxItems);
	
	for i in range(numberOfItems):
		var itemInstance = itemToDrop.item.instantiate()
		itemInstance.global_position = global_position;	
		itemInstance.linear_velocity = Vector2(randf_range(-10, 10), randf_range(-30, -10))
		itemInstance.z_index = -1;
		
		get_tree().current_scene.add_child(itemInstance)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

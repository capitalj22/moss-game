extends Area2D

@export var player: Node2D;
signal pogoed;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(on_body_entered)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_body_entered(body: Node2D):
	# replace with generic damage taking component
	if body.has_method("pogo"):
		pogoed.emit();
		

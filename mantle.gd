extends Area2D

@export var left = true;
signal entered;
signal exited;
# Called when the node enters the scene tree for the first time.


func on_body_entered(body: Node2D):
		if body is Sherma:
			if body.global_position.y > global_position.y || (body.global_position.y > global_position.y - 10 && body.velocity.y > 0):
				entered.emit(left, global_position)

func on_body_exited(body: Node2D):
	if body is Sherma:
		exited.emit();
		
func _ready() -> void:
	self.body_entered.connect(on_body_entered);
	self.body_exited.connect(on_body_exited);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Area2D

var isShronking = false;
var isUnshronking = false;
var initialYScale;
var initialYPosition;
@export var SHRINKINESS = 0.7;
const SHRINK_SPEED = 4;

func shronk():
	isShronking = true
	isUnshronking = false;

	pass;
	
func unshronk():
	isShronking = false;
	isUnshronking = true;
	pass;
	
func on_body_entered(body):
	if (body.name == "player1" || body.name == "mossgrub"):
		shronk()
		
func on_body_exited(body):
	if (body.name == "player1" || body.name == "mossgrub"):
		unshronk()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(on_body_entered)
	self.body_exited.connect(on_body_exited)
	initialYScale = $moss.scale.y;
	initialYPosition = $moss.global_position.y;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var yScale = $moss.scale.y;
	var yPosition = $moss.global_position.y;
	
	if (isShronking):
		if (yScale > initialYScale *SHRINKINESS):
			var newYScale = max(yScale - (delta * SHRINK_SPEED), initialYScale * SHRINKINESS)
			$moss.scale.y = newYScale
			$moss.global_position.y += newYScale * 0.05; 
			
		#$moss.scale.y = 0.9
	if (isUnshronking):
		var newYScale = min(initialYScale, yScale + (delta * SHRINK_SPEED * 2));
		if (yScale < initialYScale ):
			$moss.scale.y = newYScale
		if (yPosition > initialYPosition):			
			$moss.global_position.y -= newYScale * 0.05;
		
		if (yScale >= initialYScale && yPosition >= initialYPosition):
			isUnshronking = true;
			
			
	pass

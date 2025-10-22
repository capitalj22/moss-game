extends AnimatedSprite2D

var isActive = false;
var isFlashing = false;
var isFlashingOn = false;
var isFlashingOff = false;
var idleCounter = 0;
var toFlash = 0;
var rnd = RandomNumberGenerator.new();
var velocity = Vector2(0, 0);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.self_modulate.a = 0;
	$"../../../../TimeOfDay".segment_changed.connect(time_of_day_segment_changed)
	toFlash = rnd.randi_range(20, 200);
	pass # Replace with function body.

func time_of_day_segment_changed(segment: String):
	if (segment == "night" || segment == "evening"):
		isActive = true;
	else:
		isActive = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isActive || isFlashingOff):
		if (isFlashing):
			position.x += velocity.x;
			position.y += velocity.y;
			if (isFlashingOn):
				
				self.self_modulate.a +=0.01;
				
				if (self.self_modulate.a >= 0.9):
					isFlashingOn = false;
					isFlashingOff = true;
			else:
				self.self_modulate.a -=0.01;
				if (self.self_modulate.a <= 0):
					isFlashing = false;
					isFlashingOff = false;
		else:
			idleCounter+=1;
			
			if (idleCounter >= toFlash):
				position.x = rnd.randf_range(-300, 300);
				position.y = rnd.randf_range(-30, 60);
				#position.y = rnd.randfn(-30, 30);
				idleCounter = 0;
				isFlashing = true;
				isFlashingOn = true;
				self.play("flash")
				velocity = Vector2(rnd.randf_range(-2, 2), rnd.randf_range(-2, 2)) * 0.02
			
			
	pass

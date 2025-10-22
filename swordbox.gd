extends ShapeCast2D

class_name PlayerAttackCollision
@export var hitSound: AudioStreamPlayer2D
@export var player: Node2D;

signal pogo;
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if (is_colliding()):
		for i in get_collision_count():
			var collider = get_collider(i);
			
			
			if self.get_meta("pogo") && collider.has_meta("canPogo"):
				var material = "";
				if collider.has_meta("material"):
					material = collider.get_meta("material")
				#var material = collider.get_meta("material");
				
				pogo.emit(material);
	
			if collider is EnemyHurtbox:
				var collisionNormal = get_collision_normal(i)
				var collisionPoint = get_collision_point(i)
				
				if (hitSound):
					if !hitSound.playing:
						hitSound.pitch_scale = randf_range(0.95, 1.05)
						hitSound.play()
				collider.on_hit(collisionNormal, collisionPoint);

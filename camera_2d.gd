extends Camera2D

var p1pos;
var p2pos;

const MAX_ZOOM = 1.2;
const MIN_ZOOM = 0.8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var average = p1pos.lerp(p2pos, 0.5);
	var distance = p1pos - p2pos;
	var zoomFactor = 1 - (abs(distance.x) + 150) / 600;
	
	var default_zoom = Vector2(1, 1);
	var zoomlvl = 1 + zoomFactor;
	
	if (zoomlvl < MAX_ZOOM && zoomlvl > MIN_ZOOM):
		zoom = Vector2(default_zoom.x + zoomFactor, default_zoom.y + zoomFactor)
		
	position = Vector2(average.x - 220, average.y - 400)
	#position = Vector2($player.position.x, $player.position.yd)
	pass

func _on_player_1_moved(position) -> void:
	p1pos = position;
	
	pass # Replace with function body.


func _on_player_2_moved(position) -> void:
	p2pos = position;
	pass # Replace with function body.

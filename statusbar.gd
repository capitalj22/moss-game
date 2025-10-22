extends CanvasLayer

@export var player: Sherma;
var currentHP;

@onready var masks = {
	1: {"control": $"Control/mask1", "full": true},
	2: {"control": $"Control/mask2", "full": true},
	3: {"control": $"Control/mask3", "full": true},
	4: {"control": $"Control/mask4", "full": true},
}

func destroyMask(maskNumber: int):
	var mask = masks[maskNumber];
	
	if mask.full:
		mask.control.play("damage");
		mask.full = false;
	
func updateHP():
	if currentHP > 0:
			
		var totalMasks =  masks.keys().size()
		var numberOfEmptyMasks = totalMasks - currentHP;
		
		for maskindex in range(numberOfEmptyMasks):
			destroyMask(totalMasks - maskindex)

		
	
func on_sherma_damaged():
	currentHP = player.HP;
	updateHP();
	
	pass;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.damaged.connect(on_sherma_damaged);
	currentHP = player.HP;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

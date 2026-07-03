class_name PickUp extends EquipItem
# TODO: This should be using Components instead and so should the inventory. 
# This could use a Storable / Storage Component pair respectively

@onready var pick_up_area: Area2D = %Area2D;

var player: Player;

func _ready() -> void:
	super();
	pick_up_area.body_entered.connect(_on_body_entered);

func equip() -> void:
	player.player_inventory.add_to_inventory(self);
	queue_free(); # TODO: Would this be considered consumable?

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		player = body;
		equip();

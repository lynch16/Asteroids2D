class_name PlayerInventory extends Node

var gold_count: int = 0;

signal gold_count_updated(gold_count: int);

func _add_gold(gold_to_add: int) -> void:
	gold_count += gold_to_add;
	gold_count_updated.emit(gold_count);
	SignalBus.on_player_gold_updated(gold_count);

func _spend_gold(gold_to_spend: int) -> void:
	gold_count -= gold_to_spend;
	gold_count_updated.emit(gold_count);
	SignalBus.on_player_gold_updated(gold_count);

func add_to_inventory(item: EquipItem) -> void:
	if (item is PickUp):
		if (item is GoldOrePickUp):
			var gold_pickup: GoldOrePickUp = item;
			_add_gold(gold_pickup.gold_value);
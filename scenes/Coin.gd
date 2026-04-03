extends Interactable
class_name CoinInteraction

@export var item_data: ItemData

func interact() -> void:
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		inventory.add_item(item_data)
		self.queue_free()

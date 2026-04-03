extends Control
class_name InventorySlot

var item_data: ItemData = null

func is_empty() -> bool:
	return item_data == null

func set_item(item: ItemData) -> void:
	item_data = item
	if item:
		$TextureRect.texture = item.item_icon
	else:
		$TextureRect.texture = null

extends Control
class_name Inventory

var item_slots_count: int = 5
var inventory_slot_prefab: PackedScene = load("res://scenes/InventorySlot.tscn")
@onready var inventory_grid: GridContainer = %GridContainer
var inventory_slots: Array[InventorySlot] = []
var inventory_full: bool = false

func _ready() -> void:
	add_to_group("inventory")
	for i in item_slots_count:
		var slot = inventory_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		inventory_slots.append(slot)
		
func add_item(item: ItemData) -> bool:
	for slot in inventory_slots:
		if slot.is_empty():
			slot.set_item(item)
			return true
	inventory_full = true
	return false

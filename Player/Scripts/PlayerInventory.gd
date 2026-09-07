extends Node
class_name PlayerInventory


# ============================================================
# SINAIS
# ============================================================

signal item_added(item: ItemData)
signal item_removed(item: ItemData)
signal slot_selected(slot: int)
signal inventory_cleared

const QUICK_SLOT_COUNT: int = 5

 
var items: Array[ItemData] = []

var quick_slots: Array[ItemData] = [
	null,
	null,
	null,
	null,
	null
]

var selected_slot: int = 0


# ============================================================
# ADICIONAR ITEM
# ============================================================

func add_item(item: ItemData) -> bool:

	if item == null or item in items :
		return false
	items.append(item)
	item_added.emit(item)

	return true


# ============================================================
# REMOVER ITEM
# ============================================================

func remove_item(item: ItemData) -> bool:
	if item == null or item in items :
		return false
	items.erase(item)

	# Remove dos quick slots
	for i: int in range(quick_slots.size()):

		if quick_slots[i] == item:
			quick_slots[i] = null

	item_removed.emit(item)

	return true


# ============================================================
# PEGAR ITEM
# ============================================================

func get_item(index: int) -> ItemData:

	if index < 0:
		return null

	if index >= items.size():
		return null

	return items[index]


# ============================================================
# QUICK SLOT
# ============================================================

func set_quick_slot(
	slot: int,
	item: ItemData
) -> bool:

	if slot < 0:
		return false

	if slot >= quick_slots.size():
		return false

	# Só aceita item que esteja no inventário
	if item != null and not item in items:
		return false

	quick_slots[slot] = item

	return true


func get_quick_slot(slot: int) -> ItemData:

	if slot < 0:
		return null

	if slot >= quick_slots.size():
		return null

	return quick_slots[slot]


# ============================================================
# SELECIONAR SLOT
# ============================================================

func select_slot(slot: int) -> bool:

	if slot < 0:
		return false

	if slot >= quick_slots.size():
		return false

	if selected_slot == slot:
		return false

	selected_slot = slot

	slot_selected.emit(slot)

	return true


func get_selected_item() -> ItemData:

	if selected_slot < 0:
		return null

	if selected_slot >= quick_slots.size():
		return null

	return quick_slots[selected_slot]


# ============================================================
# DROPAR ITEM SELECIONADO
# ============================================================

func drop_selected_item() -> ItemData:

	var item: ItemData = get_selected_item()

	if item == null:
		return null

	if not remove_item(item):
		return null

	return item


# ============================================================
# MOVER ITEM
# ============================================================

func move_item(
	from_index: int,
	to_index: int
) -> bool:

	if from_index < 0:
		return false

	if from_index >= items.size():
		return false

	if to_index < 0:
		return false

	if to_index >= items.size():
		return false

	if from_index == to_index:
		return false

	var temp: ItemData = items[from_index]

	items[from_index] = items[to_index]
	items[to_index] = temp

	return true


# ============================================================
# LIMPAR INVENTÁRIO
# ============================================================

func clear_inventory() -> void:

	items.clear()

	for i: int in range(quick_slots.size()):
		quick_slots[i] = null

	selected_slot = 0

	inventory_cleared.emit()

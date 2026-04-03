# Tutorial 7 - Basic 3D Game Mechanics & Level Design

## Pick Up Item & Inventory System

Player dapat mengambil objek (coin) di dalam level dan menyimpannya ke dalam sistem inventori yang ditampilkan di layar.

### Arsitektur & Script

#### CoinInteraction.gd
Script yang di-attach langsung ke node Coin (StaticBody3D). Extends dari class `Interactable` dan menangani logika pickup.

- Menggunakan `add_to_group("inventory")` untuk menemukan node Inventory di scene tree
- Memanggil `inventory.add_item(item_data)` untuk menyimpan item
- Memanggil `queue_free()` pada parent untuk menghapus coin dari scene setelah diambil

```gdscript
extends Interactable
class_name CoinInteraction

@export var item_data: ItemData

func interact() -> void:
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		inventory.add_item(item_data)
		get_parent().queue_free()
```

#### ItemData.gd
Resource class yang menyimpan data dari setiap item.

- `name` — nama item (contoh: "Coin")
- `icon` — Texture2D untuk ditampilkan di slot inventory
- `scene` — PackedScene untuk respawn item saat di-drop

```gdscript
class_name ItemData
extends Resource

@export var name: String
@export var icon: Texture2D
@export var scene: PackedScene
```

#### Inventory.gd
Mengontrol keseluruhan sistem inventory. Terdaftar di group `"inventory"` agar bisa ditemukan dari scene manapun.

- Membuat sejumlah InventorySlot secara dinamis saat `_ready()`
- Fungsi `add_item()` mencari slot kosong dan mengisi dengan item
- Toggle visibility inventory dengan tombol yang dikonfigurasi di Input Map

```gdscript
extends Control
class_name Inventory

var item_slots_count: int = 5
var inventroy_slot_prefab: PackedScene = load("res://scenes/InventorySlot.tscn")
@onready var inventory_grid: GridContainer = %GridContainer
var inventory_slots: Array[InventorySlot] = []

func _ready() -> void:
	add_to_group("inventory")
	for i in item_slots_count:
		var slot = inventroy_slot_prefab.instantiate() as InventorySlot
		inventory_grid.add_child(slot)
		inventory_slots.append(slot)

func add_item(item: ItemData) -> bool:
	for slot in inventory_slots:
		if slot.is_empty():
			slot.set_item(item)
			return true
	return false
```

#### InventorySlot.gd
Merepresentasikan satu slot pada inventory UI.

- `is_empty()` — mengecek apakah slot kosong
- `set_item()` — mengisi slot dan mengupdate UI (icon)

```gdscript
extends Control
class_name InventorySlot

var item_data: ItemData = null

func is_empty() -> bool:
	return item_data == null

func set_item(item: ItemData) -> void:
	item_data = item
	if item:
		$TextureRect.texture = item.icon
	else:
		$TextureRect.texture = null

```

---

### Polishing Inventory Interface

Setelah sistem fungsional berjalan, tampilan inventory dirapikan menggunakan struktur node UI berikut:

#### Struktur Node Inventory Panel

1. **Panel** — container utama inventory

2. **MarginContainer** — memberi padding di dalam Panel

3. **GridContainer** — menyusun slot secara grid

4. **InventorySlot** (scene) — tiap slot menggunakan Button sebagai root
   - Gunakan `Button` agar slot bisa diklik untuk drop item
   - Di dalam Button, tambahkan `TextureRect` untuk menampilkan icon item
   - Set `custom_minimum_size` pada Button agar ukuran slot konsisten (Pada projek ini menggunakan 64 X 64)

#### Mengupdate Icon di Slot

Di `InventorySlot.gd`, fungsi `set_item()` perlu mengupdate TextureRect saat item masuk atau slot dikosongkan:

- Saat item masuk: `$TextureRect.texture = item.icon`
- Saat slot dikosongkan (drop): `$TextureRect.texture = null`

#### Node Structure Lengkap

```
Player (CharacterBody3D)
└── Inventory (Control) — terdaftar di group "inventory"
	└── CanvasLayer
		└── Panel
			└── MarginContainer
				└── GridContainer
					└── [InventorySlot x N]

Coin.tscn (scene terpisah)
└── StaticBody3D (root) — CoinInteraction.gd di-attach disini
	├── MeshInstance3D
	└── CollisionShape3D
```

---

## Fitur 2 — Sprinting & Crouching

Player dapat bergerak dengan tiga mode kecepatan: jalan normal, berlari (sprint), dan berjongkok (crouch) dengan kecepatan lebih lambat dari normal.

### Implementasi

- Tiga variabel kecepatan: `speed` (normal), `run_speed` (sprint), `crouch_speed` (crouch)
- `is_crouching` boolean diupdate setiap frame berdasarkan input action `"crouch"`
- Kamera turun secara smooth saat crouch menggunakan `lerp()` pada `head.position.y`
- Input Map perlu ditambahkan action `"run"` dan `"crouch"` di Project Settings

```gdscript
# Crouch toggle
if Input.is_action_just_pressed("crouch"):
	is_crouching = true
if Input.is_action_just_released("crouch"):
	is_crouching = false

# Smooth camera crouch
var target_head_y = crouch_head_y if is_crouching else normal_head_y
head.position.y = lerp(head.position.y, target_head_y, 10.0 * delta)

# Speed selection
var current_speed: float
if is_crouching:
	current_speed = crouch_speed
elif Input.is_action_pressed("run"):
	current_speed = run_speed
else:
	current_speed = speed
```

### Nilai Default

| Variabel | Nilai | Keterangan |
|---|---|---|
| `speed` | 10.0 | Kecepatan jalan normal |
| `run_speed` | 18.0 | Kecepatan sprint |
| `crouch_speed` | 4.0 | Kecepatan jongkok |
| `crouch_head_y` | -0.5 | Offset kamera saat jongkok |

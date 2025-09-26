extends Resource
class_name UpgradeData

@export_group("Common Settings")
@export var upgrade_name: String = "Item Name"
@export var type: String = "ANY"
@export var ID: String = "Null"
@export_group("Extra")
@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary") var rarity: String = "Common"

@export_group("Display Settings")
@export var icon: Texture2D

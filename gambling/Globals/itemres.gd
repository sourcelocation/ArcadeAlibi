extends Resource
class_name ItemRes

@export var id: int = 0
@export var title: String = "Item"
@export var description: String = "Placeholder description"
@export var icon: Texture2D = PlaceholderTexture2D.new()
@export var is_tool: bool = false
@export var scene: PackedScene
@export var recipe: Dictionary[int,int]

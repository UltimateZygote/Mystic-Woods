extends TileMap

@onready var minimap = $CanvasLayer/UI/Minimap

func _ready():
	for object in get_tree().get_nodes_in_group("minimap_objects"):
		object.removed.connect(minimap._on_object_removed)
	$CanvasLayer.show()

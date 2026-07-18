extends Node3D

const LIBRARY_PATHS: Array[String] = [
	"res://assets/cars/Models/GLB format/",
	"res://assets/city commercial/Models/GLB format",
	"res://assets/city industrial/Models/GLB format",
	"res://assets/city roads/Models/GLB format/",
	"res://assets/city suburban/Models/GLB format/",
	"res://assets/cube pets/Models/GLB format/",
	"res://assets/graveyard/Models/GLB format/",
	"res://assets/mini characters/Models/GLB format/"
]

func _ready() -> void:
	var mesh_library = MeshLibrary.new()

	for path in LIBRARY_PATHS:
		var structures: Array[Resource] = []

		var dir := DirAccess.open(path)

		dir.list_dir_begin()
		for file: String in dir.get_files():
			if not file.contains("import"):
				var resource: Resource = load(dir.get_current_dir() + "/" + file)
				structures.push_front(resource)

		for structure in structures:

			var id = mesh_library.get_last_unused_item_id()

			mesh_library.create_item(id)
			mesh_library.set_item_mesh(id, structure)
			mesh_library.set_item_mesh_transform(id, Transform3D())

	var save_path = "res://my_mesh_library.tres"
	ResourceSaver.save(mesh_library, save_path)


# Retrieve the mesh from a PackedScene, used for dynamically creating a MeshLibrary
func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)

					return prop_value.duplicate()

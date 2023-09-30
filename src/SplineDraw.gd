extends Node

@export var mat: StandardMaterial3D = StandardMaterial3D.new()
@export var points: Array[Vector3]
var mesh : RuneMesh


func make_new_rune() -> RuneMesh:
	mesh = RuneMesh.new()
	mesh.generate_mesh()
	
	mat.no_depth_test = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.surface_set_material(0, mat)
	
	return mesh

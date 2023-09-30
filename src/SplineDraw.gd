extends MeshInstance3D

var mat: StandardMaterial3D = StandardMaterial3D.new()
var points: Array[Vector3]

func draw_line(begin_pos: Vector3, end_pos: Vector3, color: Color = Color.RED) -> void:
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(begin_pos)
	mesh.surface_add_vertex(end_pos)
	mesh.surface_end()

func draw_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
	var step: int = 15
	var sppi: float = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	mesh.surface_set_color(color)
	for axis in axes:
		for i in range(step + 1):
			mesh.surface_add_vertex(center + (axis[0] * radius)
				.rotated(axis[1], sppi * (i % step)))
	mesh.surface_end()

func draw_spline(points):
	if points.size() < 4:
		printerr("Need at least 4 points for Catmull-Rom Spline")
		return

	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)

	for i in range(1, points.size() - 2):
		for t in range(0, 100):
			var tt = t / 100.0
			var p = catmull_rom_spline(points[i-1], points[i], points[i+1], points[i+2], tt)
			mesh.surface_add_vertex(p)

	mesh.surface_end()
	
func catmull_rom_spline(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 = t * t
	var t3 = t2 * t

	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)
	
# Function to generate N points inside a given box.
func generate_points_in_box(n: int, min_point: Vector3, max_point: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = []
	for i in range(n):
		var x = randf_range(min_point.x, max_point.x)
		var y = randf_range(min_point.y, max_point.y)
		var z = randf_range(min_point.z, max_point.z)

		var point = Vector3(x, y, z)
		points.append(point)

	return points

func _ready():
	points = generate_points_in_box(10, Vector3.ONE * -2, Vector3.ONE * +2)
	
	mesh = ImmediateMesh.new()
	mesh.clear_surfaces()
	draw_spline(points)	
	
	mat.no_depth_test = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	set_material_override(mat)
	
	get_viewport().use_xr = false
	var xri : OpenXRInterface = XRServer.find_interface("OpenXR") as OpenXRInterface
	xri.uninitialize()
	
	

func _process(_delta):
	pass
	

extends ImmediateMesh

class_name RuneMesh

enum Element {
	Fire,
	Air,
	Earth,
	Water,
	Neutral
}

var manaType : Element = Element.Neutral

	
func catmull_rom_spline(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 = t * t
	var t3 = t2 * t

	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)
	
	
func add_line(begin_pos: Vector3, end_pos: Vector3, color: Color = Color.RED) -> void:
	surface_begin(PRIMITIVE_LINES)
	surface_set_color(color)
	surface_add_vertex(begin_pos)
	surface_add_vertex(end_pos)
	surface_end()

func add_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
	var step: int = 15
	var sppi: float = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	surface_begin(PRIMITIVE_LINE_STRIP)
	surface_set_color(color)
	for axis in axes:
		for i in range(step + 1):
			surface_add_vertex(center + (axis[0] * radius)
				.rotated(axis[1], sppi * (i % step)))
	surface_end()

func add_spline(new_points):
	if new_points.size() < 4:
		printerr("Need at least 4 points for Catmull-Rom Spline")
		return

	clear_surfaces()
	surface_begin(PRIMITIVE_LINE_STRIP)
	surface_set_color(get_rune_color())
	
	for i in range(1, new_points.size() - 2):
		for t in range(0, 100):
			var tt = t / 100.0
			var p = catmull_rom_spline(new_points[i-1], new_points[i], new_points[i+1], new_points[i+2], tt)
			surface_add_vertex(p)

	surface_end()

func get_rune_color() -> Color:
	match manaType:
		Element.Fire:
			return Color.RED
		Element.Water:
			return Color.BLUE
		Element.Air:
			return Color.GOLD
		Element.Earth:
			return Color.DARK_GREEN
	return Color.DIM_GRAY

# Function to generate N points inside a given box.
func generate_points_in_box(n: int, min_point: Vector3, max_point: Vector3) -> Array[Vector3]:
	var new_points : Array[Vector3] = []
	for i in range(n):
		var x = randf_range(min_point.x, max_point.x)
		var y = randf_range(min_point.y, max_point.y)
		var z = randf_range(min_point.z, max_point.z)

		new_points.append(Vector3(x, y, z))

	return new_points
	
func generate_mesh():
	manaType = randi_range(Element.Fire, Element.Neutral)
	
	clear_surfaces()
	var points : Array[Vector3]
	points.append(Vector3.ZERO)
	points.append_array(generate_points_in_box(10, Vector3.ONE * -0.3, Vector3.ONE * +0.3))
	add_spline(points)
	

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
var runePoints : Array[Vector3]

const SMOOTH_STEPS = 30
const FLAT_STEPS = 4
	
func catmull_rom_spline(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 = t * t
	var t3 = t2 * t

	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)
	
	
func add_lines(point_pairs: Array[Vector3], color: Color = Color.RED) -> void:
	surface_begin(PRIMITIVE_LINES)
	surface_set_color(color)
	for p in point_pairs:
		surface_add_vertex(p)
	if(point_pairs.size() & 1):
		surface_add_vertex(point_pairs[0]) # Loop back
	surface_end()

func add_strip(points: Array[Vector3], color: Color = Color.RED) -> void:
	surface_begin(PRIMITIVE_LINE_STRIP)
	surface_set_color(color)
	for p in points:
		surface_add_vertex(p)
	surface_end()

func add_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
	var step: int = 15
	var sppi: float = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	
	var points: Array[Vector3]
	for axis in axes:
		for i in range(step + 1):
			points.append(center + 
			(axis[0] * radius).rotated(axis[1], sppi * (i % step)))
	
	add_strip(points)

func add_cube(minPt: Vector3, maxPt: Vector3, color: Color = Color.RED) -> void:
	var corners : Array[Vector3] = [
		Vector3(minPt.x, minPt.y, minPt.z),  # 0
		Vector3(maxPt.x, minPt.y, minPt.z),  # 1
		Vector3(maxPt.x, maxPt.y, minPt.z),  # 2
		Vector3(minPt.x, maxPt.y, minPt.z),  # 3
		Vector3(minPt.x, minPt.y, maxPt.z),  # 4
		Vector3(maxPt.x, minPt.y, maxPt.z),  # 5
		Vector3(maxPt.x, maxPt.y, maxPt.z),  # 6
		Vector3(minPt.x, maxPt.y, maxPt.z)   # 7
	]
	
	add_strip([corners[0], corners[1], corners[2], corners[3], corners[0], corners[4], corners[5], corners[1]], color)
	add_strip([corners[5], corners[6], corners[2], corners[3], corners[7], corners[4]], color)
	add_strip([corners[7], corners[6]], color)

func add_cube_extent(center: Vector3, size: float = 1.0, color: Color = Color.RED) -> void:
	add_cube(
		center + Vector3.ONE * size * -0.5,
		center + Vector3.ONE * size * +0.5,
		color)

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
			var p = catmull_rom_spline(new_points[-i], new_points[i], new_points[i+1], new_points[i+2], tt)
			surface_add_vertex(p)

	surface_end()

func add_ring(p : Vector3, dir : Vector3, radius : float, sides : int):
	var right = dir.normalized().cross(Vector3.UP)  # Side vector, perpendicular to the direction of the spline.
		
	for j in range(sides + 1):
		var angle = j * 2.0 * PI / sides
		var offset = radius * (right * cos(angle) + Vector3.UP * sin(angle))
		surface_add_vertex(p + offset)
		surface_add_vertex(p - offset)

func add_cap(p0 : Vector3, p1 : Vector3, r0 : float, r1 : float, sides : int):
	for i in range(0,5):
		add_ring(p0.lerp(p1, i / 5.0), p1 - p0, lerp(r0, r1,  i / 5.0), sides)
	
func add_smooth_tube(new_points : Array[Vector3], radius : float, sides : int):
	if new_points.size() < 4:
		printerr("Need at least 4 points for Catmull-Rom Spline")
		return

	surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surface_set_color(get_rune_color())
	
	add_cap(
		new_points[0] + (new_points[0] - new_points[1]).normalized() * radius,
		new_points[0],
		0,
		radius,
		sides
	)

	for i in range(1, new_points.size() - 2):
		var tStep = 1.0 / float(SMOOTH_STEPS)
		for t in range(0, SMOOTH_STEPS):
			var tt = t * tStep
			var p = catmull_rom_spline(new_points[i - 1], new_points[i], new_points[i + 1], new_points[i + 2], tt)
			var next_p = catmull_rom_spline(new_points[i - 1], new_points[i], new_points[i + 1], new_points[i + 2], min(tt + 0.01, 1.0))
			add_ring(p, (next_p - p), radius, sides)

	add_cap(
		new_points[-1] + (new_points[-1] - new_points[-2]).normalized() * radius,
		new_points[-1],
		radius,
		0,
		sides
	)
		
	surface_end()
	
func add_flat_tube(new_points : Array[Vector3], radius : float, sides : int):
	if new_points.size() < 2:
		printerr("Need at least 2 points for Flat Spline")
		return

	surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surface_set_color(get_rune_color())  
	
	add_cap(
		new_points[0] + (new_points[0] - new_points[1]).normalized() * radius,
		new_points[0],
		0,
		radius,
		sides
	)
	
	for i in range(1, new_points.size()-2):
		var p0 = new_points[i-1]
		var p1 = new_points[i]
		var p2 = new_points[i+1]
		
		var d0 = p1 - p0
		var d1 = p2 - p1
		
		var tStep = 1.0 / (FLAT_STEPS)
		var tDblStep = 1.0 / (FLAT_STEPS * 0.5)
		
		for t in range(0, FLAT_STEPS):
			var p = p1
			if t < (FLAT_STEPS / 2):
				p -= d0.normalized() * radius * (t / (FLAT_STEPS / 2))
			else:
				p += d1.normalized() * radius * ((t-(FLAT_STEPS / 2)) / (FLAT_STEPS / 2))
			var d = d0.lerp(d1, tStep)
			
			add_ring(p,d, radius, sides)
				
	add_cap(
		new_points[-1] + (new_points[-1] - new_points[-2]).normalized() * radius,
		new_points[-1],
		radius,
		0,
		sides
	)
	
	surface_end()

func add_bulge(new_points : Array[Vector3], radius : float, color : Color):
	var step : float = PI*2/12.0
	
	for p in new_points:
		surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_set_color(color)
		
		for ang in Vector3(0.0, PI*2.0, step):
			surface_add_vertex(p + Vector3(0, -radius, 0))
			surface_add_vertex(p + Vector3(sin(ang), 0, cos(ang)) * radius) 
			surface_add_vertex(p + Vector3(sin(ang+step), 0, cos(ang+step))*radius)
			
		for ang in Vector3(0.0, PI*2.0, step):
			surface_add_vertex(p + Vector3(0, +radius, 0))
			surface_add_vertex(p + Vector3(sin(ang), 0, cos(ang)) * radius) 
			surface_add_vertex(p + Vector3(sin(ang+step), 0, cos(ang+step))*radius)
		surface_end()
	#

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
	
func generate_fire_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	# var deltaPt = maxPt - minPt
	var invPt : float = 1.0 / float(num_points)
	var yStep : float = maxPt.y * invPt
	var yHeight : float = 0
	var last_dir : Vector3 = Vector3.ZERO
	
	for i in range(num_points - 1):
		if i & 1:
			yHeight += randf_range(yStep*1.5, yStep*2.0)
		else:
			yHeight -= randf_range(yStep*0.5, yStep*1.1)
		
		var newPt = gen_pt(minPt, maxPt)
		newPt.y = yHeight
		
		var new_dir = (newPt - points[-i]).normalized()
		
		while new_dir.dot(last_dir) > 0.0:
			newPt = gen_pt(minPt, maxPt)
			newPt.y = yHeight
			new_dir = (newPt - points[-i]).normalized()
		
		points.append(newPt)
	
	return points

func generate_water_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	# var deltaPt = maxPt - minPt
	var invPt : float = 1.0 / float(num_points)
	var yStep : float = minPt.y * invPt
	var yHeight : float = 0
	var last_dir : Vector3 = Vector3.ZERO
	
	for i in range(num_points - 1):
		if i & 1:
			yHeight += randf_range(yStep*1.5, yStep*2.0)
		else:
			yHeight -= randf_range(yStep*0.5, yStep*1.1)
		
		var newPt = gen_pt(minPt, maxPt)
		newPt.y = yHeight
		
		var new_dir = (newPt - points[-i]).normalized()
		
		while new_dir.dot(last_dir) < 0.0:
			newPt = gen_pt(minPt, maxPt)
			newPt.y = yHeight
			new_dir = (newPt - points[-i]).normalized()
		
		points.append(newPt)
	
	return points

func biggest_circle_on_plane_inside_box(p : Plane, minPt : Vector3, maxPt : Vector3) -> float:
	var bigR : float = INF
	
	for c in [
		Vector3(minPt.x, minPt.y, minPt.z),
		Vector3(minPt.x, minPt.y, maxPt.z),
		Vector3(minPt.x, maxPt.y, minPt.z),
		Vector3(minPt.x, maxPt.y, maxPt.z),
		Vector3(maxPt.x, minPt.y, minPt.z),
		Vector3(maxPt.x, minPt.y, maxPt.z),
		Vector3(maxPt.x, maxPt.y, minPt.z),
		Vector3(maxPt.x, maxPt.y, maxPt.z)]:
			var r = (p.get_center() -  p.project(c)).length()
			bigR = min(r, bigR)
	return bigR

func polar_to_3d_on_plane(p: Plane, ang_in_rads: float, dist: float) -> Vector3:
	var local_point: Vector2 = Vector2(cos(ang_in_rads), sin(ang_in_rads)) * dist
	var p0cross = p.normal.cross(Vector3.UP if p.normal.is_equal_approx(Vector3.RIGHT) else Vector3.RIGHT).normalized()
	var plane_basis: Basis = Basis(
		p0cross,
		p.normal,
		p0cross.cross(p.normal))
	return p.get_center() + plane_basis * Vector3(local_point.x, 0, local_point.y)

func generate_air_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	var deltaPt = maxPt - minPt
	
	var rdir = gen_pt(minPt, maxPt).normalized()
	rdir = Vector3.UP
	
	# Find Exit Pt
	var t: float = 100000
	t = min(t, rdir.x / maxPt.x if (rdir.x > 0) else -minPt.x) if rdir.x > 0 else t;
	t = min(t, rdir.y / maxPt.y if (rdir.y > 0) else -minPt.y) if rdir.y > 0 else t;
	t = min(t, rdir.z / maxPt.z if (rdir.z > 0) else -minPt.z) if rdir.z > 0 else t;
	
	# var exit_pt : Vector3 = rdir * t
	var stepSz = (1.0 / t) / float(num_points)
		
	for i in range(num_points - 1):
		var p : Plane = Plane(rdir.normalized(), (i+1.0) * stepSz)
		var bigR : float = biggest_circle_on_plane_inside_box(p, minPt, maxPt)
		
		var newP = polar_to_3d_on_plane(p, randf_range(0, 2*PI), randf_range(0, bigR))
		points.append(newP)
	return points

func generate_earth_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	var deltaPt = maxPt - minPt
	
	var last_dir = 0
	var last_point = points[0]
	for i in range(num_points - 1):
		var new_dir = randi_range(1,6)
		@warning_ignore("integer_division")
		while (new_dir / 2) == (last_dir / 2):
			new_dir = randi_range(1,6)
		
		var dir : Vector3
		match new_dir:
			1: dir = Vector3.RIGHT * deltaPt.x * randf_range(-0.05,-0.2)
			2: dir = Vector3.RIGHT * deltaPt.x * randf_range(+0.05,+0.2)
			3: dir = Vector3.UP * deltaPt.y * randf_range(-0.05,-0.2)
			4: dir = Vector3.UP * deltaPt.y * randf_range(+0.05,+0.2)
			5: dir = Vector3.BACK * deltaPt.z * randf_range(-0.05,-0.2)
			6: dir = Vector3.BACK * deltaPt.z * randf_range(+0.05,+0.2)
		
		var new_point = clamp_pt(last_point + dir, minPt, maxPt)
		points.append(new_point)
		last_point = new_point
		last_dir = new_dir
	return points

func generate_neutral_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	var deltaPt = maxPt - minPt
	
	for i in range(num_points - 1):
		var new_point = gen_pt(
			clamp_pt(points[-1] - deltaPt*0.3, minPt, maxPt),
			clamp_pt(points[-1] + deltaPt*0.3, minPt, maxPt))
		points.append(new_point)
	return points

func gen_pt(min_point: Vector3, max_point: Vector3) -> Vector3:
	return Vector3(
		randf_range(min_point.x, max_point.x), 
		randf_range(min_point.y, max_point.y), 
		randf_range(min_point.z, max_point.z))

func clamp_pt(pt : Vector3, min_point: Vector3, max_point: Vector3) -> Vector3:
	return Vector3(
		min(max_point.x, max(min_point.x, pt.x)),
		min(max_point.y, max(min_point.y, pt.y)),
		min(max_point.z, max(min_point.z, pt.z)))

# Function to generate N points inside a given box.
func generate_points_in_box(n: int, min_point: Vector3, max_point: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	
	for i in range(n):
		points.append(gen_pt(min_point, max_point))

	return points
	
func generate_rune(elem : Element):
	var minPt = Vector3.ONE * -0.3
	var maxPt = Vector3.ONE * +0.3
	clear_surfaces()
	
	manaType = elem
	match elem:
		Element.Fire: 
			runePoints = generate_fire_points(10, minPt, maxPt)
			add_flat_tube(runePoints, 0.01, 6)
		Element.Air: 
			runePoints = generate_air_points(10, minPt, maxPt)
			add_smooth_tube(runePoints, 0.01, 6)
		Element.Earth: 
			runePoints = generate_earth_points(10, minPt, maxPt)
			add_flat_tube(runePoints, 0.01, 6)
		Element.Water: 
			runePoints = generate_water_points(10, minPt, maxPt)
			add_smooth_tube(runePoints, 0.01, 6)
		Element.Neutral: 
			runePoints = generate_neutral_points(10, minPt, maxPt)
			add_smooth_tube(runePoints, 0.01, 6)
	
	add_bulge(runePoints, 0.03, Color.ANTIQUE_WHITE)
	
	

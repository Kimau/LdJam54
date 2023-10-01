extends ArrayMesh

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
const POINT_SEP = 0.09
const END_SEP = 0.015
const NUM_SEGS = 16
	
func catmull_rom_spline(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var t2 = t * t
	var t3 = t2 * t

	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)
	
	
func add_lines(point_pairs: Array[Vector3], color: Color = Color.RED) -> void:
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	for p in point_pairs:
		cols.append(color)
		verts.append(p)
	if(point_pairs.size() & 1): # Loop back
		cols.append(color)
		verts.append(point_pairs[0]) 
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	self.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_array, [], {}, Mesh.ARRAY_FORMAT_VERTEX | Mesh.ARRAY_FORMAT_COLOR)

func add_strip(points: Array[Vector3], color: Color = Color.RED) -> void:
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	for p in points:
		cols.append(color)
		verts.append(p)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	self.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, surface_array, [], {}, Mesh.ARRAY_FORMAT_VERTEX | Mesh.ARRAY_FORMAT_COLOR)

func add_sphere(center: Vector3, radius: float = 1.0, color: Color = Color.RED) -> void:
	var step: int = 15
	var sppi: float = 2 * PI / step
	var axes = [
		[Vector3.UP, Vector3.RIGHT],
		[Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.FORWARD, Vector3.UP]
	]
	
	var points : Array[Vector3] = []
	
	for axis in axes:
		for i in range(step + 1):
			points.append(center + 
			(axis[0] * radius).rotated(axis[1], sppi * (i % step)))
	
	add_strip(points, color)

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

func addCubeToSurf(surface_array : Array, p0 : Vector3, p1 : Vector3, r0 : float, r1 : float, uv0 : float, uv1: float, col : Color):
	var minPt = Vector3(
		min(p0.x - r0, p1.x - r1),
		min(p0.y - r0, p1.y - r1),
		min(p0.z - r0, p1.z - r1))
	var maxPt = Vector3(
		max(p0.x + r0, p1.x + r1),
		max(p0.y + r0, p1.y + r1),
		max(p0.z + r0, p1.z + r1))
	
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
	
	# Define the indices for each quad in the cube
	var indices = [
		0, 1, 2, 0, 2, 3,  # Front face
		4, 5, 6, 4, 6, 7,  # Back face
		0, 1, 5, 0, 5, 4,  # Bottom face
		2, 3, 7, 2, 7, 6,  # Top face
		0, 3, 7, 0, 7, 4,  # Left face
		1, 2, 6, 1, 6, 5   # Right face
	]
	
	var idxBase = surface_array[ArrayMesh.ARRAY_VERTEX].size()
	for i in range(0, indices.size(), 6):
		for j in range(2):  # For each of the two triangles in a quad
			for k in range(3):  # For each vertex in a triangle
				var idx = indices[i + j * 3 + k]
				var c = corners[idx % corners.size()]  # Pos
				
				surface_array[ArrayMesh.ARRAY_VERTEX].append(c)
				surface_array[ArrayMesh.ARRAY_COLOR].append(col)
				if (c - p0).length() < (c - p1).length():
					surface_array[ArrayMesh.ARRAY_TEX_UV].append(Vector2(uv0, 0))
				else:
					surface_array[ArrayMesh.ARRAY_TEX_UV].append(Vector2(uv1, 0))

				# Compute the normal for each face of the cube
				if i < 6:    surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3( 0,  0, -1))  # Front face
				elif i < 12: surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3( 0,  0,  1))  # Back face
				elif i < 18: surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3( 0, -1,  0))  # Bottom face
				elif i < 24: surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3( 0,  1,  0))  # Top face
				elif i < 30: surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3(-1,  0,  0))  # Left face
				else:        surface_array[ArrayMesh.ARRAY_NORMAL].append(Vector3( 1,  0,  0))  # Right face
				
				surface_array[ArrayMesh.ARRAY_INDEX].append(idxBase + idx)
	

func add_cube_sploob(pts: PackedVector3Array):
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	var uvs = PackedVector2Array()
	var norms = PackedVector3Array()
	var idxs = PackedInt32Array()
		
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_array[ArrayMesh.ARRAY_NORMAL] = norms
	surface_array[ArrayMesh.ARRAY_INDEX] = idxs
	
	var runeCol = get_rune_color()

	# var noofPairs : int = pts.size() / 2
	var invT : float = 1.0 / float(pts.size())
	
	# var minPt = Vector3.ONE * -0.5
	# var maxPt = Vector3.ONE * +0.5
	
	for i in range(2, pts.size()-1, 2):
		addCubeToSurf(surface_array, 
		pts[i], pts[i-2], 
		pts[i+1].length(), pts[i-2+1].length(), 
		i*invT, (i-2)*invT,
		runeCol)
	
	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func add_thin_line(pts: PackedVector3Array):
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	var uvs = PackedVector2Array()
	var norms = PackedVector3Array()
	var idxs = PackedInt32Array()
	
	var invT : float = 1.0 / float(pts.size())
	
	var col = get_rune_color()
	
	for i in range(0, pts.size()-1, 2):
		var p0 = pts[i]
		var d0 = pts[i+1]
		
		idxs.append(verts.size())
		verts.append(p0)
		idxs.append(verts.size())
		verts.append(p0)
		cols.append(col)
		cols.append(col)
		uvs.append(Vector2(i*invT, -100))
		uvs.append(Vector2(i*invT, +100))
		norms.append(d0)
		norms.append(d0)
		
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_array[ArrayMesh.ARRAY_NORMAL] = norms
	self.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, surface_array, [], {}, 
	Mesh.ARRAY_FORMAT_VERTEX | Mesh.ARRAY_FORMAT_COLOR | Mesh.ARRAY_FORMAT_TEX_UV | Mesh.ARRAY_FORMAT_NORMAL)

func add_tube(pts: PackedVector3Array, sides: int):
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	var uvs = PackedVector2Array()
	var norms = PackedVector3Array()
	var idxs = PackedInt32Array()
	
	var runeCol = get_rune_color()

	@warning_ignore("integer_division")
	var noofPairs : int = pts.size() / 2	
	var invSides : float = 1.0 / float(sides)
	var invT : float = 1.0 / float(pts.size())
	
	if sides & 1:
		sides += 1 # Dont support odd sides
	
	var prevRing = []
	for j in range(sides):
		var ang = j * 2.0 * PI / sides
		prevRing.append(Vector3.UP * cos(ang) + Vector3.RIGHT * sin(ang))
	var prevNormal = Vector3.BACK
	
	for i in range(0, pts.size()-1, 2):
		var pos = pts[i]
		var dir = pts[i+1]
		
		var up = Vector3.UP 
		if abs(Vector3.UP.dot(dir)) < 0.8:
			if abs(Vector3.RIGHT.dot(dir)) < 0.8:
				up = Vector3.BACK
			else:
				up = Vector3.RIGHT
		var side = dir.normalized().cross(up).normalized()		
		up *= dir.length()
		side *= dir.length()
		
		# Align so the ring doesn't twist		
		var newRing = []
		for j in range(sides):
			var ang = j * 2.0 * PI / sides
			newRing.append(pos + up * cos(ang) + side * sin(ang))

		var optimal_offset = 0
		var min_total_angle_diff = INF

		for offset in range(sides):
			var total_angle_diff = 0.0
			for j in range(sides):
				var prevAng = atan2(prevRing[j].dot(prevNormal.cross(prevRing[0])), prevRing[j].dot(prevNormal))
				var newAng = atan2((newRing[(j + offset) % sides] - pos).dot(dir.cross(newRing[0] - pos)), (newRing[(j + offset) % sides] - pos).dot(dir))
				var angle_diff = fmod((prevAng - newAng + PI), (2 * PI)) - PI
				total_angle_diff += abs(angle_diff)
			
			if total_angle_diff < min_total_angle_diff:
				min_total_angle_diff = total_angle_diff
				optimal_offset = offset
		
		prevRing = newRing
		for j in range(sides):
			var jAdj = (j + optimal_offset) % (sides-1)
			verts.append(newRing[jAdj])
			cols.append(runeCol)
			uvs.append(Vector2(i * invT,jAdj * invSides))
			norms.append((newRing[jAdj] - pos).normalized())
	
	for i in range(noofPairs-1):
		for j in range(sides):
			# Current ring
			var idx0 = i * sides + j
			var idx1 = i * sides + (j + 1) % sides
			
			# Next ring
			var idx2 = (i + 1) * sides + j
			var idx3 = (i + 1) * sides + (j + 1) % sides
			
			# Append indices for two triangles forming a quad
			idxs.append(idx0)
			idxs.append(idx1)
			idxs.append(idx2)
			
			idxs.append(idx2)
			idxs.append(idx1)
			idxs.append(idx3)
	
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_array[ArrayMesh.ARRAY_NORMAL] = norms
	surface_array[ArrayMesh.ARRAY_INDEX] = idxs
	self.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array, [], {}, 
		Mesh.ARRAY_FORMAT_VERTEX | Mesh.ARRAY_FORMAT_COLOR | Mesh.ARRAY_FORMAT_TEX_UV | Mesh.ARRAY_FORMAT_NORMAL | Mesh.ARRAY_FORMAT_INDEX)

func add_bulge(new_points : Array[Vector3], radius : float, color : Color):
	var step : float = PI*2/12.0
	var verts = PackedVector3Array()
	var cols = PackedColorArray()
	
	for p in new_points:
		
		for ang in Vector3(0.0, PI*2.0, step):
			cols.append(color)
			cols.append(color)
			cols.append(color)
			
			verts.append(p + Vector3(0, -radius, 0))
			verts.append(p + Vector3(sin(ang), 0, cos(ang)) * radius) 
			verts.append(p + Vector3(sin(ang+step), 0, cos(ang+step))*radius)
			
		for ang in Vector3(0.0, PI*2.0, step):
			cols.append(color)
			cols.append(color)
			cols.append(color)
			
			verts.append(p + Vector3(0, +radius, 0))
			verts.append(p + Vector3(sin(ang), 0, cos(ang)) * radius) 
			verts.append(p + Vector3(sin(ang+step), 0, cos(ang+step))*radius)
			
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_COLOR] = cols
	self.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	#

####

func make_transform(p: Vector3, dir: Vector3, scale: float) -> Transform3D:
	var d0 = dir.normalized() * scale
	var d1 = Vector3.FORWARD * scale
	var d2 = d0.cross(d1).normalized() * scale
	
	var b = Basis(d0,d1,d2)
	if b.determinant() == 0:
		d1 = Vector3.RIGHT * scale
		d2 = d0.cross(d1).normalized() * scale
		b = Basis(d0,d1,d2)
	
	return Transform3D(b,p)

func get_smooth_tube(new_points: Array[Vector3], radius: float) -> PackedVector3Array:
	var pts : PackedVector3Array = []
	if new_points.size() < 4:
		printerr("Need at least 4 points for Catmull-Rom Spline")
		return pts
	
	# Add caps
	pts.append(new_points[0] + (new_points[0] - new_points[1]).normalized() * radius)
	pts.append((new_points[0] - new_points[1]).normalized() * radius * 0.1)
	
	for i in range(1, new_points.size() - 2):
		var t_step = 1.0 / float(SMOOTH_STEPS)
		for t in range(0, SMOOTH_STEPS):
			var tt = t * t_step
			var p = catmull_rom_spline(new_points[i - 1], new_points[i], new_points[i + 1], new_points[i + 2], tt)
			var dir = (catmull_rom_spline(new_points[i - 1], new_points[i], new_points[i + 1], new_points[i + 2], min(tt + 0.01, 1.0)) - p).normalized()
			pts.append(p)
			pts.append(dir*radius)
	pts.append(new_points[-1] + (new_points[-1] - new_points[-2]).normalized() * radius)
	pts.append((new_points[-2] - new_points[-1]).normalized() * radius * 0.1)
	return pts
	

func get_flat_tube(new_points: Array[Vector3], radius: float) -> PackedVector3Array:
	var pts : PackedVector3Array = []
	if new_points.size() < 2:
		printerr("Need at least 2 points for Flat Spline")
		return pts
		
	var t_step = 1.0 / float(FLAT_STEPS)
	
	var startDir = (new_points[1] - new_points[0]).normalized()
	for t in Vector3(0,1,t_step):
		pts.append(new_points[0] - (startDir * radius) * (1.0-t))
		pts.append(startDir * t*radius)
	
	for i in range(1, new_points.size()-1):
		var p0 = new_points[i-1]
		var p1 = new_points[i]
		var p2 = new_points[i+1]
		
		var d0 = (p1 - p0).normalized()
		var d1 = (p2 - p1).normalized()
		var dmid = d0.lerp(d1, 0.5)
		
		pts.append((p0+p1)*0.5)
		pts.append(d0*radius)
		
		for t in Vector3(0,1, t_step):
			var p = p1 - d0*(1.0 - t)*radius
			var dir = d0.lerp(dmid, t)
			pts.append(p)
			pts.append(dir.normalized() * radius)
		
		for t in Vector3(0,1, t_step):
			var p = p1 + d1*t*radius
			var dir = dmid.lerp(d1, t)
			pts.append(p)
			pts.append(dir.normalized() * radius)
		
		pts.append((p1+p2)*0.5)
		pts.append(d1.normalized() * radius)
	
	var endDir = (new_points[-1] - new_points[-2]).normalized()
	for t in Vector3(0,1,t_step):
		pts.append(new_points[-1] + (endDir * radius) * (t))
		pts.append(endDir * (1.0-t) * radius)
	
	return pts

####

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

func dist_to_nearest_point(points : Array[Vector3], newPt: Vector3) -> float:
	var nd = INF
	for p in points:
		var d = (newPt - p).length()
		if d < nd:
			nd = d
	return nd
	
func generate_fire_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	var yHeight : float = 0
	
	for i in range(num_points - 1):
		var t = float(i) / float(num_points-1)
		if i & 1:
			yHeight = randf_range(minPt.y, minPt.y*0.3)
		else:
			yHeight = randf_range(maxPt.y*0.3, maxPt.y)
		
		var p = Plane(Vector3.UP, yHeight)
		var r = biggest_circle_on_plane_inside_box(p, minPt, maxPt) * (1.2 - t)
		var newPt = polar_to_3d_on_plane(p, randf_range(0, 2*PI), randf_range(r*0.8, r))
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
			yHeight += randf_range(yStep*0.5, yStep*1.1)
		
		var newPt = gen_pt(minPt, maxPt)
		newPt.y = yHeight
		
		var new_dir = (newPt - points[-i]).normalized()
		
		while new_dir.dot(last_dir) < 0.0:
			newPt = gen_pt(minPt, maxPt)
			newPt.y = yHeight
			new_dir = (newPt - points[-i]).normalized()
		
		points.append(newPt)
	
	return points

func generate_air_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	#var deltaPt = maxPt - minPt
	
	var rdir
	var t = 1.0
	while true:
		rdir = gen_pt(minPt, maxPt).normalized()
	
		# Find Exit Pt
		t = 100000
		t = min(t, rdir.x / maxPt.x if (rdir.x > 0) else -minPt.x) if rdir.x > 0 else t;
		t = min(t, rdir.y / maxPt.y if (rdir.y > 0) else -minPt.y) if rdir.y > 0 else t;
		t = min(t, rdir.z / maxPt.z if (rdir.z > 0) else -minPt.z) if rdir.z > 0 else t;
		
		if t < 100000 and t > 0.5:
			break
	
	# var exit_pt : Vector3 = rdir * t
	var stepSz = (1.0 / t) / float(num_points)
		
	for i in range(num_points - 1):
		var p : Plane = Plane(rdir.normalized(), (i+1.0) * stepSz)
		var bigR : float = biggest_circle_on_plane_inside_box(p, minPt, maxPt)
		
		var newP = polar_to_3d_on_plane(p, randf_range(0, 2*PI), randf_range(0, bigR))
		points.append(newP)
	return points

func generate_earth_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
	var deltaPt = maxPt - minPt
	
	var last_dir = 0
	var last_point = points[0]
	for i in range(num_points - 1):
		var new_dir = randi_range(1,6)
		@warning_ignore("integer_division")
		while ((new_dir-1) / 2) == ((last_dir-1) / 2):
			new_dir = randi_range(1,6)
		
		var dir : Vector3
		match new_dir:
			1: dir = Vector3.RIGHT * deltaPt.x * randf_range(-0.05,-0.2)
			2: dir = Vector3.RIGHT * deltaPt.x * randf_range(+0.05,+0.2)
			3: dir = Vector3.UP * deltaPt.y * randf_range(-0.05,-0.2)
			4: dir = Vector3.UP * deltaPt.y * randf_range(+0.05,+0.2)
			5: dir = Vector3.BACK * deltaPt.z * randf_range(-0.05,-0.2)
			6: dir = Vector3.BACK * deltaPt.z * randf_range(+0.05,+0.2)
		
		var d = 1
		var new_point = clamp_pt(last_point + dir*d, minPt, maxPt)
		while(dist_to_nearest_point(points, new_point) < POINT_SEP):
			d += 1
			new_point = last_point + dir*d
		
		points.append(new_point)
		last_point = new_point
		last_dir = new_dir
	points.append(last_point)
	return points

func generate_neutral_points(num_points: int, minPt: Vector3, maxPt: Vector3) -> Array[Vector3]:
	var points : Array[Vector3] = [Vector3.ZERO]
	var deltaPt = maxPt - minPt
	
	for i in range(num_points - 1):
		var sep = 0.3
		while true:
			var new_point = gen_pt(
				clamp_pt(points[-1] - deltaPt*sep, minPt, maxPt),
				clamp_pt(points[-1] + deltaPt*sep, minPt, maxPt))
			if(dist_to_nearest_point(points, new_point) < (POINT_SEP*2)):
				sep += 0.1
				continue
			points.append(new_point)
			break;
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

func stretch_to_fit(points : Array[Vector3], minPt : Vector3, maxPt : Vector3) -> Array[Vector3]:
	# Get min/max
	var currMin = Vector3.ZERO
	var currMax = Vector3.ZERO
	for p in points:
		currMax.x = max(currMax.x, p.x)
		currMin.x = min(currMin.x, p.x)
		currMax.y = max(currMax.y, p.y)
		currMin.y = min(currMin.y, p.y)
		currMax.z = max(currMax.z, p.z)
		currMin.z = min(currMin.z, p.z)
	
	var delta = Vector3(
		min(minPt.x / currMin.x, maxPt.x / currMax.x),
		min(minPt.y / currMin.y, maxPt.y / currMax.y),
		min(minPt.z / currMin.z, maxPt.z / currMax.z))
		
	delta = clamp_pt(delta, Vector3(1.0,1.0,1.0), Vector3(2.0,2.0,2.0))
	
	var modPoints : Array[Vector3] = []
	for p in points:
		modPoints.append(Vector3(
				p.x * delta.x,
				p.y * delta.y,
				p.z * delta.z))

	return modPoints

func extend_ends(points : Array[Vector3]) -> Array[Vector3]:
	if points.size() < 3:
		return points

	var extended_points = points.duplicate()
	var testPt = extended_points[0]
	var dir = (extended_points[1] - extended_points[0]).normalized()

	var modified = false
	for i in range(1, points.size() - 1):
		for j in range(i + 1, points.size() - 1):
			var p1 = points[i]
			var p2 = points[j]
			var closestPt = Geometry3D.get_closest_point_to_segment(testPt, p1, p2)
			var segment_to_point = (closestPt - testPt).length()			
			if segment_to_point < END_SEP:
				modified = true
				var extend_length = END_SEP * 2 - segment_to_point
				testPt -= dir * extend_length
				
	# move everything else
	if modified:
		for i in range(1, points.size() - 1):
			extended_points[i] -= testPt
		
		modified = false
		
	testPt = extended_points[points.size() - 1]
	dir = (extended_points[points.size() - 2] - extended_points[points.size() - 1]).normalized()
		
	for i in range(0, points.size() - 2):
		for j in range(i + 1, points.size() - 2):
			var p1 = points[i]
			var p2 = points[j]
			var closestPt = Geometry3D.get_closest_point_to_segment(testPt, p1, p2)
			var segment_to_point = (closestPt - testPt).length()
			if segment_to_point < END_SEP:
				modified = true
				var extend_length = END_SEP * 2 - segment_to_point
				testPt -= dir * extend_length
	
	if modified:
		extended_points[points.size()-1] = testPt

	return extended_points
	
func generate_rune(elem : Element):
	var minPt = Vector3.ONE * -0.3
	var maxPt = Vector3.ONE * +0.3
	clear_surfaces()
	
	manaType = elem
	
	match manaType:
		Element.Fire: 
			runePoints = generate_fire_points(NUM_SEGS / 2, minPt, maxPt)
		Element.Air: 
			runePoints = generate_air_points(NUM_SEGS, minPt, maxPt)
		Element.Earth: 
			runePoints = generate_earth_points(NUM_SEGS, minPt, maxPt)
		Element.Water: 
			runePoints = generate_water_points(NUM_SEGS/2, minPt, maxPt)
		Element.Neutral: 
			runePoints = generate_neutral_points(NUM_SEGS, minPt, maxPt)

	make_surfaces()

func generate_bridge(elem : Element, pts : Array[Vector3]):
	manaType = elem
	
	runePoints = pts
	
	make_surfaces()

func make_surfaces():
	clear_surfaces()
	
	var tList : PackedVector3Array
	match manaType:
		Element.Fire: 
			tList = get_flat_tube(runePoints, 0.01)
		Element.Air: 
			tList = get_smooth_tube(runePoints, 0.01)
		Element.Earth: 
			tList = get_flat_tube(runePoints, 0.01)
		Element.Water: 
			tList = get_smooth_tube(runePoints, 0.01)
		Element.Neutral: 
			tList = get_smooth_tube(runePoints, 0.01)
	
	add_thin_line(tList)
	add_tube(tList, 8)


extends Node2D
class_name DebugCanvas

@export var debugFont :Font = ThemeDB.fallback_font

static var debug_map = {}
static var debug_lines = {}
static var debug_dirty = false
var toggle_key : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if not OS.is_debug_build():
		self.queue_free()

func _process(_delta):
	if Input.is_physical_key_pressed(KEY_HOME):
		if not toggle_key:
			self.visible = not self.visible
			toggle_key = true
			if self.visible:
				self.queue_redraw() 
	else:
		toggle_key = false
		
	if debug_dirty:
		debug_dirty = false
		self.queue_redraw() 

static func debug(key: String, var_to_add):
	if(debug_map.has(key) and debug_map[key] == var_to_add):
		return
		
	debug_map[key] = var_to_add
	debug_dirty = true
	
static func debug_line(key: String, src: Vector3, dst: Vector3):
	if(debug_lines.has(key) and debug_lines[key] == [src,dst]):
		return
		
	debug_lines[key] = [src,dst]
	debug_dirty = true

func clear():
	debug_map.clear()
	debug_lines.clear()

func _draw():
	# Sort keys
	var sorted_keys = debug_map.keys()
	sorted_keys.sort()
	
	draw_circle(Vector2(10,10), 1.0, Color.AQUAMARINE)
	
	# Draw each line
	for key in debug_lines:
		var line3d = debug_lines[key]
		var a = get_viewport().get_camera_3d().unproject_position(line3d[0])
		var b = get_viewport().get_camera_3d().unproject_position(line3d[1])
		draw_line(a,b, Color.RED)

	# Draw each key-value pair
	var y_offset = debugFont.get_height() * 1.5 # Start 10 units down for the first line
	for key in sorted_keys:
		draw_string(debugFont, Vector2(10, y_offset), "%s: %s" % [key, debug_map[key]],HORIZONTAL_ALIGNMENT_LEFT)
		y_offset += debugFont.get_height()

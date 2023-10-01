extends Node3D


@onready var hmd : VrRoot = $XROrigin3D

var input = {}
var prevIn = {}

var currRune : MagicRune
var placedRunes : Array[MagicRune] = []
var wantToSpawnRune : float = 0.0
var wantToCast : bool = false
var pendingRunes : Array[MagicRune] = []
var holingArea : Array[Area3D] = []

var spellEndPoint = Vector3.ZERO
var spellEndDir = Vector3.ZERO
var validPos = false
var liftingRune = false

const RUNE_PREFAB = preload("res://magic_rune.tscn")
const PEW_PREFAB = preload("res://pewParticles.tscn")
const SPELL_SNAP = 0.5*0.3

var partTip : GPUParticles3D
var partSpellEnd : GPUParticles3D
var partCollision : GPUParticles3D

func _ready() -> void:
	hmd.conLeft.button_pressed.connect(but_press_left)
	hmd.conRight.button_pressed.connect(but_press_right)
	hmd.conLeft.button_released.connect(but_release_left)
	hmd.conRight.button_released.connect(but_release_right)
	
	holingArea = []
	var holdAreas = hmd.pendingRunes.find_children("*", "Area3D")
	for kid in holdAreas:
		var a : Area3D = kid as Area3D
		if a:
			holingArea.append(a)
	
	new_spell_sequence()

func update_spell_stats():
	var spellLength = 0
	var spellBox : AABB = AABB()
	
	for p in placedRunes:
		spellLength += p.spellLength
		spellBox = spellBox.merge(p.get_bounds())
	
	var spellVol = spellBox.get_volume()
	
	hmd.spellStatLabel.text = "Spell: %d long and %d big" % [spellLength*100, spellVol*10000]

func new_spell_sequence():
	for r in pendingRunes:
		r.owner = null
		r.queue_free()
	
	for r in placedRunes:
		r.owner = null
		r.queue_free()
		
	if currRune:
		currRune.owner = null
		currRune.queue_free()
		currRune = null
	
	pendingRunes = []
	placedRunes = []
	for i in range(8):
		var rune = RUNE_PREFAB.instantiate()
		hmd.pendingRunes.add_child(rune)
		rune.owner = hmd.pendingRunes
		rune.reroll()
		rune.visible = false
		pendingRunes.append(rune)
	
	# Clean up
	for a in holingArea:
		var grandkids = a.find_children("*", "MagicRune")
		for gk in grandkids:
			a.remove_child(gk)
			gk.queue_free()
	
	refill_book()
	update_spell_stats()

func refill_book():
	var holdBits : int = 0
	for a in holingArea:
		var holdingRunes = a.find_children("*", "MagicRune")
		if holdingRunes.is_empty():
			continue
		holdBits |= 1 << (holdingRunes[0] as MagicRune).element
		
	for a in holingArea:
		var holdingRunes = a.find_children("*", "MagicRune")
		if holdingRunes.size() > 0:
			continue
		if pendingRunes.is_empty():
			a.visible = false
			break
		else:
			a.visible = true
		
		var addRune = false
		for r in pendingRunes:
			var rElemFlag = 1 << r.element
			if holdBits & rElemFlag:
				continue # skip already have
			else:
				holdBits |= rElemFlag
				addRune = true
				_add_rune_to_holder(a, r)
				break
		
		if not addRune:
			_add_rune_to_holder(a, pendingRunes[0])
	
	if pendingRunes.is_empty():
		hmd.remainLabel.text = "Last runes"
	else:
		hmd.remainLabel.text = "%d remain" % pendingRunes.size()

func _add_rune_to_holder(a : Area3D, r : MagicRune):
	r.reparent(a)
	r.owner = a
	r.visible = true

	var box : AABB = r.get_bounds()
	var s = 0.2 / box.get_longest_axis_size()
	r.transform = Transform3D(Basis.from_scale(Vector3(s,s,s)), box.get_center() * -s)
	
	pendingRunes.erase(r)

func last_rune() -> MagicRune:
	if placedRunes.is_empty():
		return null
	return placedRunes[-1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wantToCast = hmd.conRight.get_float("trigger")
	
	if hmd.tipInArea == hmd.newSpellArea and wantToCast:
		new_spell_sequence()
		return
	
	if liftingRune:
		if not wantToCast:
			liftingRune = false
			validPos = false
			currRune.spell_prime()
			refill_book()
	elif currRune:
		if wantToCast:
			lock_in_rune()
		else:
			update_place_rune(delta)
	elif wantToSpawnRune > 0:
		wantToSpawnRune = 0
		spawn_new_rune()
	elif wantToCast:
		pick_book_rune()
	
	for a in holingArea:
		var isHovered = hmd.tipInArea == a
		if isHovered:
			a.scale = Vector3(1.3,1.3,1.3)
			a.quaternion = Quaternion.IDENTITY
		else:
			a.scale = Vector3.ONE
			a.rotate_y(1 * delta)
	
	
	# decay intent buffer
	wantToSpawnRune -= delta
	
	# Last thing
	prevIn = input

func opposite(a : RuneMesh.Element, b: RuneMesh.Element) -> bool:
	match a:
		RuneMesh.Element.Fire:
			return b == RuneMesh.Element.Water
		RuneMesh.Element.Water:
			return b == RuneMesh.Element.Fire
		RuneMesh.Element.Earth:
			return b == RuneMesh.Element.Air
		RuneMesh.Element.Air:
			return b == RuneMesh.Element.Earth
	return false

func pick_book_rune():
	for a in holingArea:
		if hmd.tipInArea != a:
			continue
			
		var runes = a.find_children("*", "MagicRune")
		if runes.is_empty():
			return
		var r : MagicRune = runes[0]
		
		var lr = last_rune()
		if lr and opposite(lr.element, r.element):
			return
				
		currRune = r
		r.reparent(hmd.wandTip)
		r.owner = hmd.wandTip
		r.transform = Transform3D.IDENTITY
		liftingRune = true

func lock_in_rune():
	if not currRune:
		return
	
	if not validPos:
		return
		
	# Start Casting
	currRune.reparent(self)
	currRune.spell_cast()
	spellEndPoint = currRune.get_end_point()
	spellEndDir = currRune.get_end_dir()
	if last_rune():
		last_rune().spellLast = false
	placedRunes.append(currRune)
	currRune = null
	validPos = false
	
	update_spell_stats()

func update_place_rune(_delta : float):
	var tipPos = hmd.wandTip.global_position
	
	validPos = true
	if last_rune():
		if (tipPos - spellEndPoint).length() > SPELL_SNAP:
			validPos = false
			currRune.extendToWorldPoint = tipPos
			return
			
		var cols = currRune.get_collisions()
		for c in cols:
			#DebugDraw3D.draw_sphere_hd(c, 0.008, Color.BLACK)
			validPos = false
		
		currRune.extendToWorldPoint = spellEndPoint
	else:
		validPos = true
		currRune.extendToWorldPoint = currRune.get_start_point()
		
func but_process(isPrim : bool, inputName : String, val : float):
	if isPrim:
		input["pri" + inputName] = val
	else:
		input["sec" + inputName] = val

func but_press_left(inputName : String) -> void:
	but_process(false, inputName, 1.0)
		
func but_press_right(inputName : String) -> void:
	but_process(true, inputName, 1.0)
		
func but_release_left(inputName : String) -> void:
	but_process(false, inputName, 0.0)
	
func but_release_right(inputName : String) -> void:
	but_process(true, inputName, 0.0)


func spawn_new_rune():
	if(currRune):
		return
	currRune = RUNE_PREFAB.instantiate()
	hmd.wandTip.add_child(currRune)
	currRune.reroll()
	currRune.spell_prime()

extends Node3D


@onready var hmd : VrRoot = $XROrigin3D

var input = {}
var prevIn = {}

var currRune : MagicRune
var wantToSpawnRune : float = 0.0
var casting: bool = false
var wantToCast : bool = false

const RUNE_PREFAB = preload("res://magic_rune.tscn")

func _ready() -> void:
	hmd.conLeft.button_pressed.connect(but_press_left)
	hmd.conRight.button_pressed.connect(but_press_right)
	hmd.conLeft.button_released.connect(but_release_left)
	hmd.conRight.button_released.connect(but_release_right)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wantToCast = hmd.conRight.get_float("trigger")
	
	if wantToCast != casting:
		if wantToCast and currRune:
			# Start Casting
			currRune.reparent(self)
			currRune.spell_cast()
			currRune = null
			
		elif not wantToCast:
			# Stop Casting
			pass
	elif casting:
		pass
	elif wantToSpawnRune > 0:
		wantToSpawnRune = 0
		spawn_new_rune()
	
	# decay intent buffer
	wantToSpawnRune -= delta
	
	# Last thing
	prevIn = input

func but_process(isPrim : bool, inputName : String, val : float):
	input["prim" + inputName] = val

func but_press_left(inputName : String) -> void:
	but_process(false, inputName, 1.0)
	
func but_press_right(inputName : String) -> void:
	but_process(true, inputName, 1.0)
	
	if(inputName == "ax_button"):
		wantToSpawnRune = 1.0
	
	
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

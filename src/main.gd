extends Node3D


@onready var hmd : VrRoot = $XROrigin3D

var input = {}
var prevIn = {}

var currRune : MeshInstance3D
var spawnRune : bool = false

func _ready() -> void:
	hmd.conLeft.button_pressed.connect(but_press_left)
	hmd.conRight.button_pressed.connect(but_press_right)
	hmd.conLeft.button_released.connect(but_release_left)
	hmd.conRight.button_released.connect(but_release_right)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if spawnRune:
		spawnRune = false
		spawn_new_rune()
	
	# Last thing
	prevIn = input

func but_process(isPrim : bool, name : String, val : float):
	input["prim" + name] = val

func but_press_left(name : String) -> void:
	but_process(false, name, 1.0)
	
func but_press_right(name : String) -> void:
	but_process(true, name, 1.0)
	
	if(name == "ax_button"):
		spawnRune = true
	
func but_release_left(name : String) -> void:
	but_process(false, name, 0.0)
	
func but_release_right(name : String) -> void:
	but_process(true, name, 0.0)


func spawn_new_rune():
	if(currRune):
		currRune.reparent(self)
	currRune = MeshInstance3D.new()
	currRune.mesh = $SplineMeshMaker.make_new_rune()
	hmd.wandTip.add_child(currRune)

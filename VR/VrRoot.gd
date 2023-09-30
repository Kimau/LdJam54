extends Node3D

class_name VrRoot

@export var enableVr : bool = true

var xri: XRInterface
var vp: Viewport

@onready var conLeft : XRController3D = $TrackHandLeft
@onready var conRight : XRController3D = $TrackHandRight
@onready var wandTip : Node3D = %WandTip

# Called when the node enters the scene tree for the first time.
func _ready():
	vp = get_viewport()
	vp.use_xr = enableVr
	
	if enableVr:
		startVR()
	else:
		stopVR()
			

func _process(_delta):
	if vp.use_xr != enableVr:
		if enableVr:
			startVR()
		else:
			stopVR()
	

func startVR():
	$XRCamera3D.make_current()

	vp.use_xr = true
	
	xri = XRServer.find_interface("OpenXR")
	XRServer.connect("tracker_added", tracker_added)
	XRServer.connect("tracker_removed", tracker_removed)
	XRServer.connect("tracker_updated", tracker_update)
	
	if !xri or !xri.is_initialized():
		vp.use_xr = false
		print_debug("Fuck no VR")
		return
		
	var oxr: OpenXRInterface = xri

	oxr.connect("pose_recentered", pose_recentered)
	oxr.connect("session_begun", session_begun)
	oxr.connect("session_focussed", session_focussed)
	oxr.connect("session_stopping", session_stopping)
	oxr.connect("session_visible", session_visible)

func stopVR():
	vp = get_viewport()
	vp.use_xr = false
	

func tracker_added(interface_name: StringName, idx: int):
	print("Added: ", idx, " : ", interface_name)


func tracker_removed(interface_name: StringName, idx: int):
	print("Removed: ", idx, " : ", interface_name)


func tracker_update(interface_name: StringName, idx: int):
	print("Update: ", idx, " : ", interface_name)


func pose_recentered():
	print("OXR: poseRecentered")


func session_begun():
	print("OXR:sessionBegun ")


func session_focussed():
	print("OXR: sessionFocussed")
	#get_viewport().use_xr = true


func session_stopping():
	print("OXR: sessionStopping")


func session_visible():
	print("OXR: sessionVisible")
	#get_viewport().use_xr = false


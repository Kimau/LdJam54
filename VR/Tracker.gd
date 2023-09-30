extends XRController3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var isValid: bool = get_is_active() && get_has_tracking_data()
	self.visible = isValid

	if !isValid:
		return
	#

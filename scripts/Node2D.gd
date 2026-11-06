extends Node2D

@onready var center: Sprite2D = $center
@onready var right = $right
@onready var left = $left
# Students must create two orbiting icons to both previously defined.
@onready var r_right = $rotator_right
@onready var r_left = $rotator_left

@onready var camera_2d = $Camera2D
@onready var background_image: Sprite2D = $"Background Image"

# The orbiting icons must have these exported attributes
@export var dist_r: float = 80.0
@export var dist_l: float = 120.0
@export var speed_r: float = 5.0
@export var speed_l: float = 2.0

# Orbiting
var angle_l: float = 0.0
var angle_r: float = 0.0

# Detecting collisions
var cooldown: float = 0.0
var detections: int = 0

func viewport_post_to_world_coordinates(event_pos: Vector2) -> Vector2:
	return get_viewport_transform().affine_inverse() * event_pos

func _ready() -> void:
	background_image.texture = load("res://assets/images.jpeg")
	center.texture = load("res://assets/godot.png")
	left.texture = load("res://assets/godot.png")
	right.texture = load("res://assets/godot.png")
	r_right.texture = load("res://assets/godot.png")
	r_left.texture = load("res://assets/godot.png")
	
	right.modulate = Color(0.045, 0.265, 0.969, 1.0)
	left.modulate = Color(0.815, 0.0, 0.0, 1.0)
	center.modulate = Color(1.0, 1.0, 1.0, 1.0)
	r_right.modulate = Color(0.0, 0.808, 0.0, 1.0)
	r_left.modulate = Color(0.812, 0.769, 0.0, 1.0)
	right.translate(Vector2(200, 0))
	left.translate(Vector2(-200, 0))
	background_image.scale = Vector2(2, 2)
	background_image.z_index = -1
	camera_2d.zoom = Vector2(2.5, 2.5)

func _process(delta):
	# Center of the camera must be in the same position as the red icon.
	camera_2d.position = left.position
	# Maintains the background in view
	background_image.position = camera_2d.position

	# The orbiting icons must rotate using transformation matrices.

	# Parent_Position x Rotation_Matrix x OffsetMatrix
	var rotation_mat_l: Transform2D = Transform2D()
	rotation_mat_l.x.x = cos(angle_l)
	rotation_mat_l.y.y = cos(angle_l)
	rotation_mat_l.y.x = -sin(angle_l)
	rotation_mat_l.x.y = sin(angle_l)
	# Rotation matrix
	var rotation_mat_r: Transform2D = Transform2D()
	rotation_mat_r.x.x = cos(angle_r)
	rotation_mat_r.y.y = cos(angle_r)
	rotation_mat_r.y.x = -sin(angle_r)
	rotation_mat_r.x.y = sin(angle_r)
	
	var offset_mat_l: Transform2D = Transform2D()
	offset_mat_l.origin.y = dist_l
	
	var offset_mat_r: Transform2D = Transform2D()
	offset_mat_r.origin.y = dist_r

	r_left.transform = Transform2D(0, left.global_transform.origin) * rotation_mat_l * offset_mat_l
	r_right.transform = Transform2D(0, right.global_transform.origin) * rotation_mat_r * offset_mat_r
	
	angle_r += speed_r * delta
	angle_l -= speed_l * delta
	
	# Detect when both orbiting icons are closer than 32 pixels using the distance_to function their current global_position
	if cooldown > 0:
		cooldown -= delta

	if r_right.global_position.distance_to(r_left.global_position) < 64:
		if cooldown <= 0:
			detections += 1
			print("detection #" + str(detections))
			cooldown = 1.0
	
func _input(input: InputEvent) -> void:
	if input is InputEventMouseButton and input.pressed:
		var cam_pos: Vector2 = viewport_post_to_world_coordinates(input.position)
		# Right mouse button will set the position of the 32x32 blue icon.
		if input.button_index == MOUSE_BUTTON_RIGHT:
			right.transform = Transform2D(0, cam_pos)
		# Left mouse button will set the position of the red icon.
		elif input.button_index == MOUSE_BUTTON_LEFT:
			left.transform = Transform2D(0, cam_pos)

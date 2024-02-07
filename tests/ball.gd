tool
extends Area2D

onready var polygon := $"%polygon"
onready var shape := $"%shape"
onready var line := $"%line"

export var is_white := true setget set_is_white
func set_is_white(val):
	if is_white == val: return
	is_white = val
	dirty_flag = true

export var radius := 50.0 setget set_radius
func set_radius(val):
	if radius == val: return
	radius = val
	dirty_flag = true
	
export var sides := 32 setget set_sides
func set_sides(val):
	if sides == val: return
	sides = val
	dirty_flag = true

var dirty_flag := true

var velocity := Vector2.ZERO

var mouse_begin_pos : Vector2
var mouse_end_pos : Vector2

	
func _process(delta):
	handle_input()
	
	if dirty_flag:
		update_color()
		update_polygon()
		update_shape()
		dirty_flag = false
		
func update_color():
	if is_white:
		polygon.color = Color.white
	else:
		polygon.color = Color.greenyellow
	
func update_polygon():
	var rotangle := PI*2 / sides
	var vertices := PoolVector2Array()
	
	for i in range(sides):
		var angle = (i * rotangle) + ((PI - rotangle) * 0.5)
		var pt = Vector2(cos(angle) * radius, sin(angle) * radius)
		vertices.append(pt)
		
	polygon.polygon = vertices
	
func update_shape():
	var circle_shape := shape.shape as CircleShape2D
	circle_shape.radius = radius

func handle_input():
	if Engine.editor_hint: return
	if !is_white: return
	
	if Input.is_action_just_pressed("click"):
		mouse_begin_pos = get_global_mouse_position()
	elif Input.is_action_just_released("click"):
		mouse_end_pos = get_global_mouse_position()
		velocity += (mouse_begin_pos - mouse_end_pos) * 0.025
	elif Input.is_mouse_button_pressed(1):
		var delta := mouse_begin_pos - get_global_mouse_position()
		line.points[1] = delta
	else:
		line.points[1] = Vector2.ZERO

func _physics_process(_delta):
	global_position += velocity
	velocity *= 0.98

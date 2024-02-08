tool
extends Area2D

onready var polygon := $"%polygon"
onready var border := $"%border"
onready var shape := $"%shape"
onready var line := $"%line"
onready var velocity_line := $"%velocity"
onready var debug_label := $"%debug_label"

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
		update_border()
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
	
func update_border():
	var vertices := PoolVector2Array(polygon.polygon)
	vertices.append(vertices[0])
	border.points = vertices
	
func update_shape():
	var circle_shape := shape.shape as CircleShape2D
	circle_shape.radius = radius

func handle_input():
	if Engine.editor_hint: return
	if is_white:
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
	else:
		var speed_multiplier := 0.25
		if Input.is_action_pressed("ui_up"):
			velocity += Vector2.UP * speed_multiplier
		elif Input.is_action_pressed("ui_down"):
			velocity += Vector2.DOWN * speed_multiplier
			
		if Input.is_action_pressed("ui_left"):
			velocity += Vector2.LEFT * speed_multiplier
		elif Input.is_action_pressed("ui_right"):
			velocity += Vector2.RIGHT * speed_multiplier
		

func _physics_process(_delta):
	if Engine.editor_hint: return
	
	global_position += velocity
	velocity *= 0.98
	velocity_line.points[1] = velocity * 10
	
	var overlapping_areas := get_overlapping_areas()
	if !overlapping_areas.empty():
		polygon.color = Color.orangered
		handle_collisions(overlapping_areas)
	else:
		update_color()

func handle_collisions(collisions):
	for collision in collisions:
		pass
		
		


func _on_ball_area_entered(collision):
	var m1 := 1.0
	var v1 : Vector2 = velocity
	var x1 := global_position
	
	var m2 := 1.0
	var v2 : Vector2 = collision.velocity
	var x2 : Vector2 = collision.global_position
	
	var foo := (2*m2) / (m1+m2)
	var bar := ((v1-v2).dot(x1-x2)/(x1-x2).length_squared())
	var baz := x1 - x2
	
	var new_velocity = v1 - foo * bar * baz
	set_deferred("velocity", new_velocity)

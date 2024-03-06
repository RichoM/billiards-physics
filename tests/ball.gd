tool
extends KinematicBody2D

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
	
	
	#global_position += velocity
	var collision = move_and_collide(velocity)
	if is_white:
		OS.set_window_title(str(collision))
	if collision != null:
		var ball = collision.collider
		var dp1 = global_position - ball.global_position
		var dv1 = velocity - ball.velocity
		var new_velocity1 = velocity - (dv1.dot(dp1) / dp1.length_squared()) * dp1
		
		var dp2 = ball.global_position - global_position
		var dv2 = ball.velocity - velocity
		var new_velocity2 = ball.velocity - (dv2.dot(dp2) / dp2.length_squared()) * dp2
		
		velocity = new_velocity1
		ball.velocity = new_velocity2
	
	velocity *= 0.98
	velocity_line.points[1] = velocity * 10
	
	if global_position.x + radius < -512:
		global_position.x = 512 + radius
	elif global_position.x - radius > 512:
		global_position.x = -512 - radius
	
	if global_position.y + radius < -300:
		global_position.y = 300 + radius
	elif global_position.y - radius > 300:
		global_position.y = -300 - radius
		
	
#	var overlapping_areas := get_overlapping_areas()
#	if !overlapping_areas.empty():
#		polygon.color = Color.orangered
#	else:
#		update_color()

func _on_ball_area_entered(ball):
	# HACK(Richo): We assume both balls have the same mass, thus we can ignore a few calculations
	var dp = global_position - ball.global_position
	var dv = velocity - ball.velocity
	var new_velocity = velocity - (dv.dot(dp) / dp.length_squared()) * dp
	
	# HACK(Richo): Important! We have to give the other balls a chance to calculate using this
	# ball old velocity before we update it with its new value
	set_deferred("velocity", new_velocity) 

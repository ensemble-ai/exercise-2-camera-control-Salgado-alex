class_name LerpSmoothingTargetFocus
extends CameraControllerBase

@export var follow_speed: float = 20.0
@export var catchup_speed: float = 5.0
@export var lead_speed: float = 30.0
@export var catchup_delay_duration: float = 1.0
@export var leash_distance: float = 10.0

var previous_tpos: Vector3
var last_input_time: float = 0.0
var is_catching_up: bool = false


func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	var tpos = target.global_position
	var cpos = global_position

	var target_velocity = (tpos - previous_tpos) / delta
	previous_tpos = tpos

	# Calculate a lead position based on the target's direction of movement
	var lead_direction = target_velocity.normalized()
	var lead_position = tpos + lead_direction * min(lead_speed, leash_distance)

	var camera_speed = follow_speed if target_velocity.length() > 0 else catchup_speed

	var distance_to_target = cpos.distance_to(tpos)
	if distance_to_target > leash_distance:
		if target_velocity.length() > follow_speed * 5:  
			camera_speed += (target.HYPER_SPEED - 1) * follow_speed
		else:
			camera_speed += (distance_to_target - leash_distance) * 0.4

	var target_position = lead_position if !is_catching_up else tpos
	global_position = global_position.lerp(target_position, min(camera_speed * delta, 1.0))

	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var cross_top:float = -5.0
	var cross_bottom:float = 5.0
	var cross_left:float = -5.0
	var cross_right:float = 5.0
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	# Vertical lines 
	immediate_mesh.surface_add_vertex(Vector3(0, 0,cross_top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, cross_bottom))
	
	# Horizontal lines 
	immediate_mesh.surface_add_vertex(Vector3(cross_left, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(cross_right, 0, 0))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.AZURE
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()

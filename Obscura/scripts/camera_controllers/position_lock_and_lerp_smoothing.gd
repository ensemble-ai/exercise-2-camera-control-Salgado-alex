class_name PositionLockAndLerpSmoothing
extends CameraControllerBase

@export var follow_speed: float = 50.0 
@export var catchup_speed: float = 50.0  
@export var leash_distance: float = 10.0  

var previous_tpos: Vector3

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

	var camera_speed = follow_speed if target_velocity.length() > 0 else catchup_speed

	# Hyper-speed multiplier when over leash distance
	var distance_to_target = cpos.distance_to(tpos)
	if distance_to_target > leash_distance:
		if target_velocity.length() > follow_speed:
			camera_speed *= target.HYPER_SPEED
		else:
			camera_speed += (distance_to_target - leash_distance) * 0.4  

	var next_position = cpos.lerp(tpos, camera_speed * delta)

	if next_position.distance_to(tpos) > leash_distance:
		var direction_to_target = (tpos - cpos).normalized()
		next_position = cpos + direction_to_target * (camera_speed * delta)

	global_position = next_position

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

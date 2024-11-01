class_name FourWaySpeedupPushZone
extends CameraControllerBase

@export var push_ratio: float = 1.0
@export var pushbox_top_left: Vector2 = Vector2(-2, 2)
@export var pushbox_bottom_right: Vector2 = Vector2(2, -2)
@export var speedup_zone_top_left: Vector2 = Vector2(-1, 1)
@export var speedup_zone_bottom_right: Vector2 = Vector2(2, -1)

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	target_position(delta)
	
	super(delta)
    
func target_position(delta: float) -> void:
    # Target and camera positions
	var cpos = global_position
	var tpos = target.global_position

	var half_width = target.WIDTH / 2.0
	var half_height = target.HEIGHT / 2.0

	#boundry checks
	#left 
	var diff_between_left_edges = (tpos.x - half_width) - (cpos.x + pushbox_top_left.x)
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	#right 
	var diff_between_right_edges = (tpos.x + half_width) - (cpos.x + pushbox_bottom_right.x)
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	#top 
	var diff_between_top_edges = (tpos.z - half_height) - (cpos.z + pushbox_top_left.y)
	if diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
	#bottom 
	var diff_between_bottom_edges = (tpos.z + half_height) - (cpos.z + pushbox_bottom_right.y)
	if diff_between_bottom_edges > 0:
		global_position.z += diff_between_bottom_edges

	#target moves within the speedup zone
    #right
	if (tpos.x - cpos.x) > speedup_zone_bottom_right.x and (tpos.x - cpos.x) < pushbox_bottom_right.x and target.velocity.x > 0:
		global_position.x += target.BASE_SPEED * push_ratio * delta
    #left
	elif (tpos.x - cpos.x) < speedup_zone_top_left.x and (tpos.x - cpos.x) > pushbox_top_left.x and target.velocity.x < 0:
		global_position.x -= target.BASE_SPEED * push_ratio * delta
	#top
	if (tpos.z - cpos.z) > speedup_zone_top_left.y and (tpos.z - cpos.z) < pushbox_top_left.y and target.velocity.z < 0:
		global_position.z -= target.BASE_SPEED * push_ratio * delta
    #bottom     
	elif (tpos.z - cpos.z) < speedup_zone_bottom_right.y and(tpos.z - cpos.z) > pushbox_top_left.y and target.velocity.z > 0:
		global_position.z += target.BASE_SPEED * push_ratio * delta

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)

	#pushbox
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))

	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))

	#speedup zone
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))

	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))

	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))

	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.AZURE

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()

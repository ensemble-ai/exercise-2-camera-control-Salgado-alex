class_name HorizontalScroll
extends CameraControllerBase

@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3 

func _ready() -> void:
	super()
	position = target.position

func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	global_transform.origin += autoscroll_speed * delta
	adjust_target_position()

	super(delta)

# Target's position within the defined boundaries
func adjust_target_position() -> void:
	
	var tpos = target.global_position
	var cpos = global_position
	
	# Half-width and half-height of the target 
	var half_width = target.WIDTH / 2.0
	var half_height = target.HEIGHT / 2.0

	# Boundary 
	if (tpos.x - half_width) < (cpos.x + top_left.x):
		target.global_position.x = cpos.x + top_left.x + half_width
	elif (tpos.x + half_width) > (cpos.x + bottom_right.x):
		target.global_position.x = cpos.x + bottom_right.x - half_width

	if (tpos.z + half_height) > (cpos.z + top_left.y):
		target.global_position.z = cpos.z + top_left.y - half_height
	elif (tpos.z - half_height) < (cpos.z + bottom_right.y):
		target.global_position.z = cpos.z + bottom_right.y + half_height

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Boundary lines 
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	# bottom right to top right
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))    
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))
	# bottom right to bottom left
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y)) 
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))
	# bottom left to top left
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))  
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))
	# top left to top right
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))     
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.AZURE

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()

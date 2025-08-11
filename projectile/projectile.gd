class_name Projectile
extends GPUParticles2D

var type:Constants.UnitType:
	set(value):
		type = value
		#(process_material as ParticleProcessMaterial).color = 


func _ready() -> void:
	visible = false
func _process(delta: float) -> void:
	%Core.scale = Vector2(
		10 + sin(Engine.get_frames_drawn() * 0.1),
		10 + cos(Engine.get_frames_drawn() * 0.15),
	)
	%Core.rotation = TAU * (
		1.2 * sin(Engine.get_frames_drawn() * 0.1  ) + 
		2.5 * cos(Engine.get_frames_drawn() * 0.15 ) + 
		0.9 * sin(Engine.get_frames_drawn() * 0.075)
	) * 0.005

extends CanvasLayer

var fireball_trail = preload("res://assets/materials/FireballTrail.tres")

var materials = [fireball_trail]

# Called when the node enters the scene tree for the first time.
func _ready():
	for material in materials:
		var particles_inst = GPUParticles2D.new()
		particles_inst.set_process_material(material)
		particles_inst.set_one_shot(true)
		particles_inst.set_emitting(true)
		particles_inst.set_modulate(Color(1,1,1,0))
		self.add_child(particles_inst)


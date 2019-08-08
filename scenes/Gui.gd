extends Control

onready var seeed = $Yaml/Stack/Seed
onready var textbox = $Yaml/Stack/Config
onready var error_label = $Yaml/Stack/Box/Error
onready var load_button = $Yaml/Stack/Box/Button
onready var zoom_slider = $Zoom/Stack/Slider
onready var texture_stack = $Noise/Stack
onready var texture_box = $Box
onready var tilegen = preload("res://assets/scripts/tilegen.gd").new()

signal loaded
signal zoom

# TODO add zoom in and out buttons

# Called when the node enters the scene tree for the first time.
func _ready():
    load_button.connect("pressed", self, "_pressed")
    zoom_slider.connect("value_changed", self, "_value_changed")


func _pressed():
    load_config()


func _value_changed(value):
    emit_signal("zoom", value)


func load_config():
    var sed = seeed.text
    if sed != "":
        if int(sed) != 0:
            sed = int(sed)
        else:
            sed = sed.hash()
    else:
        sed = null

    if tilegen.parse_config(textbox.text, sed):
        error_label.visible = false
        set_textures()
        emit_signal("loaded")
    else:
        error_label.visible = true


func set_textures():
    for child in texture_stack.get_children():
        child.queue_free()
    for generator in tilegen.generators:
        var gen = tilegen.generators[generator]
        var new_box = texture_box.duplicate()
        var tex = NoiseTexture.new()
        tex.width = 128
        tex.height = 128
        tex.noise = gen
        new_box.get_node("Texture").texture = tex
        new_box.get_node("Label").text = generator
        texture_stack.add_child(new_box)
        new_box.visible = true

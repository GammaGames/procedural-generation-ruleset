extends Node

export(int) var WIDTH = 168
export(int) var HEIGHT = 168
var variance

onready var tilemap = $TileMap
onready var gui = $Gui


func _ready():
    gui.connect("loaded", self, "_loaded")
    gui.connect("zoom", self, "_zoom")
    variance = OpenSimplexNoise.new()
    variance.seed = randi()
    variance.octaves = 3
    variance.period = 2
    variance.persistence = 1
    variance.lacunarity = 1
    gui.load_config()
    gui.connect("resized", self, "_resized")


func _resized():
    tilemap.position = get_viewport().size / 2


func _input(event):
    # if event is InputEventMouseMotion:
    #     var pos = get_viewport().get_mouse_position()
    #     # camera.transform.x =

    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()
    elif Input.is_action_just_pressed("ui_restart"):
        gui.load_config()


func _loaded():
    generate(gui.tilegen)


func _zoom(value):
    tilemap.scale = Vector2(value, value)


func generate(tilegen):
    variance.seed = randi()
    for x in WIDTH:
        var xx = x - floor(WIDTH / 2)
        for y in HEIGHT:
            var tile = tilegen.get_tile(xx, y)
            var id = tilemap.tile_set.find_tile_by_name(tile)
            var variance_val = variance.get_noise_2d(float(xx), float(y))
            var subtile = self._get_subtile(id, variance_val)
            tilemap.set_cell(xx, y - HEIGHT / 2, id, false, false, false, subtile)
    tilemap.update_bitmask_region()


func _get_subtile(id, val, plain=null):
    val = inverse_lerp(-1.0, 1.0, val)
    var tiles = tilemap.tile_set
    var rect = tilemap.tile_set.tile_get_region(id)
    var y = int(rect.size.y / tiles.autotile_get_size(id).y)
    if plain != null:
        return Vector2(0, int(round(y * val)) % plain)
    else:
    # x is always 0
        return Vector2(0, round(y * val))

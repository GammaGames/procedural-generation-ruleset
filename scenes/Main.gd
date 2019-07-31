extends Node2D

export(int) var WIDTH = 168
export(int) var HEIGHT = 168
var variance

onready var tilemap = $TileMap
onready var tilegen = preload("res://assets/scripts/tilegen.gd").new()


func _ready():
    tilegen.load_config("res://assets/simple.yaml")
    randomize()
    variance = OpenSimplexNoise.new()
    variance.seed = randi()
    variance.octaves = 3
    variance.period = 2
    variance.persistence = 1
    variance.lacunarity = 1
    _generate()


func _input(event):
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()
    elif Input.is_action_just_pressed("ui_restart"):
        get_tree().reload_current_scene()


func _generate():
    for x in WIDTH:
        for y in HEIGHT:
            var id = tilemap.tile_set.find_tile_by_name(tilegen.get_tile(x, y))
            var variance_val = variance.get_noise_2d(float(x), float(y))
            var subtile = self._get_subtile(id, variance_val)
            tilemap.set_cell(x, y - HEIGHT / 2, id, false, false, false, subtile)
    tilemap.update_bitmask_region()


func _get_subtile(id, val, plain=false):
    # if id == 2:
    #     return Vector2(0, 0)
    val = inverse_lerp(-1.0, 1.0, val)
    if plain:
        return Vector2(0, 0)
    var tiles = tilemap.tile_set
    var rect = tilemap.tile_set.tile_get_region(id)
    var y = int(rect.size.y / tiles.autotile_get_size(id).y)
    # x is always 0
    return Vector2(0, round(y * val))

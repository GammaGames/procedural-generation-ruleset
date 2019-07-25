extends Node2D

export(int) var WIDTH = 168
export(int) var HEIGHT = 168

var height
var moisture
var tech
var variance
var curse

onready var tilemap = $TileMap
onready var tilegen = preload("res://assets/scripts/tilegen.gd").new()


func _ready():
    randomize()
    height = OpenSimplexNoise.new()
    height.seed = randi()
    height.octaves = 1
    height.period = 20
    height.persistence = 0.75
    height.lacunarity = 1

    moisture = OpenSimplexNoise.new()
    moisture.seed = randi()
    moisture.octaves = 2
    moisture.period = 24
    moisture.persistence = 0.2
    moisture.lacunarity = 4

    tech = OpenSimplexNoise.new()
    tech.seed = randi()
    tech.octaves = 4
    tech.period = 6
    tech.persistence = 0.6
    tech.lacunarity = 0.7

    variance = OpenSimplexNoise.new()
    variance.seed = randi()
    variance.octaves = 3
    variance.period = 2
    variance.persistence = 1
    variance.lacunarity = 1

    curse = OpenSimplexNoise.new()
    curse.seed = randi()
    curse.octaves = 3
    curse.period = 64
    curse.persistence = 0.5
    curse.lacunarity = 2

    _generate()


func _input(event):
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()
    elif Input.is_action_just_pressed("ui_restart"):
        get_tree().reload_current_scene()


func _generate():
    for x in WIDTH:
        # if randf() < 0.5:
        #     tilemap.tile_set.tile_set_modulate(tilemap.tile_set.find_tile_by_name("ground_2"), Color.black)
        # else:
        #     tilemap.tile_set.tile_set_modulate(tilemap.tile_set.find_tile_by_name("ground_2"), Color.red)
        for y in HEIGHT:
            var height_val = height.get_noise_2d(float(x), float(y))
            var moisture_val = moisture.get_noise_2d(float(x), float(y))
            var tech_val = tech.get_noise_2d(float(x), float(y))
            var variance_val = variance.get_noise_2d(float(x), float(y))
            var curse_val = curse.get_noise_2d(float(x), float(y))
            var id =  self._get_tile_index(height_val, moisture_val, tech_val, curse_val)
            var subtile = self._get_subtile_position(id, variance_val)

            tilemap.set_cell(x, y - HEIGHT / 2, id, false, false, false, subtile)
    tilemap.update_bitmask_region()


func _get_tile_index(height, moisture, tech, curse):
    var tiles = tilemap.tile_set
    height = inverse_lerp(-1.0, 1.0, height)
    moisture = inverse_lerp(-1.0, 1.0, moisture)
    tech = inverse_lerp(-1.0, 1.0, tech)
    curse = inverse_lerp(-1.0, 1.0, curse)

    # if curse > 0.8:
    #     return tiles.find_tile_by_name("4_extended")

    var name = "water"

    if height < 0.35:
        name = "water"
    elif height < 0.45:
        if moisture < 0.2:
            if tech < 0.3:
                name = "sand"
            else:
                name = "dirt"
        elif moisture < 0.55:
            if tech < 0.5:
                name = "dirt"
            else:
                name = "buildings"
        if moisture < 0.65:
            if tech < 0.6:
                name = "grass"
            else:
                name = "buildings"
        elif moisture < 0.9:
            if tech < 0.7:
                name = "plants"
            else:
                name = "buildings"
        else:
            name = "water"
    elif height < 0.6:
        if moisture < 0.10:
            name = "sand"
        elif moisture < 0.45:
            if tech < 0.8:
                name = "dirt"
            else:
                name = "buildings"
        elif moisture < 0.65:
            if tech < 0.7:
                name = "grass"
            else:
                name = "buildings"
        else:
            name = "plants"
    elif height < 0.85:
        if moisture < 0.35:
            name = "grass"
        if moisture < 0.65:
            if tech < 0.7:
                name = "plants"
            else:
                name = "buildings"
        else:
            name = "rock"
    else:
        if moisture < 0.6:
            name = "rock"
        else:
            name = "snow"

    return tiles.find_tile_by_name(name)


func _get_subtile_position(id, val, plain=false):
    val = inverse_lerp(-1.0, 1.0, val)
    if plain:
        return Vector2(0, 0)
    var tiles = tilemap.tile_set
    var rect = tilemap.tile_set.tile_get_region(id)
    var x = int(rect.size.x / tiles.autotile_get_size(id).x)
    var y = int(rect.size.y / tiles.autotile_get_size(id).y)
    # x is always 0
    return Vector2(0, floor(round(y * val)))

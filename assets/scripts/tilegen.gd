extends Object

func _init():
    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/tilemap.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)
    for val in value:
        for key in val.keys():
            pass


func _iterate(x_axis, y_axis, x, y, target):
    # TODO if target is string, process step and get tile
    # If target is array, iterate on each value
    pass


func _process_step(step):
    # TODO process step and 2d array for axis
    pass


func _get_tile(axis):
    # TODO get y axis
    # Get x axis
    # Return x value
    pass

func _get_axis(value, array):
    # TODO if tilemap, return array index key name
    # If array, return array index by key value
    pass

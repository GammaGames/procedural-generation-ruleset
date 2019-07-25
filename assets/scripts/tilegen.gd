extends Object

func _init():

    _pass("foo")

    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/tilemap.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)
    for val in value:
        for key in val.keys():
            pass


func _iterate(x_axis, y_axis, x, y, obj):
    # TODO steps if present
    # TODO iterate if pass present
    pass


func _steps(x_axis, y_axis, x, y, steps):
    # TODO loop through steps
    pass

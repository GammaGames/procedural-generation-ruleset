extends Object

var generators = {}
var alises = {}
var parsed_steps = null


func _init():
    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/simple.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)

    var gens = value["generators"]
    for gen in gens:
        generators[gen] = OpenSimplexNoise.new()
        for key in gens[gen]:
            generators[gen][key] = gens[gen][key]
        generators[gen].seed = randi()

    parsed_steps = _parse_steps(value["steps"])
    for map in parsed_steps:
        print(JSON.print(map, "    "))


func _parse_steps(steps):
    # Pass in array and parse each step
    var result = []
    var total = 0.0

    for step in steps:
        if typeof(step) == TYPE_DICTIONARY:
            result.append(_parse_object(step))
        else:
            var parts = step.split("@")
            var parsed_step = _parse_step(parts[1])

            if int(parts[0]) == 0:
                for key in parts[0].split(","):
                    result.append({
                        "value": key,
                        "steps": parsed_step.steps
                    })
            else:
                parsed_step.value = float(parts[0])
                total += parsed_step.value
                result.append(parsed_step)

    var current = 0.0
    for step in result:
        if step.has("value") and int(step.value) != 0:
            var val = step.value
            current += val
            step.value = current / total

    return result


func _parse_object(step):
    var axis = step.keys()[0].split("*")

    return {
        "x_axis": axis[1],
        "y_axis": axis[0],
        "steps": _parse_steps(step.values()[0])
    }


func _parse_step(step):
    var options = step.split(",")
    var result = []
    # Calculate total value
    var total = 0.0
    var current = 0.0

    for option in options:
        var parts = option.split(":")
        total += float(parts[0])

    for option in options:
        var parts = option.split(":")
        current += float(parts[0])
        # Store pre-result to only split once
        var row = {
            "value": current / total,
            "tile": parts[1]
        }
        result.append(row)

    return {
        "steps": result
    }


func get_tile(x, y):
    var tile_stack = []
    for map in parsed_steps:
        var x_axis = map.x_axis
        var y_axis = map.y_axis
        var yy = null if y_axis == "tile" else inverse_lerp(-1.0, 1.0, generators[y_axis].get_noise_2d(x, y))
        var xx = null if x_axis == "tile" else inverse_lerp(-1.0, 1.0, generators[x_axis].get_noise_2d(x, y))
        var tile = _process_steps(x_axis, xx, y_axis, yy, tile_stack, map.steps)
        if tile != null:
            if tile.begins_with("="):
                return tile.lstrip("=")
            elif tile != "-":
                tile_stack.append(tile)

    return tile_stack.back()


func _process_steps(x_axis, x, y_axis, y, tile_stack, steps):
    var yy = _get_axis(y_axis, y, tile_stack, steps)
    if yy:
    # TODO if yy has x_axis and y_axis, then call _process_steps again
    # Else just get xx value
        var xx = _get_axis(x_axis, x, tile_stack, yy.steps)
        return xx.tile
    else:
        return null


func _get_axis(key, value, tile_stack, steps):
    if key == "tile":
        for step in steps:
            if tile_stack.back() == step.value:
                return step
    else:
        for step in steps:
            if value <= step.value:
                return step

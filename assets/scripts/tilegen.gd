extends Object

var generators = {}
var aliases = {}
var parsed_steps = null
var parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()


func load_config(path, seeed=null):
    var file = File.new()
    file.open(path, File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = parser.parse(content)

    randomize()
    if seeed == null:
        seeed = randi()
    var gens = value["generators"]
    for gen in gens:
        generators[gen] = OpenSimplexNoise.new()
        generators[gen].seed = seeed
        for key in gens[gen]:
            generators[gen][key] = gens[gen][key]
    aliases = value["aliases"]
    parsed_steps = parse_config(value["steps"])


func parse_config(config):
    return _parse_steps(config).next_pass


func print_config():
    print(JSON.print(parsed_steps, "  "))


func _parse_steps(steps):
    # Pass in array and parse each step
    var result = []
    var next = []
    var total = 0.0

    for step in steps:
        if typeof(step) == TYPE_DICTIONARY:
            if "@" in step.keys()[0]:
                var parts = step.keys()[0].split("@")
                var stp = {
                    parts[1]: step.values()[0]
                }
                print(stp)
                var parsed_step = _parse_object(stp)

                if int(parts[0]) == 0:
                    parsed_step.value = parts[0]
                else:
                    parsed_step.value = float(parts[0])
                    total += parsed_step.value
                result.append(parsed_step)

            else:
                next.append(_parse_object(step))
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

    var return_val = {}
    if len(result):
        return_val.steps = result
    if len(next):
        return_val.next_pass = next

    return return_val


func _parse_object(step):
    var axis = step.keys()[0].split("*")

    var parsed_steps = _parse_steps(step.values()[0])
    var result = {
        "axis": {
            "x": axis[1],
            "y": axis[0]
        }
    }
    if parsed_steps.has("steps"):
        result.steps = parsed_steps.steps
    if parsed_steps.has("next_pass"):
        result.next_pass = parsed_steps.next_pass

    return result


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
    var tile = _process_objects(x, y, [], parsed_steps)
    if tile != null and tile.begins_with("="):
        tile = tile.lstrip("=")
    return aliases[tile] if aliases.has(tile) else tile


func _process_objects(x, y, tile_stack, objects):
    for object in objects:
        var tile = _process_object(x, y, tile_stack, object)
        if tile != null:
            if tile.begins_with("="):
                return tile
            elif tile != "-":
                tile_stack.append(tile)

    return tile_stack.back()


func _process_object(x, y, tile_stack, object):
    var x_axis = object.axis.x
    var y_axis = object.axis.y
    var yy = inverse_lerp(-1.0, 1.0, generators[y_axis].get_noise_2d(x, y)) if y_axis != "tile" else y
    var xx = inverse_lerp(-1.0, 1.0, generators[x_axis].get_noise_2d(x, y)) if x_axis != "tile" else x
    var tile = _process_steps(x_axis, xx, y_axis, yy, tile_stack, object.steps)
    if tile != null:
        if tile.begins_with("="):
            return tile
        elif tile != "-":
            tile_stack.append(tile)

    if object.has("next_pass"):
        tile = _process_objects(x, y, tile_stack, object.next_pass)
        if tile != null:
            if tile.begins_with("="):
                return tile
            elif tile != "-":
                tile_stack.append(tile)

    return tile_stack.back()


func _process_steps(x_axis, x, y_axis, y, tile_stack, object):
    var yy = _get_axis(y_axis, y, tile_stack, object)
    if yy:
    # TODO if yy has x_axis and y_axis, then call _process_steps again
    # Else just get xx value
        if yy.has("axis"):
            # TODO doesn't work? Won't correctly return tile >:c
            return _process_object(x, y, tile_stack, yy)
        else:
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

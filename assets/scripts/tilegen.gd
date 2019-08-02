extends Object

var generators = {}
var aliases = {}
var parsed_steps = null
var parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()


# Load config file with file path. Seed is optional.
func load_config(path, seeed=null):
    var file = File.new()
    file.open(path, File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = parser.parse(content)
    # If no seed passed in, randomize it
    if seeed == null:
        randomize()
        seeed = randi()
    # Create the generators
    var gens = value["generators"]
    for gen in gens:
        generators[gen] = OpenSimplexNoise.new()
        generators[gen].seed = seeed
        for key in gens[gen]:
            generators[gen][key] = gens[gen][key]
    aliases = value["aliases"]
    # Store the parsed steps
    parsed_steps = parse_config(value["steps"])


# Parse config object
func parse_config(config):
    return _parse_steps(config).next_pass


# Print parsed config
func print_config():
    print(JSON.print(parsed_steps, "  "))


# Get a tile at x, y with the current parsed steps
func get_tile(x, y):
    var tile = _process_objects(x, y, [], parsed_steps)
    if tile != null and tile.begins_with("="):
        tile = tile.lstrip("=")
    return aliases[tile] if aliases.has(tile) else tile


# Pass in array and parse each step
func _parse_steps(steps):
    var result = []
    var next = []
    var total = 0.0

    for step in steps:
        # If the step is a dictionary
        if typeof(step) == TYPE_DICTIONARY:
            # If there is an @ it is a nested pass
            if "@" in step.keys()[0]:
                # Get the parts and parse the step
                var parts = step.keys()[0].split("@")
                var stp = {
                    parts[1]: step.values()[0]
                }
                var parsed_step = _parse_object(stp)

                # If the key is a string, set the value
                if int(parts[0]) == 0:
                    parsed_step.value = parts[0]
                # Else add to the total and append the step
                else:
                    parsed_step.value = float(parts[0])
                    total += parsed_step.value
                result.append(parsed_step)
            # If just object, add to the next pass
            else:
                next.append(_parse_object(step))
        # If it is an array
        else:
            # Parse the step
            var parts = step.split("@")
            var parsed_step = _parse_step(parts[1])

            # If the key is a string, set the value
            if int(parts[0]) == 0:
                for key in parts[0].split(","):
                    result.append({
                        "value": key,
                        "steps": parsed_step.steps
                    })
            # Else add to the total and append step
            else:
                parsed_step.value = float(parts[0])
                total += parsed_step.value
                result.append(parsed_step)

    var current = 0.0
    # Get the probability for each step
    for step in result:
        if step.has("value") and int(step.value) != 0:
            var val = step.value
            current += val
            step.value = current / total

    # Return the steps with any steps or pass values
    var return_val = {}
    if len(result):
        return_val.steps = result
    if len(next):
        return_val.next_pass = next

    return return_val


# Split the axis and parse the step
func _parse_object(step):
    var axis = step.keys()[0].split("*")
    var parsed_steps = _parse_steps(step.values()[0])
    var result = {
        "axis": {
            "x": axis[1],
            "y": axis[0]
        }
    }
    # If our parsed steps have steps or next pass, add them
    if parsed_steps.has("steps"):
        result.steps = parsed_steps.steps
    if parsed_steps.has("next_pass"):
        result.next_pass = parsed_steps.next_pass

    return result


# Parse a single step
func _parse_step(step):
    var options = step.split(",")
    var result = []
    # Calculate total value
    var total = 0.0
    var current = 0.0

    # Add up total value of step
    for option in options:
        var parts = option.split(":")
        total += float(parts[0])

    # For each option get step probability
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


# Process all objects and return tile
func _process_objects(x, y, tile_stack, objects):
    for object in objects:
        # Process the object and check if tile is good
        var tile = _process_object(x, y, tile_stack, object)
        if tile != null:
            if tile.begins_with("="):
                return tile
            elif tile != "-":
                tile_stack.append(tile)

    # Return the last tile in stack
    return tile_stack.back()


# Process a single object and return tile
func _process_object(x, y, tile_stack, object):
    # Get the axis names
    var x_axis = object.axis.x
    var y_axis = object.axis.y
    # Get the axis values
    var yy = inverse_lerp(-1.0, 1.0, generators[y_axis].get_noise_2d(x, y)) if y_axis != "tile" else y
    var xx = inverse_lerp(-1.0, 1.0, generators[x_axis].get_noise_2d(x, y)) if x_axis != "tile" else x
    # Get the tile with the object's steps
    var tile = _process_steps(x_axis, xx, y_axis, yy, tile_stack, object.steps)
    # Check and return or process the tile
    if tile != null:
        if tile.begins_with("="):
            return tile
        elif tile != "-":
            tile_stack.append(tile)

    # If there is a next pass, get the tile for the following steps
    if object.has("next_pass"):
        tile = _process_objects(x, y, tile_stack, object.next_pass)
        # Check and return or process the tile
        if tile != null:
            if tile.begins_with("="):
                return tile
            elif tile != "-":
                tile_stack.append(tile)

    # Return the last tile in the stack
    return tile_stack.back()


# Process steps and return a tile
func _process_steps(x_axis, x, y_axis, y, tile_stack, object):
    var yy = _get_axis(y_axis, y, tile_stack, object)
    # If we got a y value, continue
    if yy:
        # If the y value has an axis, process and return
        if yy.has("axis"):
            return _process_object(x, y, tile_stack, yy)
        # Else just return the tile
        else:
            var xx = _get_axis(x_axis, x, tile_stack, yy.steps)
            return xx.tile
    else:
        return null


# Get an axis from given steps
func _get_axis(key, value, tile_stack, steps):
    # If the key is a tile, then find the matching step
    if key == "tile":
        for step in steps:
            if tile_stack.back() == step.value:
                return step
    # Else, use the probability to get the step
    else:
        for step in steps:
            if value <= step.value:
                return step

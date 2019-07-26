extends Object


func _init():
    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/simple.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)
    val tile = _process_steps(0, 1, randf())


func _iterate(x_axis, y_axis, x, y, target):
    for instruction in target.keys():
        if "*" in instruction:
            pass
        else:
            pass
    # TODO if target is string, process step and get tile
    # If target is array, iterate on each value
    pass


func _process_steps(x, y, key, steps):
    for step in steps:
        if typeof(steps) == TYPE_ARRAY:
            var parsed = _parse_steps(steps)
            return _get_tile(axis[1], x, axis[0], y, steps)

        else:
            var axis = key.split("*")
    # TODO if step starts with "=", strip and return without processing more
    # TODO process step and 2d array for axis


func _parse_steps(steps):
    var map = []
    for step in steps:
        map.append(_parse_step(step))
    return map

func _parse_step(step):
    var row = step.split("@")
    var keys = row[0].split(",")
    var options = row[1].split(",")
    var result = null
    var is_dict = int(options[0].split(":")[0]) == 0

    if is_dict:
        result = {}
        for option in options:
            var parts = option.split(":")
            var key = parts[0] if is_dict else int(parts[0])
            result.append({
                value: key,
                tile: parts[1]
            })
    else:
        # Calculate total value
        var total = 0.0
        var rows = [];
        for option in options:
            var parts = option.split(":")
            # Store pre-result to only split once
            var row = {value: float(parts[0], tile:parts[1])}
            total += row.f
            rows.append(row)
        # For each row, calculate its probability
        var current = 0.0
        for row in rows:
            current += row.key
            row.value = current / total
            result.append(row)

    return result


func _parse_axis(axis):
    pass


func _get_tile(x_axis, x, y_axis, y, map):
    var y_value = _get_axis(y_axis, y, steps)
    return _get_axis(x_axis, y, y_value)
    # TODO get y axis
    # Get x axis
    # Return x value

func _get_axis(key, value, steps):
    if key == "tile":
        return steps[value]
    else:
        for key in steps.keys():
            if value < float(key):
                return steps[key]


    if typeof(steps) == TYPE_DICTIONARY:
        pass
    else:
        for row in map:
            if key < float(row.probability):
                return map[value].value

    # TODO if tilemap, return array index key name
    # If array, return array index by key value

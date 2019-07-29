extends Object


func _init():
    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/simple.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)
    var parsed = _parse_steps(value["steps"])
    # for p in parsed:
    #     print(p)

    # var tile = _process_steps(0, 1, randf())


func _iterate(x_axis, y_axis, x, y, target):
    for instruction in target.keys():
        if "*" in instruction:
            pass
        else:
            pass
    # TODO if target is string, process step and get tile
    # If target is array, iterate on each value
    pass


func _process_steps(key, steps):
    for step in steps:
        pass
    # TODO if step starts with "=", strip and return without processing more
    # TODO process step and 2d array for axis


func _parse_steps(steps):
    var map = []
    var is_dict = typeof(steps[0]) == TYPE_DICTIONARY
    var total = 0.0

    for step in steps:
        # print(step)
        # If step is object, get axis and parse steps
        if is_dict:
            # TODO process object
            # print("AXIS")
            var axis = step.keys()[0].split("*")
            # print(axis)
            var parsed = _parse_steps(step.values()[0])
            map.append({
                "x_axis": axis[1],
                "y_axis": axis[0],
                "steps": parsed
            })
        # If step is array, parse step
        else:
            # TODO process string
            # print("STEP")
            var y_axis = step.split("@")
            var is_map = int(y_axis[0]) == 0
            print(y_axis[0])
            print(is_map)
            if is_map:
                var keys = y_axis[0].split(",")
                print(keys)
                # TODO map keys to values
                # for key in keys:
                #     print(key)
                #     var row = {
                #         "value": key,
                #         "value": _parse_step(y_axis[1])
                #     }
                #     map.append(row)
            else:
                var row = {
                    "value": float(y_axis[0]),
                    "tile": y_axis[1]
                }
                total += row.value
                print(row)
                map.append(row)
                # TODO calculate probability

    if not is_dict:

        pass



            # var parsed = _parse_step(step)
            # print(parsed)
            # map.append(parsed)

    return map


func _parse_step(step):
    var options = step.split(",")
    var result = null
    var is_dict = int(options[0].split(":")[0]) == 0
    # print(is_dict)

    if is_dict:
        result = {}
        for option in options:
            var parts = option.split(":")
            var key = parts[0] if is_dict else int(parts[0])
            result.append({
                "value": key,
                "tile": parts[1]
            })
    else:
        result = []
        # Calculate total value
        var total = 0.0
        var rows = [];
        for option in options:
            var parts = option.split(":")
            # Store pre-result to only split once
            var row = {
                "value": float(parts[0]),
                "tile": parts[1]
            }
            total += row.value
            rows.append(row)
        # For each row, calculate its probability
        var current = 0.0
        for row in rows:
            current += row.value
            row.value = current / total
            result.append(row)

    return result


func _parse_axis(axis):
    pass


func _get_tile(x_axis, x, y_axis, y, map):
    var y_value = _get_axis(y_axis, y, map)
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
        for row in steps:
            if key < float(row.value):
                return steps[value].value

    # TODO if tilemap, return array index key name
    # If array, return array index by key value

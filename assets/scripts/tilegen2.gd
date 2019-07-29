extends Object


func _init():
    var yaml = load("res://addons/godot-yaml/gdyaml.gdns").new()

    var file = File.new()
    file.open("res://assets/simple.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    var value = yaml.parse(content)
    var parsed = _parse_steps(value["steps"])
    for p in parsed:
        for s in p["steps"]:
            print(s)
        # print(p)

    # var tile = _process_steps(0, 1, randf())


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
    result.invert()
    for step in result:
        if step.has("value") and int(step.value) != 0:
            current += step.value
            step.value = current / total

    result.invert()
    return result


func _parse_step(step):
    var options = step.split(",")
    var result = []
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

    return {
        "steps": result
    }


func _parse_object(step):
    var axis = step.keys()[0].split("*")

    return {
        "x_axis": axis[1],
        "y_axis": axis[0],
        "steps": _parse_steps(step.values()[0])
    }

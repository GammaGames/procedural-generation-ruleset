extends TextEdit

func _ready():
    var file = File.new()
    file.open("res://assets/tilemap.yaml", File.READ)
    var content = file.get_as_text().strip_edges()
    file.close()

    text = content

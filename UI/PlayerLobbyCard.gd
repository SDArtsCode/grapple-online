extends PanelContainer

var id = null

func set_name(_name):
	$Name.text = _name
	
func set_ready(is_ready : bool):
	if is_ready:
		$Ready.text = "READY"
		modulate = "#39EE56"
	else:
		$Ready.text = "UNREADY"
		$Ready.modulate = "#EE3939"

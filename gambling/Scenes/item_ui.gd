extends Panel

func set_data(item: ItemRes, i):
	$Label.text = str(i+1)
	$TextureRect.texture = item.icon

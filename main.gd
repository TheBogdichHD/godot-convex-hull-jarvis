extends Control

@export_category("Point")
@export var point_radius = 4
@export var point_color = Color.RED
@export_category("Line")
@export var line_width = 2
@export var line_color = Color.BLUE

var points = []
var selected_point = -1


func _draw():
	if points.size() < 2:
		for point in points:
			draw_circle(point, point_radius, point_color)
		return
	
	var convex_hull = jarvis_march()
	
	for i in range(convex_hull.size()-1):
		draw_line(points[convex_hull[i]], points[convex_hull[i+1]], line_color, line_width)
	
	draw_line(points[convex_hull[-1]], points[convex_hull[0]], line_color, line_width)
	
	for point in points:
		draw_circle(point, point_radius, point_color)


func calculate_orientation(p, q, r):
	return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x)


func jarvis_march():
	var num_points = points.size()
	
	var point_indices = []
	for i in range(num_points):
		point_indices.append(i)
	
	for i in range(1, num_points):
		if points[point_indices[i]].x < points[point_indices[0]].x:
			var temp = point_indices[i]
			point_indices[i] = point_indices[0]
			point_indices[0] = temp
	
	var convex_hull = [point_indices[0]]
	
	point_indices.remove_at(0)
	point_indices.append(convex_hull[0])
	
	while true:
		var rightmost = 0
		
		for i in range(1, point_indices.size()):
			if calculate_orientation(
					points[convex_hull[-1]], 
					points[point_indices[rightmost]], 
					points[point_indices[i]]) < 0:
				rightmost = i
		
		if point_indices[rightmost] == convex_hull[0]:
			break
		else:
			convex_hull.append(point_indices[rightmost])
			point_indices.remove_at(rightmost)
	
	return convex_hull


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = event.global_position
			points.append(mouse_pos)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var mouse_pos = event.global_position
			for i in range(points.size()):
				if mouse_pos.distance_to(points[i]) <= point_radius+5:
					points.remove_at(i)
					queue_redraw()
					return
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			var mouse_pos = event.global_position
			for i in range(points.size()):
				if mouse_pos.distance_to(points[i]) <= point_radius+5:
					selected_point = i
					queue_redraw()
					return
		elif event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			selected_point = -1
	elif event is InputEventMouseMotion and selected_point >= 0:
		var mouse_pos = event.global_position
		points[selected_point] = mouse_pos
		queue_redraw()

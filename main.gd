extends Control


@export_category("Point")
@export var point_radius = 4
@export var point_color = Color.RED
@export_category("Line")
@export var line_width = 2
@export var line_color = Color.BLUE


var points = []


func _draw():
	for point in points:
		draw_circle(point, point_radius, point_color)
	
	if points.size() < 3:
		return
	
	var H = jarvismarch(points)
	
	for i in range(H.size()-1):
		draw_line(points[H[i]], points[H[i+1]], line_color, line_width)
	
	draw_line(points[H[-1]], points[H[0]], line_color, line_width)
	
	for point in points:
		draw_circle(point, point_radius, point_color)


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_pos = event.global_position
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			points.append(mouse_pos)
			queue_redraw()


func rotate(P, Q, R):
	return (Q[0] - P[0]) * (R[1] - P[1]) - (Q[1] - P[1]) * (R[0] - P[0])


func jarvismarch(A):
	var n = A.size()
	var P = []
	for i in range(n):
		P.append(i)
	
	# start point
	for i in range(1, n):
		if A[P[i]][0] < A[P[0]][0]:
			var temp = P[i]
			P[i] = P[0]
			P[0] = temp
	
	var H = [P[0]]
	P.remove_at(0)
	P.append(H[0])

	while true:
		var right = 0
		for i in range(1, P.size()):
			if rotate(A[H[-1]], A[P[right]], A[P[i]]) < 0:
				right = i
		
		if P[right] == H[0]:
			break
		else:
			H.append(P[right])
			P.remove_at(right)
	return H
	

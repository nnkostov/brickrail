class_name LayoutCell
extends Node2D

var x_idx
var y_idx
var spacing
var tracks = {}
var hover_track = null
var orientations = ["NS", "NE", "NW", "SE", "SW", "EW"]
var pretty_tracks = true

func _init(p_x_idx, p_y_idx, p_spacing):
	x_idx = p_x_idx
	y_idx = p_y_idx
	spacing = p_spacing
	
	position = Vector2(x_idx, y_idx)*spacing

func hover_at(pos, direction=null):
	hover_track = create_track_at(pos, direction)
	update()

func stop_hover():
	hover_track = null
	update()

func create_track_at(pos, direction=null):
	var i = 0
	var closest_dist = spacing+1
	var closest_track = null
	var normalized_pos = pos/spacing
	for orientation in orientations:
		var track = LayoutTrack.new(orientation[0], orientation[1], spacing)
		if direction!= null:
			if track.get_direction()!=direction:
				continue
		var dist = track.distance_to(normalized_pos)
		if dist<closest_dist:
			closest_track = track
			closest_dist = dist
	return closest_track

func get_slot_to_cell(cell):
	if cell.x_idx == x_idx+1 and cell.y_idx == y_idx:
		return "E"
	if cell.x_idx == x_idx-1 and cell.y_idx == y_idx:
		return "W"
	if cell.x_idx == x_idx and cell.y_idx == y_idx+1:
		return "S"
	if cell.x_idx == x_idx and cell.y_idx == y_idx-1:
		return "N"
	
func create_track(slot0, slot1):
	var track = LayoutTrack.new(slot0, slot1, spacing)
	return track
	
func add_track(track):
	if track.get_orientation() in tracks:
		print("can't add track, same orientation already occupied!")
		return tracks[track.get_orientation()]
	tracks[track.get_orientation()] = track
	track.connect("connections_changed", self, "_on_track_connections_changed")
	update()
	return track

func _on_track_connections_changed(orientation):
	update()

func _on_grid_view_changed(p_pretty_tracks):
	set_view(p_pretty_tracks)

func set_view(p_pretty_tracks):
	pretty_tracks = p_pretty_tracks
	for child in get_children():
		child.set_view(p_pretty_tracks)
	update()

func draw_track(track):
	
	var connections = track.connections
	var pos0 = track.pos0
	var pos1 = track.pos1
	var slot0 = track.slot0
	var slot1 = track.slot1

	if pretty_tracks:
		var track_segment = track.get_track_segment()
		if track_segment != null:
			draw_polyline(track_segment, Color.white, 6.0, true)
			draw_polyline(track_segment, Color.black, 3.0, true)
		
		for slot in connections:
			for turn in connections[slot]:
				var connection_segment =  track.get_track_connection_segment(slot, turn)
				draw_polyline(connection_segment, Color.white, 6.0, true)
				draw_polyline(connection_segment, Color.black, 3.0, true)
			if len(connections[slot]) == 0:
				var tangent = track.get_slot_tangent(slot)
				var pos = track.get_slot_pos(slot)
				var start = pos - tangent*0.5
				var stop = pos-tangent*0.25
				var normal = tangent.rotated(PI/2).normalized()
				draw_line(start*spacing, stop*spacing, Color.white, 6.0, true)
				draw_line(start*spacing, stop*spacing, Color.black, 3.0, true)
				draw_line((stop*spacing+4*normal), (stop*spacing-4*normal), Color.white, 3.0, true)
	else:
		draw_line(pos0*spacing, pos1*spacing, Color.white, 4)
		if len(connections[slot0]) == 0:
			draw_circle(pos0*spacing, spacing/10, Color.white)
		if len(connections[slot1]) == 0:
			draw_circle(pos1*spacing, spacing/10, Color.white)

func _draw():
	for orientation in tracks:
		draw_track(tracks[orientation])

	if hover_track != null:
		draw_line(hover_track.pos0*spacing, hover_track.pos1*spacing, Color(0.4,0.4,0.4), 4)
	
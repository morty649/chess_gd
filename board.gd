extends Sprite2D

const Board_size = 8
const CELL_WIDTH = 64
const piece_move = preload("res://assets/Piece_move.png")
const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

const BLACK_BISHOP = preload("res://assets/black_bishop.png")
const BLACK_KNIGHT = preload("res://assets/black_knight.png")
const BLACK_KING = preload("res://assets/black_king.png")
const BLACK_PAWN = preload("res://assets/black_pawn.png")
const BLACK_QUEEN = preload("res://assets/black_queen.png")
const BLACK_ROOK = preload("res://assets/black_rook.png")
const WHITE_BISHOP = preload("res://assets/white_bishop.png")
const WHITE_KNIGHT = preload("res://assets/white_knight.png")
const WHITE_KING = preload("res://assets/white_king.png")
const WHITE_PAWN = preload("res://assets/white_pawn.png")
const WHITE_QUEEN = preload("res://assets/white_queen.png")
const WHITE_ROOK = preload("res://assets/white_rook.png")
const TURN_BLACK = preload("res://assets/turn-black.png")
const TURN_WHITE = preload("res://assets/turn-white.png")
const drawn_image = WHITE_KING
@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn
@onready var white_pieces = $CanvasLayer/white_pieces
@onready var black_pieces = $CanvasLayer/black_pieces
#Variables 
#-numbers : black pieces  positive : white 654(CELL_WIDTH/2 king,queen,rook,bishop,knight,pawn
#board is of type array 
var board : Array
var white : bool = true
#state = false : selecting the move 
#state = true : confirming the move
var state : bool = false
#moves [] holds all possible moves by selected piece anta bayata talk
var moves = []
var selected_piece : Vector2

var promotion_square = null

var white_king = false
var black_king = false
var white_rook_left = false
var white_rook_right = false
var black_rook_left = false
var black_rook_right = false

var fifty_move_rule = 0

var unique_array:Array=[]
var amount_unique:Array=[]


func _ready():
	board.append([4,2,3,5,6,3,2,4])
	board.append([1,1,1,1,1,1,1,1])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([-1,-1,-1,-1,-1,-1,-1,-1])
	board.append([-4,-2,-3,-5,-6,-3,-2,-4])
	_display_board()
	var white_buttons = get_tree().get_nodes_in_group("white_pieces")
	var black_buttons = get_tree().get_nodes_in_group("black_pieces")
	
	for button in white_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
	for button in black_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))

func _input(event):
	if event is InputEventMouseButton && event.pressed && promotion_square == null:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): 
				print("mouse is out")
				return
			var var1 = snapped(get_global_mouse_position().x,0)/CELL_WIDTH
			var var2 = abs(snapped(get_global_mouse_position().y,0))/CELL_WIDTH
			if !state && (white && board[var2][var1] > 0 || !white && board[var2][var1]<0):
				selected_piece = Vector2(var2,var1)
				show_options()
				state = true
			elif state:
				set_move(var2,var1)
			
			

func is_mouse_out():
	if get_global_mouse_position().x < 0 || get_global_mouse_position().x >=512 || get_global_mouse_position().y<0 || get_global_mouse_position().y>512 : return true
	return false

func _display_board():
	for child in pieces.get_children():
		child.queue_free()
	for i in Board_size:
		for j in Board_size:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH/2),i*CELL_WIDTH+(CELL_WIDTH/2))
			
			match board[i][j]:
				-6:holder.texture = BLACK_KING
				-5:holder.texture = BLACK_QUEEN
				-2:holder.texture = BLACK_KNIGHT
				-1:holder.texture = BLACK_PAWN
				-3:holder.texture = BLACK_BISHOP
				-4:holder.texture = BLACK_ROOK
				0:holder.texture = null
				6:holder.texture = WHITE_KING
				5:holder.texture = WHITE_QUEEN
				2:holder.texture = WHITE_KNIGHT
				1:holder.texture = WHITE_PAWN
				3:holder.texture = WHITE_BISHOP
				4:holder.texture = WHITE_ROOK
				
	#if white : turn.texture = TURN_WHITE
	#if !white : turn.texture = TURN_BLACK
				
func show_options():
	moves = get_moves(selected_piece)
	if moves == []:
		state = true
		return
	show_dots()
func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = piece_move
		holder.global_position = Vector2(i.y*CELL_WIDTH +32,i.x*CELL_WIDTH+32)
		
func delete_dots():
	for child in dots.get_children():
		child.queue_free()

var en_passant = null

var white_king_pos = Vector2(0,4)
var black_king_pos = Vector2(7,4)

func set_move(var2,var1):
	var just_now = false
	for i in moves:
		if i.x==var2 && i.y==var1:
			match board[selected_piece.x][selected_piece.y]:
				1:
					if i.x==7: promote(i)
					if i.x==3 && selected_piece.x == 1:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
				-1:
					if i.x==0: promote(i)
					if i.x==4 && selected_piece.x == 6:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
				4:
					if selected_piece.x==0 && selected_piece.y==0 : white_rook_left = true
					elif selected_piece.x==0 && selected_piece.y==7: white_rook_right = true
				-4:
					if selected_piece.x==0 && selected_piece.y==0 : black_rook_left = true
					elif selected_piece.x==7 && selected_piece.y==7: black_rook_right = true
				6:
					if selected_piece.x == 0 && selected_piece.y == 4:
						white_king = true
						if i.y==2:
							white_rook_left = true
							white_rook_right = true
							board[0][0] = 0
							board[0][3] = 4
						elif i.y == 6:
							white_rook_left = true
							white_rook_right = true
							board[0][7] = 0
							board[0][5] = 4
					white_king_pos = i
				-6:
					if selected_piece.x == 7 && selected_piece.y == 4:
						black_king = true
						if i.y==2:
							black_rook_left = true
							black_rook_right = true
							board[7][0] = 0
							board[7][3] = -4
						elif i.y == 6:
							black_rook_left = true
							black_rook_right = true
							board[7][7] = 0
							board[7][5] = -4
					black_king_pos = i
			if !just_now : en_passant = null
			board[var2][var1] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			white = !white
			threehold(board)
			_display_board()
			break
	delete_dots()
	state = false
	#
	if is_stalemate():
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos): print("CHECKMATE")
		elif !is_in_check(white_king_pos)&&white || !is_in_check(black_king_pos)&&!white:
			print("DRAW")



func get_moves(selected : Vector2):
	var _moves 
	match abs(board[selected.x][selected.y]):
		1:_moves = get_pawn_moves(selected)
		2:_moves = get_knight_moves(selected)
		3:_moves = get_bishop_moves(selected)
		4:_moves = get_rook_moves(selected)
		5:_moves = get_queen_moves(selected)
		6:_moves = get_king_moves(selected)
	return _moves
		
func get_rook_moves(piece_position : Vector2):
	var _moves = []
	var direction = [Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	
	for i in direction:
		var pos = piece_position
		pos+=i
		while _is_valid_position(pos):
			if _is_empty(pos):
				board[pos.x][pos.y] = 4 if white else -4
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 4 if white else -4
			elif _is_enemy(pos): 
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 4 if white else -4
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 4 if white else -4
				break
			else:
				break
			pos+=i
	
	return _moves
	
func get_bishop_moves(piece_position : Vector2):
	var _moves = []
	var direction = [Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
	
	for i in direction:
		var pos = piece_position
		pos+=i
		while _is_valid_position(pos):
			if _is_empty(pos): 
				board[pos.x][pos.y] = 3 if white else -3
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 3 if white else -3
			elif _is_enemy(pos): 
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 3 if white else -3
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 3 if white else -3
				break
			else:
				break
			pos+=i
	
	return _moves
	
	
func get_queen_moves(piece_position : Vector2):
	var _moves = []
	var direction = [Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0),Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
	
	for i in direction:
		var pos = piece_position
		pos+=i
		while _is_valid_position(pos):
			if _is_empty(pos):
				board[pos.x][pos.y] = 5 if white else -5
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 5 if white else -5
			elif _is_enemy(pos): 
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 5 if white else -5
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 5 if white else -5
				break
			else:
				break
			pos+=i
	
	return _moves


func get_king_moves(piece_position : Vector2):
	var _moves = []
	var direction = [Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0),Vector2(1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(-1,1)]
	
	if white:
		board[white_king_pos.x][white_king_pos.y] = 0
	else:
		board[black_king_pos.x][black_king_pos.y] = 0
	
	for i in direction:
		var pos = piece_position + i
		if _is_valid_position(pos):
			if !is_in_check(pos):
				if _is_empty(pos): _moves.append(pos)
				elif _is_enemy(pos): 
					_moves.append(pos)
				
				
	if white && !white_king:
		if !white_rook_left && _is_empty(Vector2(0,1)) && _is_empty(Vector2(0,2)) && is_in_check(Vector2(0,2)) && _is_empty(Vector2(0,3)) && is_in_check(Vector2(0,3)) && is_in_check(Vector2(0,4)):
			_moves.append(Vector2(0,2))
		if !white_rook_right && _is_empty(Vector2(0,5)) && is_in_check(Vector2(0,5)) && _is_empty(Vector2(0,6)) && is_in_check(Vector2(0,6)):
			_moves.append(Vector2(0,6))
	elif !white && !black_king:
		if !black_rook_left && _is_empty(Vector2(7,1))  &&  _is_empty(Vector2(7,2)) && is_in_check(Vector2(7,2)) && _is_empty(Vector2(7,3)) && is_in_check(Vector2(7,3)) && is_in_check(Vector2(7,4)):
			_moves.append(Vector2(7,2))
		if !black_rook_right && is_in_check(Vector2(7,4))&& _is_empty(Vector2(7,5)) && is_in_check(Vector2(7,5)) && _is_empty(Vector2(7,6)) && is_in_check(Vector2(7,6)):
			_moves.append(Vector2(7,6))
	if white:
		board[white_king_pos.x][white_king_pos.y] = 6
	else:
		board[black_king_pos.x][black_king_pos.y] = -6
	return _moves

func get_knight_moves(piece_position : Vector2):
	var _moves = []
	var direction = [Vector2(2,1),Vector2(1,2),Vector2(-2,1),Vector2(-1,2),Vector2(1,-2),Vector2(2,-1),Vector2(-2,-1),Vector2(-1,-2)]
	for i in direction:
		var pos = piece_position+i
		
		if _is_valid_position(pos):
			if _is_empty(pos):
				board[pos.x][pos.y] = 2 if white else -2
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 2 if white else -2
			elif _is_enemy(pos): 
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 2 if white else -2
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
					_moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 2 if white else -2
			
			
	
	return _moves

	
	
	
func get_pawn_moves(piece_position : Vector2):
	var _moves = []
	var direction = Vector2(1,0) if white else Vector2(-1,0)
	var _is_first_move = (white and piece_position.x == 1) or (!white and piece_position.x == 6)
	
	if en_passant != null && (white && piece_position.x == 4 || !white && piece_position.x == 3 ) && abs(en_passant.y - piece_position.y) ==1:
		var pos = en_passant + direction
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		board[en_passant.x][en_passant.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
			_moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
		board[en_passant.x][en_passant.y] = -1 if white else 1
		
	var pos = piece_position + direction
	if _is_empty(pos):
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
			_moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
	pos = piece_position + Vector2(direction.x,1)
	if _is_valid_position(pos):
		if _is_enemy(pos) :
			var t = board[pos.x][pos.y]
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
				_moves.append(pos)
			board[pos.x][pos.y] = t
			board[piece_position.x][piece_position.y] = 1 if white else -1
	pos = piece_position + Vector2(direction.x,-1)
	if _is_valid_position(pos):
		if _is_enemy(pos):
			var t = board[pos.x][pos.y]
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
				_moves.append(pos)
			board[pos.x][pos.y] = t
			board[piece_position.x][piece_position.y] = 1 if white else -1
	pos = piece_position + direction*2
	if _is_first_move && _is_empty(pos) && _is_empty(piece_position + direction):
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos):
			_moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
	return _moves



func _is_valid_position(pos : Vector2):
	if pos.x>=0 && pos.x<Board_size && pos.y>=0 && pos.y<Board_size  : return true
	return false
	
func _is_empty(pos : Vector2):
	if board[pos.x][pos.y]==0:return true
	return false
	
func _is_enemy(pos : Vector2):
	if white&&board[pos.x][pos.y]<0 || !white&&board[pos.x][pos.y]>0 : return true
	return false
		
func promote(_var : Vector2):
	promotion_square = _var
	white_pieces.visible = white
	black_pieces.visible = !white
		
	
func _on_button_pressed(button):
	var num_char = int(button.name.substr(0,1))
	board[promotion_square.x][promotion_square.y] = -num_char if white else num_char
	white_pieces.visible = false
	black_pieces.visible =  false
	promotion_square = null
	_display_board()
	
func is_in_check(king_pos: Vector2) -> bool:
	var directions = [
		Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0), # Rook & Queen (straight)
		Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) # Bishop & Queen (diagonal)
	]
	
	# Pawn attacks
	var pawn_direction = 1 if white else -1
	var pawn_attacks = [
		king_pos + Vector2(pawn_direction, 1),
		king_pos + Vector2(pawn_direction, -1)
	]
	for pos in pawn_attacks:
		if _is_valid_position(pos):
			if (white and board[pos.x][pos.y] == -1) or (!white and board[pos.x][pos.y] == 1):
				return true
	
	# King attacks (adjacent)
	for dir in directions:
		var pos = king_pos + dir
		if _is_valid_position(pos):
			if (white and board[pos.x][pos.y] == -6) or (!white and board[pos.x][pos.y] == 6):
				return true

	# Sliding pieces (Rook, Bishop, Queen)
	for dir in directions:
		var pos = king_pos + dir
		while _is_valid_position(pos):
			var piece = board[pos.x][pos.y]
			if piece != 0:
				if dir.x == 0 or dir.y == 0: # Straight line → Rook or Queen
					if (white and piece in [-4, -5]) or (not white and piece in [4, 5]):
						return true
				if dir.x != 0 and dir.y != 0: # Diagonal line → Bishop or Queen
					if (white and piece in [-3, -5]) or (not white and piece in [3, 5]):
						return true
				break # Stop on first hit (friend or enemy)
			pos += dir
	
	# Knight attacks
	var knight_moves = [
		Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(-1, 2),
		Vector2(1, -2), Vector2(-2, -1), Vector2(-2, 1), Vector2(-1, -2)
	]
	for move in knight_moves:
		var pos = king_pos + move
		if _is_valid_position(pos):
			if (white and board[pos.x][pos.y] == -2) or (not white and board[pos.x][pos.y] == 2):
				return true

	return false
	
func is_stalemate():
	print("is stalemate called")
	if white:
		for i in range(Board_size):
			for j in range(Board_size):
				if board[i][j] > 0:
					if get_moves(Vector2(i, j)).size() != 0:
						return false
	else:
		for i in range(Board_size):
			for j in range(Board_size):
				if board[i][j] < 0:
					if get_moves(Vector2(i, j)).size() != 0:
						return false
	return true
func insuff_material():
	var white_piece = 0
	var black_piece = 0
	for i in Board_size:
		for j in Board_size:
			match board[i][j]:
				2,3:
					if white_piece==0:white_piece+=1
					else:
						return false
				-2,-3:
					if black_piece==0:black_piece+=1
					else:
						return false
				6,-6,0:pass
				_:
					return false
	return true
	
func threehold(var1:Array):
	for i in range(unique_array.size()):
		if unique_array[i]==var1:
			amount_unique[i]+=1
			if amount_unique[i]>=3:
				print("draw")
				turn.texture=drawn_image
				return
			return
	unique_array.append(var1.duplicate(true))
	amount_unique.append(1)
	
func _process(delta: float)->void:
	pass

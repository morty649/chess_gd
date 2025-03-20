extends Sprite2D

#bot moves codes
const MAX_DEPTH = 3


# Piece values for evaluation
var piece_value = {
	1: 1,   # White Pawn
	2: 3,   # White Knight
	3: 3,   # White Bishop
	4: 5,   # White Rook
	5: 9,   # White Queen
	6: 0,   # White King
	-1: -1, # Black Pawn
	-2: -3, # Black Knight
	-3: -3, # Black Bishop
	-4: -5, # Black Rook
	-5: -9, # Black Queen
	-6: 0   # Black King
}

var PAWN_BONUS = [
	[0, 0, 0, 0, 0, 0, 0, 0],
	[5, 10, 10, -20, -20, 10, 10, 5],
	[5, -5, -10, 0, 0, -10, -5, 5],
	[0, 0, 0, 20, 20, 0, 0, 0],
	[5, 5, 10, 25, 25, 10, 5, 5],
	[10, 10, 20, 30, 30, 20, 10, 10],
	[50, 50, 50, 50, 50, 50, 50, 50],
	[0, 0, 0, 0, 0, 0, 0, 0]
]

var KNIGHT_BONUS = [
	[-50, -40, -30, -30, -30, -30, -40, -50],
	[-40, -20, 0, 0, 0, 0, -20, -40],
	[-30, 0, 10, 15, 15, 10, 0, -30],
	[-30, 5, 15, 20, 20, 15, 5, -30],
	[-30, 0, 15, 20, 20, 15, 0, -30],
	[-30, 5, 10, 15, 15, 10, 5, -30],
	[-40, -20, 0, 5, 5, 0, -20, -40],
	[-50, -40, -30, -30, -30, -30, -40, -50]
]

var BISHOP_BONUS = [
	[-20, -10, -10, -10, -10, -10, -10, -20],
	[-10, 0, 0, 0, 0, 0, 0, -10],
	[-10, 0, 5, 10, 10, 5, 0, -10],
	[-10, 5, 5, 10, 10, 5, 5, -10],
	[-10, 0, 10, 10, 10, 10, 0, -10],
	[-10, 10, 10, 10, 10, 10, 10, -10],
	[-10, 5, 0, 0, 0, 0, 5, -10],
	[-20, -10, -10, -10, -10, -10, -10, -20]
]

var ROOK_BONUS = [
	[0, 0, 0, 5, 5, 0, 0, 0],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[-5, 0, 0, 0, 0, 0, 0, -5],
	[5, 10, 10, 10, 10, 10, 10, 5],
	[0, 0, 0, 0, 0, 0, 0, 0]
]

var QUEEN_BONUS = [
	[-20, -10, -10, -5, -5, -10, -10, -20],
	[-10, 0, 0, 0, 0, 0, 0, -10],
	[-10, 0, 5, 5, 5, 5, 0, -10],
	[-5, 0, 5, 5, 5, 5, 0, -5],
	[0, 0, 5, 5, 5, 5, 0, -5],
	[-10, 5, 5, 5, 5, 5, 0, -10],
	[-10, 0, 5, 0, 0, 0, 0, -10],
	[-20, -10, -10, -5, -5, -10, -10, -20]
]

var KING_BONUS = [
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-30, -40, -40, -50, -50, -40, -40, -30],
	[-20, -30, -30, -40, -40, -30, -30, -20],
	[-10, -20, -20, -20, -20, -20, -20, -10],
	[20, 20, 0, 0, 0, 0, 20, 20],
	[20, 30, 10, 0, 0, 10, 30, 20]
]

var bot_play_white=true
var bot_play_black=false


func minimax(depth: int, is_maximizing: bool, alpha: float, beta: float) -> float:
	if depth == 0 or is_game_over():
		return evaluate_position()

	var legal_moves = generate_legal_moves()
	if is_maximizing:
		var max_eval = -INF
		for move in legal_moves:
			var from_pos = move[0]
			var to_pos = move[1]
			var captured_piece = board[to_pos.x][to_pos.y]

			make_move(from_pos, to_pos)
			var eval = minimax(depth - 1, false, alpha, beta)
			undo_move(from_pos, to_pos, captured_piece)

			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)

			if beta <= alpha:
				break

		return max_eval
	else:
		var min_eval = INF
		for move in legal_moves:
			var from_pos = move[0]
			var to_pos = move[1]
			var captured_piece = board[to_pos.x][to_pos.y]

			make_move(from_pos, to_pos)
			var eval = minimax(depth - 1, true, alpha, beta)
			undo_move(from_pos, to_pos, captured_piece)

			min_eval = min(min_eval, eval)
			beta = min(beta, eval)

			if beta <= alpha:
				break

		return min_eval

func get_positional_bonus(piece, position) -> int:
	var row =int(position.y)
	var col = int(position.x)

	match piece:
		1: # White Pawn
			return PAWN_BONUS[row][col]
		-1: # Black Pawn
			return PAWN_BONUS[7 - row][col]  # Mirror the table
		2: # White Knight
			return KNIGHT_BONUS[row][col]
		-2: # Black Knight
			return KNIGHT_BONUS[7 - row][col]
		3: # White Bishop
			return BISHOP_BONUS[row][col]
		-3: # Black Bishop
			return BISHOP_BONUS[7 - row][col]
		4: # White Rook
			return ROOK_BONUS[row][col]
		-4: # Black Rook
			return ROOK_BONUS[7 - row][col]
		5: # White Queen
			return QUEEN_BONUS[row][col]
		-5: # Black Queen
			return QUEEN_BONUS[7 - row][col]
		6: # White King
			return KING_BONUS[row][col]
		-6: # Black King
			return KING_BONUS[7 - row][col]
		_:
			return 0

func evaluate_position() -> float:
	var score = 0.0
	
	for x in range(8):
		for y in range(8):
			var piece = board[x][y]
			if piece != 0:
				# Base piece value
				score += piece_value.get(piece, 0)
				
				# Add positional bonus
				score += get_positional_bonus(piece, Vector2(y, x)) 

	return score


#
#func generate_legal_moves() -> Array:
	#var moves_legal = []
	#
	#for x in range(8):
		#for y in range(8):
			#var piece = board[x][y]
			#
			## ✅ Only consider pieces belonging to the current player
			#if piece != 0 and ((white and piece > 0) or (!white and piece < 0)):
				#var possible_moves = get_moves(Vector2(x, y))
				#
				#for target in possible_moves:
					## ✅ Simulate the move
					#var temp = board[target.x][target.y]
					#board[target.x][target.y] = piece
					#board[x][y] = 0
#
					## ✅ Check for king safety after the move
					#var king_pos = white_king_pos if white else black_king_pos
					#if not is_in_check(king_pos):
						#moves_legal.append([Vector2(x, y), target])
					#
					## ✅ Undo the simulation
					#board[x][y] = piece
					#board[target.x][target.y] = temp
	#
	#return moves_legal
	
func generate_legal_moves():
	var legal_moves = []
	for x in range(8):
		for y in range(8):
			var piece = board[x][y]
			if (white and piece > 0) or (not white and piece < 0):
				var possible_moves = get_moves(Vector2(x, y))
				for target in possible_moves:
					# Simulate the move to check if it resolves check
					var captured_piece = board[target.x][target.y]
					board[target.x][target.y] = piece
					board[x][y] = 0
					
					var king_pos = white_king_pos if piece > 0 else black_king_pos
					if piece == 6:
						king_pos = target
					if not is_in_check(king_pos):
						legal_moves.append([Vector2(x, y), target])
					
					# Undo the simulated move
					board[x][y] = piece
					board[target.x][target.y] = captured_piece
	return legal_moves

#memorizes
#
## Executes a move on the board
#func make_move(start: Vector2, target: Vector2):
	#var piece = board[start.x][start.y]
	#var captured_piece = board[target.x][target.y]
	#board[target.x][target.y] = piece
	#board[start.x][start.y] = 0
	#
	## Handle pawn promotion
	#if abs(piece) == 1:
		#if (piece == 1 and target.y == 7) or (piece == -1 and target.y == 0):
			#board[target.x][target.y] = 5 if piece > 0 else -5
#
	## Update king's position if moved
	#if piece == 6:
		#white_king_pos = target
	#elif piece == -6:
		#black_king_pos = target
#
	## Switch turns after a successful move
	#white = not white
#
#3issues
#func make_move(start: Vector2, target: Vector2):
	#var piece = board[start.x][start.y]
	#board[target.x][target.y] = piece
	#board[start.x][start.y] = 0
	#
	## Update king's position if moved
	#if piece == 6:
		#white_king_pos = target
	#elif piece == -6:
		#black_king_pos = target
	#
	## 🔥 Commit to the turn — no undo!
	#white = not white

func make_move(start: Vector2, target: Vector2):
	var piece = board[start.x][start.y]
	var captured_piece = board[target.x][target.y]
	board[target.x][target.y] = piece
	board[start.x][start.y] = 0
	
	# Update king's position if moved
	if piece == 6:
		white_king_pos = target
	elif piece == -6:
		black_king_pos = target

	# Handle promotion
	if abs(piece) == 1 and (target.y == 0 or target.y == 7):
		board[target.x][target.y] = 5 if piece > 0 else -5
	
	# Switch turn
	white = not white

# Called when it's the bot's turn to move #3issues
#func make_bot_move():
	#if (white and bot_play_white) or (not white and bot_play_black):
		#var best_move = get_best_move()
		#if best_move!=null:
			#var start = best_move[0]
			#var target = best_move[1]
			#
			## Directly execute the chosen move
			#make_move(start, target)
			##memorizes
		##elif best_move==null:
			##if is_in_check(white_king_pos):
				##print("white lost")
			##elif !is_in_check(white_king_pos):
				##print("draw")
				##
func make_bot_move():
	if (white and bot_play_white) or (not white and bot_play_black):
		var best_move = get_best_move()
		if best_move:
			var start = best_move[0]
			var target = best_move[1]
			
			# Make the move temporarily
			var piece = board[start.x][start.y]
			var captured_piece = board[target.x][target.y]
			board[target.x][target.y] = piece
			board[start.x][start.y] = 0
			
			# Update king's position if needed
			if piece == 6:
				white_king_pos = target
			elif piece == -6:
				black_king_pos = target
			
			# Only switch turns if the move doesn't leave the king in check
			if not is_in_check(white_king_pos if piece > 0 else black_king_pos):
				white = not white
			else:
				# Undo the move if it's invalid
				board[start.x][start.y] = piece
				board[target.x][target.y] = captured_piece
				if piece == 6:
					white_king_pos = start
				elif piece == -6:
					black_king_pos = start
			if is_stalemate()&& is_in_check(white_king_pos):
				turn.texture=you_won
			





func undo_move(start: Vector2, target: Vector2, captured_piece: int):
	board[start.x][start.y] = board[target.x][target.y]
	board[target.x][target.y] = captured_piece
	
	# Restore king position if necessary
	if board[start.x][start.y] == 6:
		white_king_pos = start
	elif board[start.x][start.y] == -6:
		black_king_pos = start
	
	# Restore turn
	white = !white

#old best move bot memorizes
#func get_best_move() -> Array:
	#var best_move = null
	#var best_score = -INF if white else INF
	#var legal_moves = generate_legal_moves()
#
	#for move in legal_moves:
		#var start = move[0]
		#var target = move[1]
		#
		#var piece = board[start.x][start.y]
		#var captured_piece = board[target.x][target.y]
		#var is_promotion = false
		#var promoted_piece = 0
		#
		## Simulate the move
		#board[target.x][target.y] = piece
		#board[start.x][start.y] = 0
		#
		## Handle pawn promotion
		#if abs(piece) == 1:  # Pawn
			#if (piece == 1 and target.y == 7) or (piece == -1 and target.y == 0):
				#is_promotion = true
				#promoted_piece = 5 if piece > 0 else -5
				#board[target.x][target.y] = promoted_piece
		#
		## Update king position if needed
		#var original_king_pos = white_king_pos if piece == 6 else black_king_pos
		#if piece == 6:
			#white_king_pos = target
		#elif piece == -6:
			#black_king_pos = target
		#
		## Evaluate the position
		#var score = evaluate_position()
#
		## Undo the move
		#board[start.x][start.y] = piece
		#board[target.x][target.y] = captured_piece
		#if is_promotion:
			#board[target.x][target.y] = captured_piece  # Restore captured piece
		#if piece == 6:
			#white_king_pos = original_king_pos
		#elif piece == -6:
			#black_king_pos = original_king_pos
		#
		## Choose the best move
		#if (white and score > best_score) or (not white and score < best_score):
			#best_score = score
			#best_move = move
#
	#return best_move
#

func get_best_move():
	var best_score = -INF if white else INF
	var best_move = null

	var all_moves = generate_legal_moves()
	for move in all_moves:
		var start = move[0]
		var target = move[1]
		
		# Make the move temporarily
		var piece = board[start.x][start.y]
		var captured_piece = board[target.x][target.y]
		board[target.x][target.y] = piece
		board[start.x][start.y] = 0
		
		# Handle king position update (if needed)
		var old_king_pos = white_king_pos if piece == 6 else black_king_pos
		if piece == 6:
			white_king_pos = target
		elif piece == -6:
			black_king_pos = target
		
		# Evaluate the board state
		var score = evaluate_position()
		
		# 🛑 Undo ONLY during simulation
		board[start.x][start.y] = piece
		board[target.x][target.y] = captured_piece
		if piece == 6:
			white_king_pos = old_king_pos
		elif piece == -6:
			black_king_pos = old_king_pos
		
		# Choose the best move based on score
		if white and score > best_score or not white and score < best_score:
			best_score = score
			best_move = move
	
	return best_move



var bot_moving = false
var turn_in_progress=false
#var turn_in_progress = false


#func sets_move(from_pos, to_pos):
	#








func is_game_over() -> bool:
	# Check if the current player is in checkmate
	if is_in_check(white_king_pos):
		return true
	
	# Check if the current player is in stalemate
	if is_stalemate():
		return true
	
	# Check for insufficient material
	if insuff_material():
		return true
	
	return false
	





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


const brain_lag=preload("res://assets/brain_lag_detected.png")
const you_are_dumb=preload("res://assets/you_are_dumb.png")
const you_let_me_win=preload("res://assets/you_let_me_win.png")
const you_call_that_plan=preload("res://assets/you_call_that_a_plan.png")
const winning_human_standards=preload("res://assets/winning_by_human_standards.png")
const common_you_are_better=preload("res://assets/WhatsApp Image 2025-03-19 at 4.12.23 PM.jpeg")

const you_won=preload("res://assets/you_won.png")
const bot_won=preload("res://assets/bot_won.png")

const white_in_favour=preload("res://assets/white_is_in_favour.png")
const black_in_favour=preload("res://assets/black_in_favour.png")
@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $turner
@onready var white_pieces = $CanvasLayer/white_pieces
@onready var black_pieces = $CanvasLayer/black_pieces
@onready var new_game_button = $"CanvasGroup/Control/new game"
@onready var restart_button = $CanvasGroup/Control/reset_game
@onready var one_v_one_button =$"CanvasGroup/Control/1v1"
@onready var bot_button = $CanvasGroup/Control/bot
#Variables 
#-numbers : black pieces  positive : white 654(CELL_WIDTH/2 king,queen,rook,bishop,knight,pawn
#board is of type array 
var board : Array
var white : bool =true
var bot_playing=false
var player_playing=false
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
	new_game_button.pressed.connect(on_new_game)
	restart_button.pressed.connect(reset_board)
	one_v_one_button.pressed.connect(one_v_one)
	bot_button.pressed.connect(bot_enable)
	var white_buttons = get_tree().get_nodes_in_group("white_pieces")
	var black_buttons = get_tree().get_nodes_in_group("black_pieces")
	
	for button in white_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
	for button in black_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
		
func on_new_game():
	one_v_one_button.disabled=false
	bot_button.disabled=false
	new_game_button.disabled=true
	restart_button.disabled=true
	player_playing=true
	print("new game selected")
	reset_board()

func reset_board():
	board.append([4,2,3,5,6,3,2,4])
	board.append([1,1,1,1,1,1,1,1])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([-1,-1,-1,-1,-1,-1,-1,-1])
	board.append([-4,-2,-3,-5,-6,-3,-2,-4])
	
	_display_board()
	
func one_v_one():
	player_playing=true
	bot_playing=false
	new_game_button.disabled=false
	restart_button.disabled=false
	reset_board()
	
func bot_enable():
	bot_playing=true
	player_playing=false
	new_game_button.disabled=false
	restart_button.disabled=false
	reset_board()

	

func _input(event):
	
	if bot_playing:
		if white&&bot_play_white || !white &&bot_play_black:
			make_bot_move()
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
				
	
	if bot_playing:
		var score=evaluate_position()
		print(score)
		if score>=0 and score<50:
			turn.texture=you_call_that_plan
		elif score>=50 and score<100:
			turn.texture=you_are_dumb
		elif score>100:
			turn.texture=you_let_me_win
		elif score<=-200:
			turn.texture=winning_human_standards
		elif score<=-100 and score >=-199:
			turn.texture=common_you_are_better
		elif score>-100 and score<=0:
			turn.texture=brain_lag
		
	elif player_playing:
		var score=evaluate_position()
		print(score)
		if score>=0:
			turn.texture=white_in_favour
		else:
			turn.texture=black_in_favour
		
		
				
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
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			if is_in_check(white_king_pos):
				print("white lost")
			elif is_in_check(black_king_pos):
				print("black lost")
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
	board[promotion_square.x][promotion_square.y] = num_char if white else -num_char
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
	#print("is stalemate called")
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

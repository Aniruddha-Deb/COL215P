from K_map_gui_tk import *




def generate_binary_list(dimension):
	if dimension == 4:
		return ["00", "01", "11", "10"]
	if dimension == 2:
		return ["0", "1"]	


def filter_list(binary_list, term):
	# print(f"Here is the list :- {binary_list}")
	invalid_indices = []
	for literal_pos in range(len(term)):
		for i, entry in enumerate(binary_list):
			# print(f"Term[literal_pos] :- {term[literal_pos]}")
			# print(f"Entry {entry}")
			if term[literal_pos] != None and entry[literal_pos] != str(term[literal_pos]) :
				invalid_indices.append(i)


	filtered_list = []
	for index in range(len(binary_list)):
		if not (index in invalid_indices):
			filtered_list.append(binary_list[index])	

	return filtered_list

def integer_log2(dimension):
	if dimension == 1:
		return 0
	if dimension == 2:
		return 1
	if dimension == 4:
		return 2

def next(entry):
	if entry == "0":
		return "1"
	elif entry == "1":
		return "0"
	elif entry == "00":
		return "01"
	elif entry == "01":
		return "11"
	elif entry == "11":
		return "10"
	else:
		return "00"

def prev(entry):
	if entry == "0":
		return "1"
	elif entry == "1":
		return "0"
	elif entry == "00":
		return "10"
	elif entry == "01":
		return "00"
	elif entry == "11":
		return "01"
	else:
		return "11"


def position(entry):
	if entry == "00":
		return 0
	elif entry == "01":
		return 1
	elif entry == "11":
		return 2
	elif entry == "10":
		return 3
	elif entry == "0":
		return 0
	else :
		return 1
def get_top_row(binary_list):
	if len(binary_list) == 4:
		return 0 # any row can be top row
	else:
		for row, entry in enumerate(binary_list):
			if (not (prev(entry) in binary_list)):
				return position(entry)
		return -1

def get_bottom_row(binary_list):
	if len(binary_list) == 4:
		return 3 
	else:
		for row, entry in enumerate(binary_list):
			if (not (next(entry) in binary_list)):
				return position(entry)
		return -1

def get_left_col(binary_list):
	if len(binary_list) == 4:
		return 0 # any col can be left col
	else:
		for col, entry in enumerate(binary_list):
			if (not (prev(entry) in binary_list)):
				return position(entry)
		return -1

def get_right_col(binary_list):
	if len(binary_list) == 4:
		return 3 
	else:
		for col, entry in enumerate(binary_list):
			if (not (next(entry) in binary_list)):
				return position(entry)
		return -1

def check_legal(kmap_function, binary_list1, binary_list2):
	for entry1 in binary_list1:
		for entry2 in binary_list2:
			if kmap_function[position(entry1)][position(entry2)]== 0:
				return False

	return True


def is_legal_region(kmap_function, term):


	d1 = len(kmap_function)
	d2 = len(kmap_function[0])

	binary_list1 = filter_list(generate_binary_list(d1), term[0: integer_log2(d1)])
	binary_list2 = filter_list(generate_binary_list(d2), term[integer_log2(d1): ])

	top_r = get_top_row(binary_list1)
	bottom_r = get_bottom_row(binary_list1)
	left_c = get_left_col(binary_list2)
	right_c = get_right_col(binary_list2)
	
	is_legal = check_legal(kmap_function, binary_list1, binary_list2)

	return ((top_r, left_c), (bottom_r, right_c), is_legal)


def test(kmap_function, root, term):
	(upper_left, bottom_right, is_legal) = is_legal_region(kmap_function, term)
	top_r, left_c = upper_left
	bottom_r, right_c = bottom_right

	color = 'blue'

	if not is_legal:
		color = 'red'

	root.draw_region(top_r, left_c, bottom_r, right_c, color)


kmap_function = [[0,1,1,0], ['x',1,'x',0], [1,0,0,0], [1,'x',0,0]]
root = kmap(kmap_function)

# TEST - 1
term = [0, None, None, 1]
test(kmap_function, root, term)


# TEST - 2
term = [1, 0, None, 0]
test(kmap_function, root, term)
root.mainloop()

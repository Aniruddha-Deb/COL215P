from K_map_gui_tk import *



def integer_log2(dimension):
	current_base    = 1
	current_log_val = 0

	while dimension != current_base:
		current_base    *= 2
		current_log_val += 1
	return current_log_val

def xor(a, b):
    if ( a == b ):
        return '0'
    else:
        return '1'

def generate_binary_list(dimension):
	"""
	given a dimension, (a,b,c,d). This will generate 
	
	Input:
		integer, denoting how many expressions are there (this is 2^no. of 
		variables)
	Returns:
		A list of all possible binary expressions
	"""

	print(dimension)
	if dimension == 2:
		return ["0", "1"]
	
	half_list = generate_binary_list(dimension//2)
	
	binary_list = []
	
	for i in range(0, dimension//2):
		binary_list.append("0" + half_list[i])
	
	for i in range(0, dimension//2):
		binary_list.append("1" + half_list[i])

	return binary_list

def generate_gray_code_list(dimension):

    if dimension == 2:
        return ["0", "1"]

    half_list = generate_gray_code_list(dimension//2)

    l1 = []
    l2 = []

    for i in range(0, dimension//2):
        l1.append("0"+half_list[i])

    for i in range(0,dimension//2):
        l2.append("1"+half_list[i])

    l2.reverse()

    return l1+l2

# preserves order!
def filter_list(gray_code_list, term):
	# print(f"Here is the list :- {gray_code_list}")
	invalid_indices = []
	for literal_pos in range(len(term)):
		for i, entry in enumerate(gray_code_list):
			# print(f"Term[literal_pos] :- {term[literal_pos]}")
			# print(f"Entry {entry}")
			if term[literal_pos] != None and entry[literal_pos] != str(term[literal_pos]) :
				invalid_indices.append(i)


	filtered_list = []
	for index in range(len(gray_code_list)):
		if not (index in invalid_indices):
			filtered_list.append(gray_code_list[index])	

	return filtered_list



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

def get_top_row(binary_list, d):
	if len(binary_list) == d:
		return 0 # any row can be top row
	else:
		for row, entry in enumerate(binary_list):
			if (not (prev(entry) in binary_list)):
				return position(entry)
		return -1

def get_bottom_row(binary_list, d):
	if len(binary_list) == d:
		return d-1 
	else:
		for row, entry in enumerate(binary_list):
			if (not (next(entry) in binary_list)):
				return position(entry)
		return -1

def get_left_col(binary_list, d):
	if len(binary_list) == d:
		return 0 # any col can be left col
	else:
		for col, entry in enumerate(binary_list):
			if (not (prev(entry) in binary_list)):
				return position(entry)
		return -1

def get_right_col(binary_list, d):
	if len(binary_list) == d:
		return d-1 
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

def transpose(l):
	return [[row[i] for row in l] for i in range(len(l[0]))]

def get_top(gcl_map, gcl, filt_list, dim):
	if len(filt_list) == dim:
		return 0 # WLOG
	else:
		idx = gcl_map[filt_list[0]]
		while gcl[idx-1] in filt_list:
			idx -= 1

		if idx < 0:
			return dim+idx
		else:
			return idx

def get_bottom(gcl_map, gcl, filt_list, dim):
	if len(filt_list) == dim:
		return dim-1 # WLOG
	else:
		idx = gcl_map[filt_list[0]]
		while gcl[(idx+1)%dim] in filt_list:
			idx = (idx+1)%dim

		return idx

def is_legal_region(kmap_function, term):

	kmap_function = transpose(kmap_function)

	rows = len(kmap_function)
	cols = len(kmap_function[0])

	gcl_rows = generate_gray_code_list(rows)
	gcl_cols = generate_gray_code_list(cols)
	gcl_map_rows = {gcl_rows[i]:i for i in range(len(gcl_rows))}
	gcl_map_cols = {gcl_cols[i]:i for i in range(len(gcl_cols))}

	filt_rows = filter_list(gcl_rows, term[0: integer_log2(rows)])
	filt_cols = filter_list(gcl_cols, term[integer_log2(rows): ])

	top_r    = get_top(gcl_map_cols, gcl_cols, filt_cols, cols)
	bottom_r = get_bottom(gcl_map_cols, gcl_cols, filt_cols, cols)
	left_c   = get_top(gcl_map_rows, gcl_rows, filt_rows, rows)
	right_c  = get_bottom(gcl_map_rows, gcl_rows, filt_rows, rows)	

	is_legal = check_legal(kmap_function, filt_rows, filt_cols)

	return ((top_r, left_c), (bottom_r, right_c), is_legal)

def test(kmap_function, root, term):
	(upper_left, bottom_right, is_legal) = is_legal_region(kmap_function, term)
	# print(upper_left)
	# print(bottom_right)
	top_r, left_c = upper_left
	bottom_r, right_c = bottom_right

	color = 'blue'

	if not is_legal:
		color = 'red'

	root.draw_region(top_r, left_c, bottom_r, right_c, color)

if __name__ == "__main__":
    kmap_function = [[0,1,1,0], ['x',1,'x',0], [1,0,0,0], [1,'x',0,0]]
    root = kmap(kmap_function)
    
    # TEST - 1
    term = [0, None, None, 1]
    test(kmap_function, root, term)
    
    
    # TEST - 2
    # term = [1, 0, None, 0]
    # test(kmap_function, root, term)
    
    # TEST - 3
    # term = [1, 1, None, None]
    # test(kmap_function, root, term)
    
    # TEST - 4
    # term = [1, None, None, None]
    # test(kmap_function, root, term)
    
    # TEST - 5
    # term = [1, None, 1, None]
    # test(kmap_function, root, term)
    
    # TEST - 6
    # term = [0, None, 1, 1]
    # test(kmap_function, root, term)
    
    
    # 2 variables
    # kmap_function2 = [[0, 1], [1, 1]]
    # root = kmap(kmap_function2)
    
    # TEST - 1
    # term = [0, None]
    # test(kmap_function2, root, term)
    
    
    # TEST - 2
    # term = [1, None]
    # test(kmap_function2, root, term)
    
    # TEST - 3
    # term = [1, 1]
    # test(kmap_function2, root, term)
    
    # TEST - 4
    # term = [1, 0]
    # test(kmap_function2, root, term)
    
    # TEST - 5
    # term = [None, None]
    # test(kmap_function2, root, term)
    # TEST - 6
    # term = [None, 1]
    # test(kmap_function2, root, term)
    
    # 3 variables
    # kmap_function3 = [[0, 1, 0, 0], [1, 1, 0, 0]]
    # root = kmap(kmap_function3)
    
    # TEST - 1
    # term = [1, None, None]
    # test(kmap_function3, root, term)
    
    # TEST - 2
    # term = [None, 1, None]
    # test(kmap_function3, root, term)
    
    # TEST - 3
    # term = [None, None, None]
    # test(kmap_function3, root, term)
    
    # TEST - 4
    # term = [1, None, 0]
    # test(kmap_function3, root, term)
    
    # TEST - 5
    # term = [1, 0, 1]
    # test(kmap_function3, root, term)
    
    # TEST - 6
    # term = [None, 1, 1]
    # test(kmap_function3, root, term)
    
    # TEST - 7
    # term = [0, 1, None]
    # test(kmap_function3, root, term)
    
    root.mainloop()

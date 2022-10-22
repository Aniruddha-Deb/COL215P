
def get_num_literals(func_TRUE, func_DC):
    seen_chars = set()
    for l in func_TRUE+func_DC:
        for c in l:
            if c != "'" and c not in seen_chars:
                seen_chars.add(c)

    return len(seen_chars)

def get_binary_literal(term):
    literal = ""
    idx = 0
    for i in range(len(term)):
        if term[i] == "'":
            literal[-1] ^= (1<<(ord(term[i-1])-97))
        else:
            literal[^= (1<<(ord(term[i])-97))
    return literal

# def get_binary_literals(term, n):
#     # will need to generate a list here?
#     fixed_literals = {}
#     free_literals = set([chr(i) for i in range(97,97+n)])
#     for i in range(len(term)):
#         if term[i] == "'":
#             fixed_literals[term[i-1]] = 0
#             # look one back and negate
#         else:
#             free_literals.remove(term[i])
#             fixed_literals[term[i]] = 1
# 
#     # now get the length of free literals, bruteforce terms and generate 
#     # binary terms
#     literals = []
#     for i in range(2**len(free_literals)):
#         literals

def comb_function_expansion(func_TRUE, func_DC):
    """
    determines the maximum legal region for each term in the K-map function 

    Arguments:
        func_TRUE: list containing the terms for which the output is '1'
        func_DC: list containing the terms for which the output is 'x' 
    Return:
        a list of terms: expanded terms in form of boolean literals
    """
    
    true_literals = set([get_binary_literal(s) for s in func_TRUE])
    dc_literals = set([get_binary_literal(s) for s in func_DC])
    literals = true_literals.union(dc_literals)

    reduced_literals = []
    # start reducing
    for l in literals:
        




    


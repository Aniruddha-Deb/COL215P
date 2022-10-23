import itertools
import math

def get_num_literals(func_TRUE, func_DC):
    seen_chars = set()
    for l in func_TRUE+func_DC:
        for c in l:
            if c != "'" and c not in seen_chars:
                seen_chars.add(c)

    return len(seen_chars)

def get_binary_literal(term, n):
    literal = "-"*n
    for i in range(len(term)):
        if term[i] == "'":
            literal[ord(term[i-1])-97] = "0"
        else:
            literal[ord(term[i])-97] = "1"
    return literal

def can_combine(l1, l2):
    """
    Returns true if literals l1 and l2 can be combined with each other (all their
    ignore bits (-) match and they differ by only one bit elsewhere)
    """
    # TODO @sachit
    pass

def combine(l1, l2):
    """
    Combines literals l1 and l2. The literals are guaranteed to be combinable.
    """
    # TODO @sachit
    pass

def comb_function_expansion(func_TRUE, func_DC):
    """
    determines the maximum legal region for each term in the K-map function 

    Arguments:
        func_TRUE: list containing the terms for which the output is '1'
        func_DC: list containing the terms for which the output is 'x' 
    Return:
        a list of terms: expanded terms in form of boolean literals
    """
    
    n = get_num_literals(func_TRUE, func_DC)
    true_literals = set([get_binary_literal(s, n) for s in func_TRUE])
    dc_literals = set([get_binary_literal(s, n) for s in func_DC])
    literals = [true_literals.union(dc_literals)]

    # now, reduce all the literals sequentially using quine-mccluskey
    # will take O(n^2) at each step.
    for t in range(n):
        paired_literals = itertools.combinations(literals[-1],2)
        literal_paired = dict.fromkeys(literals[-1], False)
        literals.append(set())
        
        for (l1,l2) in paired_literals:
            if can_combine(l1,l2):
                l = combine(l1, l2)
                literals[-1].add(l)
                literal_paired[l1] = True
                literal_paired[l2] = True

        for l in literal_paired:
            if not literal_paired[l]:
                literals[-1].add(l)
    
    # literals[-1] is the set that contains all the combined terms at the end.
    # Now, make the grid with the true literals and get the reverse mapping.
    #
    # TODO @sachit






    


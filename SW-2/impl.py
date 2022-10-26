import itertools
import math

def get_num_literals(func_TRUE, func_DC):
    seen_chars = set()
    for l in func_TRUE+func_DC:
        for c in l:
            if c != "'" and c not in seen_chars:
                seen_chars.add(c)

    return len(seen_chars)

def str2bin(term, n):
    literal = []
    for i in range(0, n):
        literal.append('-')
    for i in range(len(term)):
        if term[i] == "'":
            literal[ord(term[i-1])-97] = '0'
        else:
            literal[ord(term[i])-97] = '1'
    return ''.join(literal)

def bin2str(term):
    literal = []
    for i in range(len(term)):
        if term[i] == '0':
            literal.append(f"{chr(i+97)}'")
        elif term[i] == '1':
            literal.append(f"{chr(i+97)}")
    return ''.join(literal)

def can_combine(l1, l2):

    """
    Returns true if literals l1 and l2 can be combined with each other (all their
    ignore bits (-) match and they differ by only one bit elsewhere)
    """
    
    if len(l1) != len(l2):
        return False
    else:
        diff_count = 0
        for i in range(0, len(l1)):
            if l1[i] != l2[i]:
                diff_count += 1

        if diff_count > 1:
            return False
        else:
            return True

def combine(l1, l2):
    """
    Combines literals l1 and l2. The literals are guaranteed to be combinable.
    """
    l = []
    for i in range(0, len(l1)):
        if l1[i] == l2[i]:
            l.append(l1[i])
        else:
            l.append('-')

    return ''.join(l)

def str_list(term_list):
    lst = []
    for term in term_list:
        lst.append(''.join(term))

    return lst

def term_size(term):
    return sum([1 for c in term if c != '-'])

def is_simple(term):
    return '-' in list(term)

def filter_list(literals):
    return list(set(literals))

def comb_function_expansion(func_TRUE, func_DC, do_log=False):
    """
    determines the maximum legal region for each term in the K-map function 

    Arguments:
        func_TRUE: list containing the terms for which the output is '1'
        func_DC: list containing the terms for which the output is 'x' 
    Return:
        a list of terms: expanded terms in form of boolean literals
    """
    original_terms = {}
    
    n = get_num_literals(func_TRUE, func_DC)
    true_terms = [str2bin(s, n) for s in func_TRUE]
    dc_terms = [str2bin(s, n) for s in func_DC]
    literals = [true_terms + dc_terms]

    for term in true_terms:
        original_terms[''.join(term)] = [term]
    for term in dc_terms:
        original_terms[''.join(term)] = [term] 


    # now, reduce all the literals sequentially using quine-mccluskey
    # will take O(n^2) at each step.

    term_graph = {}

    for t in range(n):

        paired_literals = itertools.combinations(literals[-1],2)
        term_graph = {**dict.fromkeys(literals[-1], set()), **term_graph}
        literals.append([])
        for (l1,l2) in paired_literals:
            if can_combine(l1,l2):
                l = combine(l1, l2)
                term_graph[l1].add(l)
                term_graph[l2].add(l)

                literals[-1].append(l)

        literals[-1] = filter_list(literals[-1])

    # print(term_graph)

    # Now, make the grid with the true literals and get the reverse mapping.

    maximal_regions = []

    for i,term in enumerate(true_terms):
        print(f'N = {i}')
        print(f'Current term expansion: {bin2str(term)}')
        print(f'Legal regions for expansion: ', end='')
        q = [term]
        visited = dict.fromkeys(term_graph.keys(), False)
        maximal_regions.append(term)
        while q:
            t = q.pop(0)
            if term_size(t) < term_size(maximal_regions[-1]):
                maximal_regions[-1] = t
            for c in term_graph[t]:
                if not visited[c]:
                    visited[c] = True
                    q.append(c)
                    print(f"{bin2str(c)} ", end='')

        print()
        print(f"Final maximal region: {bin2str(maximal_regions[-1])}")
        print()

    return [bin2str(t) for t in maximal_regions]

if __name__ == '__main__':
    print(comb_function_expansion(["a'b'c'd'e'", "a'b'cd'e", "a'b'cde'", "a'bc'd'e'", "a'bc'd'e", "a'bc'de", "a'bc'de'", "ab'c'd'e'", "ab'cd'e'"], ["abc'd'e'", "abc'd'e", "abc'de", "abc'de'"]))
    
    


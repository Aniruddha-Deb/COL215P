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
    literal = []
    for i in range(0, n):
        literal.append('-')
    for i in range(len(term)):
        if term[i] == "'":
            literal[ord(term[i-1])-97] = '0'
        else:
            literal[ord(term[i])-97] = '1'
    return literal

def get_string_term(literal_list, n):

    term = ''

    for i in range(0, n):
        if literal_list[i] == '-':
            pass
        elif literal_list[i] == '0':
            term += chr(97 + i)
            term += "'"
        else:
            term += chr(97 + i)


    return term


def can_combine(l1, l2):

    """
    Returns true if literals l1 and l2 can be combined with each other (all their
    ignore bits (-) match and they differ by only one bit elsewhere)
    """
    # TODO @sachit
    
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
    # TODO @sachit

    # at all the places which they match keep them as it is, at places which they don't match add _

    l = []

    for i in range(0, len(l1)):
        if l1[i] == l2[i]:
            l.append(l1[i])
        else:
            l.append('-')

    return l
    

def str_list(term_list):

    lst = []

    for term in term_list:
        lst.append(''.join(term))

    return lst

def term_size(term):

    t_size = 0

    for c in term:
        if c != '-':
            t_size+=1

    return t_size

def is_simple(term):

    for c in term:
        if c == '-':
            return False

    return True


def filter_list(literals):

    new_list = []

    for i in range(0, len(literals)):
        duplicate = False
        for j in range(i+1, len(literals)):

            if literals[i] == literals[j]:
                duplicate = True

        if not duplicate:
            new_list.append(literals[i])


    return new_list

def s(literal):
    return ''.join(literal)

def do_nothing(x):
    pass

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
    if do_log:
        log = lambda x: print(x)
    else:
        log = lambda x: do_nothing(x)
    
    n = get_num_literals(func_TRUE, func_DC)
    true_terms = [get_binary_literal(s, n) for s in func_TRUE]
    dc_terms = [get_binary_literal(s, n) for s in func_DC]
    literals = [true_terms + dc_terms]

    for term in true_terms:
        original_terms[''.join(term)] = [term]
    for term in dc_terms:
        original_terms[''.join(term)] = [term] 


    # now, reduce all the literals sequentially using quine-mccluskey
    # will take O(n^2) at each step.

    # mapping of terms to next terms
    term_graph = {}

    for t in range(n):

        paired_literals = itertools.combinations(literals[len(literals) - 1],2)
        literal_paired = dict.fromkeys(str_list(literals[len(literals) - 1]), False)
        literals.append([])
        for (l1,l2) in paired_literals:
            if t == 3:
                pass
            if can_combine(l1,l2):
                l = combine(l1, l2)
                if l1 not in term_graph:
                    term_graph[s(l1)] = []
                if l2 not in term_graph:
                    term_graph[s(l2)] = []
                term_graph[s(l1)].append(l)
                term_graph[s(l2)].append(l)

                original_terms[''.join(l)] = original_terms[''.join(l1)] + (original_terms[''.join(l2)])

                literals[len(literals) - 1].append(l)
                literal_paired[''.join(l1)] = True
                literal_paired[''.join(l2)] = True

        for l in literal_paired.keys():
            if not literal_paired[l]:
                literals[len(literals) - 1].append([*l])
        


        literals = [ filter_list(literals[len(literals) - 1]) ]
    # literals[-1] is the set that contains all the combined terms at the end.
    # Now, make the grid with the true literals and get the reverse mapping.
    #
    # TODO @sachit


    minimal_terms = {}

    if log:
        for i,term in enumerate(true_terms):
            print(f'N = {i}')
            print(f'Current term expansion: {term}')
            print(f'Legal regions for expansion: ', end='')
            q = queue()
            t = term
            while t in term_graph:
                print(f"Regions under consideration: {term_graph[t]}")
                t = term_graph[]

            print(f"Final maximal region")

    for term in original_terms.keys():
        if is_simple(term) and not (term in str_list(dc_terms)):
            minimal_terms[term] = term

    for (i,rev_term) in enumerate(original_terms.keys()):
        log(f'N = {i}')
        log(f'Current term expansion: {s(rev_term)}')
        for term in original_terms[rev_term]:
            if(is_simple(term)) and (not (term in dc_terms)):
                if term_size(rev_term) < term_size(minimal_terms[''.join(term)]):
                    minimal_terms[''.join(term)] = rev_term


    minimal_list = []
    for term in minimal_terms.keys():
        minimal_list.append(get_string_term(minimal_terms[term], n))


    return minimal_list
if __name__ == '__main__':
    print(comb_function_expansion(["a'b'c'd'e'", "a'b'cd'e", "a'b'cde'", "a'bc'd'e'", "a'bc'd'e", "a'bc'de", "a'bc'de'", "ab'c'd'e'", "ab'cd'e'"], ["abc'd'e'", "abc'd'e", "abc'de", "abc'de'"]))
    
    # print(comb_function_expansion(["a'b'c", "a'bc", "ab'c'"], ["a'bc'", "ab'c"]))
    # print(comb_function_expansion(["a'bc'd'", "abc'd'", "a'b'c'd", "a'bc'd", "a'b'cd"], ["abc'd"]))
    


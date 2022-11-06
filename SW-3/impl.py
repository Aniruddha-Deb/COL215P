import itertools
import math
import time
from itertools import chain, combinations

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
    if not literal:
        return '1'
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
        if diff_count > 1:
            return False
        else:
            return True

def combine(l1, l2):
    """
    Combines literals l1 and l2. 
    """
    l = []
    diff_count = 0
    for i in range(0, len(l1)):
        if l1[i] == l2[i]:
            l.append(l1[i])
        else:
            diff_count += 1
            if diff_count > 1:
                return None
            l.append("-")

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

def powerset(iterable):
    "powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
    s = list(iterable)
    return chain.from_iterable(set(combinations(s, r)) for r in range(len(s)+1))

def get_expansion_terms(term, exp_term):
    blank_idxs = [i for i in range(len(exp_term)) if exp_term[i] == '-']
    t = list(exp_term)
    terms = set()
    for g in powerset(blank_idxs):
        for idx in blank_idxs:
            if idx in g:
                t[idx] = '1'
            else:
                t[idx] = '0'
        terms.add(''.join(t))

    terms.remove(term)
    return terms

def comb_function_expansion(func_TRUE, func_DC, do_log=False):
    """
    determines the maximum legal region for each term in the K-map function 

    Arguments:
        func_TRUE: list containing the terms for which the output is '1'
        func_DC: list containing the terms for which the output is 'x' 
    Return:
        a list of terms: expanded terms in form of boolean literals
    """
    
    n = get_num_literals(func_TRUE, func_DC)
    print(f'N = {n}')
    true_terms = [str2bin(s, n) for s in func_TRUE]
    dc_terms = [str2bin(s, n) for s in func_DC]
    literals = true_terms + dc_terms

    #print(literals)


    # now, reduce all the literals sequentially using quine-mccluskey
    # will take O(n^2) at each step.

    term_graph = {}
    s_time = time.time()
    for t in range(n+1):
        s_time = time.time()

        paired_literals = combinations(literals,2)
        # print(list(paired_literals))
        term_graph = {**{k: set() for k in literals}, **term_graph}
        
        print(f"1 {time.time() - s_time}")
        s_time = time.time()
        literals = []
        i = 0
        for (l1,l2) in paired_literals:
            i+=1
            l = combine(l1,l2)
            if l:
                term_graph[l1].add(l)
                term_graph[l2].add(l)

                literals.append(l)

        print(i)
        print(f"2 {time.time() - s_time}")
        s_time = time.time()
        literals = filter_list(literals)

        print(f"3 {time.time() - s_time}")
        print(f"Current length of literals:- {len(literals)}")
    # print(term_graph)

    # Now, make the grid with the true literals and get the reverse mapping.

    maximal_regions = []

    for i,term in enumerate(true_terms):
        print()
        print(f'Current term expansion: {bin2str(term)}')
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

        print(f'Next Legal Terms for Expansion: ', end='')
        for t in get_expansion_terms(term, maximal_regions[-1]):
            print(f'{bin2str(t)}', end=' ')
        print()
        print(f"Expanded term: {bin2str(maximal_regions[-1])}")

    return maximal_regions


# CODE FROM ASSIGNMENT - 2
#######################

def sort_terms(terms):
    '''
    to sort the maximal terms based on their lengths
    '''
    terms.sort(lambda x,y: cmp(len(x), len(y)))


def can_be_contained(terms, i):
    '''
    will check whether ith term can be contained in terms from index 0 - (i-1)
    '''


def contains(term1, term2):

    for i in range(0, len(term1)):
        if term1[i] != term2[i] and term1[i] != '-':
            return False

    return True


def opt_function_reduce(func_TRUE, func_DC):
    """
    determines the minimum number of sum of product terms for the given K-map function Arguments:
    func_TRUE: list containing the terms for which the output is '1'
    func_DC: list containing the terms for which the output is 'x' Return:
                     a list of minimum size containing terms:  terms in form of boolean literals
    """

    # TODO implement
    n = get_num_literals(func_TRUE, func_DC)
    maximal_terms = comb_function_expansion(func_TRUE, func_DC, do_log=False)
    

    table = {}
    for max_term in maximal_terms:
        for true_term in str2bin(func_TRUE, n):
            if contains(max_term, true_term):
                table[(max_term, true_term)] = True
            else:
                table[(max_term, true_term)] = False

    ## finding essential prime implicants


    essential_prime_implicants = []

    for true_term in str2bin(func_TRUE, n):
        count = 0
        for max_term in maximal_terms:
            if table[(max_term, true_term)] == True:
                count += 1
        if count == 1:
            essential_prime_implicants.append(max_term)

    terms_covered_count = 0

    covered = {}

    for epi in essential_prime_implicants:
        for true_term in str2bin(func_TRUE, n):
            if table[(max_term, true_term)] == True:
                covered[true_term] = True

    for true_term in str2bin(func_TRUE, n):
        if not true_term in covered.keys():
            ## I DON'T SEE ANY OPTION OTHER THAN HIT AND TRIAL AT THIS POINT OF TIME 


    
    pass

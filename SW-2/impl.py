import itertools
import math
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
    original_terms = {}
    
    n = get_num_literals(func_TRUE, func_DC)
    print(f'N = {n}')
    true_terms = [str2bin(s, n) for s in func_TRUE]
    dc_terms = [str2bin(s, n) for s in func_DC]
    literals = [true_terms + dc_terms]
    #print(literals)

    for term in true_terms:
        original_terms[''.join(term)] = [term]
    for term in dc_terms:
        original_terms[''.join(term)] = [term] 


    # now, reduce all the literals sequentially using quine-mccluskey
    # will take O(n^2) at each step.

    term_graph = {}

    for t in range(n+1):

        paired_literals = combinations(literals[-1],2)
        # print(list(paired_literals))
        term_graph = {**{k: set() for k in literals[-1]}, **term_graph}
        literals.append([])
        for (l1,l2) in paired_literals:
            if can_combine(l1,l2):
                # print(f"Combining {l1} and {l2}")
                l = combine(l1, l2)
                term_graph[l1].add(l)
                term_graph[l2].add(l)

                literals[-1].append(l)

        literals[-1] = filter_list(literals[-1])

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

    return [bin2str(t) for t in maximal_regions]

if __name__ == '__main__':

    # TEST CASES OF SIZE 5
    # GIVEN IN PDF
    print(comb_function_expansion(["a'b'c'd'e'", "a'b'cd'e", "a'b'cde'", "a'bc'd'e'", "a'bc'd'e", "a'bc'de", "a'bc'de'", "ab'c'd'e'", "ab'cd'e'"], ["abc'd'e'", "abc'd'e", "abc'de", "abc'de'"]))

    
    # print(comb_function_expansion(["a'bc'd'e", "a'bc'de", "a'bcde'", "abcde'", "a'b'cd'e'"], ["a'bc'de'", "a'bcd'e'", "a'bcd'e'", "ab'cd'e'"]))

    # TEST CASES SIZE 4
    # GIVEN IN PDF
    # print(comb_function_expansion(["a'bc'd'", "abc'd'", "a'b'c'd", "a'bc'd", "a'b'cd"], ["abc'd"]))

    # print(comb_function_expansion(["a'b'c'd", "a'bc'd", "a'b'cd'", "ab'c'd"], ["abc'd", "ab'c'd'", "ab'cd", "ab'cd'"]))
    # print(comb_function_expansion(["a'b'c'd", "a'bc'd", "abc'd", "ab'c'd"], ["a'b'c'd'", "a'bc'd'", "a'bcd", "a'bcd'"]))

    # TEST CASES SIZE 3
    
    # print(comb_function_expansion(["abc", "a'bc'", "ab'c"], ["ab'c'"]))
    # print(comb_function_expansion(["ab'", "ab"], ["a'b'"]))
    # print(comb_function_expansion(["a'b'"], []))
    # print(comb_function_expansion(["a'b'", "ab"], []))
    print(comb_function_expansion(["a'b'", "a'b", "ab'", "ab"], []))


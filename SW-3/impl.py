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
    # print(f'N = {n}')
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
        
        # print(f"1 {time.time() - s_time}")
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

        # print(i)
        # print(f"2 {time.time() - s_time}")
        s_time = time.time()
        literals = filter_list(literals)

        # print(f"3 {time.time() - s_time}")
        # print(f"Current length of literals:- {len(literals)}")
    # print(term_graph)

    # Now, make the grid with the true literals and get the reverse mapping.

    maximal_regions = []

    visited = dict.fromkeys(term_graph.keys(), False)
    for term in true_terms:
        q = [term]
        while q:
            t = q.pop(0)
            if not term_graph[t]:
                # maximal region 
                maximal_regions.append(t)
            for c in term_graph[t]:
                if not visited[c]:
                    visited[c] = True
                    q.append(c)

    return maximal_regions

# CODE FROM ASSIGNMENT - 2
#######################

def contains(outer_term, inner_term):

    for i in range(0, len(outer_term)):
        if outer_term[i] != inner_term[i] and outer_term[i] != '-':
            return False

    return True


def opt_function_reduce(func_TRUE, func_DC):
    """
    determines the minimum number of sum of product terms for the given K-map function Arguments:
    func_TRUE: list containing the terms for which the output is '1'
    func_DC: list containing the terms for which the output is 'x' Return:
                     a list of minimum size containing terms:  terms in form of boolean literals
    """

    n = get_num_literals(func_TRUE, func_DC)
    # TODO rejig comb_function_expansion to return all pi's
    maximal_terms = set(comb_function_expansion(func_TRUE, func_DC, do_log=False))
    bin_true_terms = [str2bin(f, n) for f in func_TRUE]
    # maximal_bin_true_terms = 
    # print(bin_true_terms)
    # print(f"Maximal regions: {[bin2str(f) for f in maximal_terms]}")
    
    table = {}
    for max_term in maximal_terms:
        for true_term in bin_true_terms:
            if contains(max_term, true_term):
                table[(max_term, true_term)] = True
            else:
                table[(max_term, true_term)] = False

    ## finding essential prime implicants


    essential_prime_implicants = set()
    all_prime_implicants = set(maximal_terms)

    for true_term in bin_true_terms:
        count = 0
        epi = None
        for max_term in maximal_terms:
            if table[(max_term, true_term)] == True:
                count += 1
                epi = max_term
        if count == 1:
            essential_prime_implicants.add(epi)

    terms_covered_count = 0

    covered = set()

    for epi in essential_prime_implicants:
        for true_term in bin_true_terms:
            if table[(epi, true_term)] == True:
                covered.add(true_term)

    # print(f"Covered so far: {covered}")
    # print(f"EPI's so far: {essential_prime_implicants}")
    # print()

    uncovered_terms = set(bin_true_terms).difference(covered)

    # bruteforce will generate a powerset of the leftover prime implicants, and 
    # then go over them in a sorted manner to see which is the smallest 
    # powerset that includes all the leftover terms.

    uncovered_prime_implicants = all_prime_implicants.difference(essential_prime_implicants)

    for pi_set in powerset(uncovered_prime_implicants):
        covered_len = 0
        for term in uncovered_terms:
            for pi in pi_set:
                if contains(pi, term):
                    covered_len += 1
        if covered_len == len(uncovered_terms):
            # break, as we've found the set of PI's that covers all the leftover
            # ones 
            for pi in pi_set:
                essential_prime_implicants.add(pi)
            break


    # for i, true_term in enumerate(bin_true_terms):
    #     print(f"Term {i+1}: {bin2str(true_term)}")
    #     for epi in essential_prime_implicants:
    #         if contains(epi, true_term):
    #             print(f"Covering region: {bin2str(epi)}")
    #     print()
    # deleted_terms = []

    deleted_terms = []
    for term in maximal_terms:
        if not term in essential_prime_implicants:
            deleted_terms.append(term)

    # print(f"Deleted terms are :- {deleted_terms}")

    for dt in deleted_terms:
        print(f"The covering region/term to be deleted {bin2str(dt)}")
        counter = 1
        for true_term in bin_true_terms:
            if contains(dt, true_term):
                print(f"Term {counter}: {bin2str(true_term)} lies in this region")
                counter += 1
    return [bin2str(a) for a in essential_prime_implicants]

if __name__ == "__main__":

    # SAMPLE TEST CASE 1
    # func_TRUE = ["a'bc'd'", "abc'd'", "a'b'c'd", "a'bc'd", "a'b'cd"]
    # func_DC = ["abc'd"]


    # SAMPLE TEST CASE 2
    # func_TRUE = ["a'b'c'd", "a'b'cd", "a'bc'd", "abc'd'", "abc'd", "ab'c'd'", "ab'cd"] 
    # func_DC = ["a'bc'd'", "a'bcd", "ab'c'd"]


    # SAMPLE TEST CASE 3

    # func_TRUE = ["a'b'c", "a'bc", "a'bc'", "ab'c'"]
    # func_DC = ["abc'"]

    # SAMPLE TEST CASE 4

    # func_TRUE = ["a'b'c'd'e'", "a'bc'd'e'", "abc'd'e'", "ab'c'd'e'", "abc'de'", "abcde'",
    # "a'bcde'", "a'bcd'e'", "abcd'e'", "a'bc'de", "abc'de", "abcde",
    # "a'bcde", "a'bcd'e", "abcd'e", "a'b'cd'e", "ab'cd'e"]
    # func_DC = []


    # SIZE 6

    # func_TRUE = ["abcdef", "a'bcdef", "ab'cdef", "a'b'cdef", "abc'd'ef", "abc'def", "abcd'ef"]
    # func_DC   = ["ab'c'def", "a'b'c'd'e'f'"]


    # SIZE 8


    # func_TRUE = ["a'b'c'd'e'fgh", "a'bc'd'e'fgh", "abc'd'e'fgh", "ab'c'd'e'fgh", "abc'de'fgh", "abcde'fgh",
    # "a'bcde'fgh", "a'bcd'e'fgh", "abcd'e'fgh", "a'bc'defgh", "abc'defgh", "abcdefgh",
    # "a'bcdefgh", "a'bcd'efgh", "abcd'efgh", "a'b'cd'efgh", "ab'cd'efgh"]
    # func_DC = ["a'b'c'd'e'fg'h", "a'bc'd'e'f'gh", "abc'd'e'f'g'h'", "ab'c'd'e'fg'h'"]    




    # SIZE 10

    # func_TRUE = ["abc'defghij", "abc'd'efghij", "abc'defg'h'ij", "ab'c'd'efg'hij", "ab'cdefgh'ij"] 
    # func_DC = ["a'b'c'defgh'ij", "a'b'cdefghi'j", "abc'd'e'fghij", "abc'de'fghij", "abc'de'f'ghij", "abc'def'ghij", "ab'c'd'e'fg'hij", "ab'cd'efg'hij", "ab'cd'e'fg'hij", "a'bcdefgh'ij", "a'b'cdefgh'ij", "abcdefgh'ij"]

    # SIZE 15

    func_TRUE = ["a'bc'defgh'i'jklm", "a'bc'defgh'i'jkl'm'", "a'bc'defgh'i'jk'l'm", "a'bc'defgh'i'jk'l'm'", "a'bc'defgh'i'jk'lm'", "a'bc'defgh'i'jk'lm", "a'bc'defgh'i'jkl'm", "a'bc'defgh'i'jklm'", "a'bc'defgh'ijklm", "a'bc'defghi'jklm", "a'bc'defghijklm"] 
    func_DC = ["a'bc'de'fg'h'ijklm", "a'bc'de'fghi'jklm", "a'bc'defg'hijklm", "a'bc'd'efgh'ijklm'", "a'bc'defghi'jklm'", "a'b'c'defghij'klm'"]


    print(opt_function_reduce(func_TRUE, func_DC))

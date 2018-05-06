import collections
import functools
import heapq
import math
import re
import sys
from fractions       import gcd
from fractions       import Fraction
from multiprocessing import Pool    
from operator        import itemgetter

class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

def doit(fn=None,multi=False) :
    IN = myin(fn)
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    if (not multi) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            printOutput(tt,ans)
    else :
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)

#####################################################################################################

def getInputs(IN) :
    l = int(IN.input())
    lines = [ tuple(IN.input().rstrip().lstrip().split()) for i in range(l) ]
    a = int(IN.input())
    animals = [ tuple(IN.strs()) for i in range(a) ]
    return (l,lines,a,animals)

def solve(inp) :
    (l,lines,a,animals) = inp
    tokens = []
    for s in lines:
        for ss in s :
            t = tokenize(ss)
            tokens.extend(t)
    tr,_ = parseTree(tokens,0)
    ans = []
    for animal in animals :
        lans = evalAnimal(tr,animal, 1.0)
        ans.append( "%.8f" % lans)
    return ans

def printOutput(tt,ans) :
    print("Case #%d:" % tt)
    for a in ans : print(a)

def tokenize(s) :
    prefix,suffix = [],[]
    ## Take off any prefix characters
    i = 0
    while i < len(s) and s[i] == "(" : prefix.append('('); i += 1
    if i == len(s) : return prefix
    j = len(s) - 1
    while j >= 0 and s[j] == ")" : suffix.append(')'); j -= 1
    if i > j : return prefix + suffix
    return prefix + [s[i:j+1]] + suffix

def parseTree(tokens,idx) :
    assert tokens[idx] == "("
    weight = float(tokens[idx+1])
    if tokens[idx+2] == ")" : return [weight],idx+2
    attribute = tokens[idx+2]
    dt1,i1 = parseTree(tokens,idx+3)
    dt2,i2 = parseTree(tokens,i1+1)
    assert tokens[i2+1] == ")"
    return [weight, attribute, dt1, dt2],i2+1

def evalAnimal(dtree,animal, p) :
    p *= dtree[0]
    if len(dtree) == 1 : return p
    else :
        trait = dtree[1]
        if trait in animal[2:] : p = evalAnimal(dtree[2], animal, p)
        else                   : p = evalAnimal(dtree[3], animal, p)
        return p

#####################################################################################################
if __name__ == "__main__" :
    doit()

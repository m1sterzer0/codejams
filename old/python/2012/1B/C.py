import collections
import functools
import heapq
import itertools
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
    s = list(IN.ints())
    n = s.pop(0)
    return (n,s)

def solve(inp) :
    (n,s) = inp
    if n == 20 : ans1,ans2 = solveBruteForce(n,s)
    else       : ans1,ans2 = solveRandom(n,s)
    return (ans1,ans2)

def printOutput(tt,ans) :
    (ans1,ans2) = ans
    print("Case #%d:" % (tt,))
    print(" ".join(str(x) for x in ans1))
    print(" ".join(str(x) for x in ans2))

from itertools import combinations
def solveBruteForce(n,s) :
    d = {}
    for size in range(1,n+1) :
        cc = list(combinations(s,size))
        sums = [sum(x) for x in cc]
        for ss,c in zip(sums,cc) :
            if ss in d : return c,d[ss]
            else       : d[ss] = c

import random
random.seed(1)
def solveRandom(n,s) :
    d = {}
    while(True) :
        c = tuple(random.sample(s,6))
        ss = sum(c)
        if ss in d : return c,d[ss]
        else       : d[ss] = c

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)
    
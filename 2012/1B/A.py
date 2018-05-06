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
    ans = [ "%.8f" % solvecase(i,n,s) for i in range(n) ]
    return " ".join(ans)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def eval(m,i,x,n,s) :
    target = s[i] + m*x
    scores = sum(0 if ss > target else target - ss for ss in s) - m*x
    return scores > (1-m)*x 

def solvecase(i,n,s) :
    a,b = 0,1
    x = sum(s)
    while (b-a) > 1e-8 :
        m = 0.5*(a+b)
        if eval(m,i,x,n,s) : a,b = a,m
        else             : a,b = m,b
    return 100.0 * 0.5 * (a+b)

#####################################################################################################
if __name__ == "__main__" :
    doit()

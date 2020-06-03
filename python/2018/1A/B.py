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
    r,b,c = IN.ints()
    cashiers = [0] * c
    for i in range(c) :
        mi,si,pi = IN.ints()
        cashiers[i] = (mi,si,pi)
    return (r,b,c,cashiers)

def solve(inp) :
    (r,b,c,cashiers) = inp
    left,right = 0,2000000000000000000
    while (right-left) > 1 :
        m = (right+left) // 2
        if evalCashiers(cashiers,m,r,b) : right = m
        else :                            left = m
    return "%d" % right

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def coins(c,t) :
    (m,s,p) = c
    if p > t : return 0
    maxt = p + s * m
    if t >= maxt : return m
    return (t - p) // s

def evalCashiers(cashiers,t,r,b) :
    coinsPerCashier = [coins(cashiers[i],t) for i in range(len(cashiers))]
    coinsPerCashier.sort(reverse=True)
    return True if sum(coinsPerCashier[:r]) >= b else False

#####################################################################################################
if __name__ == "__main__" :
    doit()

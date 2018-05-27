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

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    naomi = list(IN.floats())
    ken   = list(IN.floats())
    return (n,naomi,ken)

def solve(inp) :
    (n,naomi,ken) = inp
    naomi.sort()
    ken.sort()
    fairWar = doFairWar(n,naomi,ken)
    deceitfulWar = doDeceitfulWar(n,naomi,ken)
    return "%d %d" % (deceitfulWar, fairWar)

## For the Deceitful war, you clearly bleed out your opponents top pieces with your bottom pieces
## For the Regular war, playing your boards from bottom to top seems to be the best you can do. 

def doFairWar(n,naomi,ken) :
    score = 0
    idxk = 0
    for i in range(n) :
        while (idxk < n and ken[idxk] < naomi[i]) : idxk += 1
        if idxk >= n : score += 1
        idxk += 1
    return score

def doDeceitfulWar(n,naomi,ken) :
    score = 0
    idxk = 0
    for i in range(n) :
        if naomi[i] > ken[idxk] :
            score += 1
            idxk += 1
    return score

#####################################################################################################
if __name__ == "__main__" :
    doit()


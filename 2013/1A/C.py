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
    print("Case #%d:" % tt)
    for l in ans : print(l)

def getInputs(IN) :
    r,n,m,k = IN.ints()
    prods = [ list(IN.ints()) for x in range(r) ]
    return (r,n,m,k,prods)

## The heuristics for the large case seem flakey at best
## We'll go for the full out Bayes theorem decomp
def solve(inp) :
    (r,n,m,k,prods) = inp
    cases = list(itertools.combinations_with_replacement(list(range(2,m+1)),n))
    #print("Cases Enumerated",file=sys.stderr)
    probCases = {}
    oneOverTotalCases = 1.0 / (m-1)**n
    for c in cases : probCases[c] = probCase(c,n,oneOverTotalCases) 
    #print("Case Probabilities Calculated",file=sys.stderr)
    pdict = {}
    for c in cases : pdict[c] = genSubsetProbabilities(c)
    #print("Subset Probabilities Calculated",file=sys.stderr)
    multi = True if r > 1000 else False
    localInputs = [ (cases,probCases,pdict,p) for p in prods ]
    if not multi : ans = map(solveCase, localInputs)
    else  :
        with Pool(processes=32) as pool : ans = pool.map(solveCase,localInputs)
    return ans

def solveCase(inp):
    (cases,probCases,pdict,p) = inp
    lprob = probCases.copy()
    casesRemaining = cases.copy()
    for x in p :
        casesRemaining = [ c for c in casesRemaining if x in pdict[c] ]
        prob_x = math.fsum(lprob[c] * pdict[c][x] for c in casesRemaining)
        oneOverProbx = 1.0 / prob_x
        for c in casesRemaining : lprob[c] *= pdict[c][x] * oneOverProbx
    bestval = max([lprob[c] for c in casesRemaining])
    for c in casesRemaining :
        if lprob[c] == bestval : return "".join(str(x) for x in c)
 
def probCase(c,n,oneOverTotal) :
    count = 1
    subcount = 1; last = c[0]
    for x in c[1:] :
        if last == x : subcount += 1
        else :
            count *= choose(n,subcount); n -= subcount; last = x; subcount = 1
    return count * oneOverTotal

def genSubsetProbabilities(case) :
    p = {}
    p[1] = 1.0
    for c in case :
        p2 = {}
        for x in p :
            cx = c* x
            halfpx = 0.5 * p[x]
            if x not in p2 : p2[x]    = halfpx
            else           : p2[x]   += halfpx
            if cx not in p2 : p2[cx]  = halfpx
            else            : p2[cx] += halfpx
        p = p2
    return p

def choose(n, k):
    if k < 0 or k > n : return 0
    num,denom = 1,1
    if n-k < k : k = n-k
    for t in range(1, k+1) :
        num *= n; n -= 1
        denom *= t
    return num // denom
    
#####################################################################################################
if __name__ == "__main__" :
    doit()


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
    a1,a2,b1,b2 = IN.ints()
    return (a1,a2,b1,b2)

## When do we actually win?  When is A,B a winning position? (assume A > B)
## We see that (x,x) is losing, and that (kx+c,x) is winning for k>=2 (c>=0,x>0) by a forked-move argument (i.e. assigning (c,x) to either us or opponent via a forced move)
## Otherwise, we are forced to play (B,A-B) and hope for the best.  Here is how the game plays out:
## Round1: (A,B)         is a winning position if       A >= 2(B)     --> A/B >= 2,    otherwise play (B,A-B) 
## Round2: (B,A-B)       is a winning position if       B >= 2(A-B)   --> A/B <= 3/2,  otherwise play (A-B,2B-A)
## Round3: (A-B,2B-A)    is a winning position if   (A-B) >= 2(2B-A)  --> A/B >= 5/3,  otherwise play (2B-A,2A-3B)
## Round4: (2B-A,2A-3B)  is a winning position if  (2B-A) >= 2(2A-3B) --> A/B <= 8/5,  otherwise play (2A-3B,5B-3A)
## Round5: (2A-3B,5B-3A) is a winning position if (2A-3B) >= 2(5B-3A) --> A/B >= 13/8, otherwise play (5B-3A,5A-8B)
## Round6: (5B-3A,5A-8B) is a winning position if (5B-3A) >= 2(5A-8B) --> A/B <= 21/13, ...
## Clearly the A/B comparison numbers are ratios of consecutive fibonnaci terms.  This sequence is alternates around its limit
## and it appears that just checking if A/B is >= the golden ratio is good enough
def solve(inp) :
    (a1,a2,b1,b2) = inp
    ans = 0
    goldenRatio = 0.5 * (1 + math.sqrt(5))
    oneOverGoldenRatio = 1.0/goldenRatio
    arr = [(math.floor(oneOverGoldenRatio*x),math.ceil(goldenRatio*x)) for x in range(a1,a2+1)]
    for amin,amax in arr :
        if amax   <= b1 : ans += (b2-b1+1)
        elif amax <= b2 : ans += (b2-amax+1)
        if amin >= b2   : ans += (b2-b1+1)
        elif amin >= b1 : ans += (amin-b1+1)
    return "%d" % ans 

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)


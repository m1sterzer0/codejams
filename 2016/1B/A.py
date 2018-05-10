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
    s = IN.input().rstrip()
    return (s,)

## Ordered Passes
## Z: ZERO
## W: TWO
## U: FOUR
## X: SIX
## G: EIGHT
## =========
## O: ONE
## H: THREE
## F: FIVE
## S: SEVEN
## =========
## N: NINE

def solve(inp) :
    (s,) = inp
    d = collections.defaultdict(lambda: 0)
    for c in s : d[c] += 1
    ans = []
    searchTuples = [ ('Z','0',"ZERO"),
                     ('W','2',"TWO"),
                     ('U','4',"FOUR"),
                     ('X','6',"SIX"),
                     ('G','8',"EIGHT"),
                     ('O','1',"ONE"),
                     ('H','3',"THREE"),
                     ('F','5',"FIVE"),
                     ('S','7',"SEVEN"),
                     ('I','9',"NINE") ]
    for (c,dig,lets) in searchTuples :
        if d[c] == 0 : continue
        n = d[c]
        for i in range(n) : ans.append(dig)
        for cc in lets : d[cc] -= n
    ans.sort()
    return "".join(ans)

#####################################################################################################
if __name__ == "__main__" :
    doit()

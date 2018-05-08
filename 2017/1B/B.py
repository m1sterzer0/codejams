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
    n,r,o,y,g,b,v = IN.ints()
    return (n,r,o,y,g,b,v)

def solve(inp) :
    (n,r,o,y,g,b,v) = inp

    ## Check for the special case of only 1 blended color and its opposite
    if o == y == b == v == 0 and r == g : return "RG" * r
    if r == o == g == b == 0 and y == v : return "YV" * y
    if r == y == g == v == 0 and b == 0 : return "BO" * b

    if o > 0 and b <= o : return "IMPOSSIBLE"
    if g > 0 and r <= g : return "IMPOSSIBLE"
    if v > 0 and y <= v : return "IMPOSSIBLE"

    (newr,newy,newb) = (r-g, y-v, b-o)
    x = [(newr,'R'),(newy,'Y'),(newb,'B')]
    x.sort(reverse=True)

    if x[0][0] > x[1][0] + x[2][0] : return "IMPOSSIBLE"
    ans = solvePure(x)
    if g > 0 : ans = ans.replace("R", "RG" * g + "R",1)
    if v > 0 : ans = ans.replace("Y", "YV" * v + "Y",1)
    if o > 0 : ans = ans.replace("B", "BO" * o + "B",1)
    return ans

def solvePure(a) :
    ## Assume v1 >= v2 and v2 >= v3 with v1 <= v2 + v3
    v1,v2,v3 = (x[0] for x in a)
    c1,c2,c3 = (x[1] for x in a)
    ans = []
    while (v1 > 0) :
        if v1 == v2 == v3 : break
        ans.append(c1); v1 -= 1
        if v1 == v2 == v3 : break
        if v2 >= v3 : ans.append(c2); v2 -= 1
        else        : ans.append(c3); v3 -= 1
    if len(ans) > 0 and ans[-1] == ans[0]:
        for i in range(v1) : ans.append(c2); ans.append(c1); ans.append(c3)
    else :
        for i in range(v1) : ans.append(c1); ans.append(c2); ans.append(c3)
    return "".join(ans)

#####################################################################################################
if __name__ == "__main__" :
    doit()

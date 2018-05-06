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

def nCr(n,r) :
    f = math.factorial
    return f(n) // f(r) // f(n-r)

def p(c,n,missing,found) :
    # ( missing ) ( c - missing )
    # ( found   ) ( n - found   )
    # ----------------------------
    #        ( c )
    #        ( n )
    if found < 0 : return 0
    if found > missing : return 0
    if n - found < 0 : return 0
    if n - found > c - missing : return 0
    return 1.0 * nCr(missing,found) * nCr(c-missing,n - found) / nCr(c,n)

def getInputs(IN) :
    c,n = IN.ints()
    return (c,n)

def solve(inp) :
    (c,n) = inp
    e = [0] * (c+1)
    for missing in range(1,c+1) :
        num = 1
        for found in range(1,missing) :
            num += p(c,n,missing,found) * e[missing-found]
        denom = 1.0 - p(c,n,missing,0)
        e[missing] = num / denom
    return "%.8f" % e[c]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()


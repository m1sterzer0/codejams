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

anscache = {}
def presolve() :
    anscache[1] = 1
    for i in range(1,15) :
        n = 10 ** i
        locsolve(n-1)
        anscache[n] = anscache[n-1]+1

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    return (n,)

def solve(inp) :
    (n,) = inp
    res = locsolve(n)
    return "%d" % res

def locsolve(n) :
    if n <= 20 : anscache[n] = n
    if n not in anscache :
        x,numdig = 10,1
        while n >= x : x *= 10; numdig += 1
        ans1 = anscache[10**(numdig-1)] + (n - 10**(numdig-1))
        sn = str(n)
        sleft = sn[:numdig//2]
        sright = sn[numdig//2:]
        if sleft == "1" + "0" * (len(sleft)-1) :
            anscache[n] = anscache[10**(numdig-1)] + myeval(sright)
        elif myeval(sright) == 0 :
            sleft = str(int(sleft)-1) ## Guaranteed to be the same number of digits, given the case above
            anscache[n] = min(ans1,anscache[10**(numdig-1)] + myeval(sleft[::-1]) + 10**(len(sright)))
        else :
            anscache[n] = anscache[10**(numdig-1)] + myeval(sleft[::-1]) + myeval(sright)
    return anscache[n]

def myeval(s) :
    v = 0
    for c in s : v = 10 * v + int(c)
    return v

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()

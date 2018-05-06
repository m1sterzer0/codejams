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
    n,l = IN.ints()
    c = tuple(IN.ints())
    return (n,l,c)

def solve(inp) :
    (n,l,c) = inp
    numLeft = n - sum(c)
    soloRemainder = 100 % n
    remainders = [ (100 * x) % n for x in c ]

    if soloRemainder == 0 : return "100"
    if 2 * soloRemainder >= n :
        percentage = 0
        for cc,r in zip(c,remainders) :
            if 2 * r >= n : percentage += (100*cc // n) + 1
            else          : percentage += (100*cc // n)
        percentage += numLeft * (100 // n + 1)
        return "%d" % percentage

    percentage = 0
    candidates = []
    for cc,r in zip(c,remainders) :
        if 2 * r >= n :  percentage += (100*cc // n) + 1
        elif r == 0 :    percentage += 100*cc // n
        else :           candidates.append((r,cc))
    
    candidates.sort(reverse=True)
    neededExtras = [ math.ceil( (n-2*r)/(2*soloRemainder) ) for r,cc in candidates ]
    for x,(r,cc) in zip(neededExtras,candidates) :
        if numLeft >= x :
            numLeft -= x
            percentage += 100 * (cc + x) // n + 1
        else :
            percentage += 100 * cc // n

    soloNeed = math.ceil( n / (2 * soloRemainder) )
    while (numLeft >= soloNeed) :
        numLeft -= soloNeed
        percentage += soloNeed * 100 // n + 1
    percentage += numLeft * 100 // n
    return "%d" % percentage

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()


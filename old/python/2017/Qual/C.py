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
    n,k = IN.ints()
    return (n,k)

def solve(inp) :
    (n,k) = inp
    ## Do full tiers
    amts = [n,n+1]
    cnts = [1,0]
    tiercnt = 1
    while k > tiercnt :
        ## two cases, amt[0] is even, and amt[0] is odd
        if amts[0] % 2 == 0 :
            newamt1 = amts[0]//2 - 1
            newamt2 = newamt1 + 1
            newcnt1 = cnts[0]
            newcnt2 = cnts[0] + 2 * cnts[1]
            amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
        else :
            newamt1 = amts[0]//2
            newamt2 = newamt1 + 1
            newcnt1 = 2 * cnts[0] + cnts[1]
            newcnt2 = cnts[1]
            amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
        k -= tiercnt
        tiercnt *= 2

    mymin,mymax = 0,0        
    if k <= cnts[1] :
        mymin = (amts[1]-1)//2; mymax = amts[1] - 1 - mymin
    else :
        mymin = (amts[0]-1)//2; mymax = amts[0] - 1 - mymin
    return "%d %d" % (mymax,mymin)

#####################################################################################################
if __name__ == "__main__" :
    doit()


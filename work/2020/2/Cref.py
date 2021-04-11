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
    print("Case #%d: %d" % (tt,ans))

def getInputs(IN) :
    N, = IN.ints()
    X = [0] * N
    Y = [0] * N
    for i in range(N) :
        X[i],Y[i] = IN.ints()
    return (N,X,Y)

def solve(inp) :
    (N,X,Y) = inp
    points = list(zip(X,Y))
    if N == 1 : return 1

    ## We can chain all lines with an even number of points together
    ## We can chain pairs of odd lines
    ## THUS: 
    ##    two singletons + all even + even number of pairs of odd
    ##    one singletons + all even + odd number of lines of odd
    ## CONCLUSION:
    ##    Take all of the connected points for a slope
    ##    Add up to 1 if the total is odd
    ##    Add up to 2 if the total is even
    fracs = {}
    for i in range(N) :
        for j in range(N) :
            if i == j : continue
            f = reduceDir(points[i],points[j])
            if f not in fracs : fracs[f] = set()
            fracs[f].add(i)
    
    connected = [len(x) for x in fracs.values()]
    maxconnected = max(connected)
    if    maxconnected % 2 == 0 and maxconnected + 2 <= N : return maxconnected+2
    elif  maxconnected + 1 <= N : return maxconnected+1
    return maxconnected


def reduceDir(p1,p2) :
    c1 = p2[0] - p1[0]
    c2 = p2[1] - p1[1]
    if c1 < 0 : c1 = -c1; c2 = -c2
    if c2 == 0 : return (1,0)
    if c1 == 0 : return (0,1)
    g = math.gcd(c1,c2)
    return (c1//g,c2//g)


#####################################################################################################
if __name__ == "__main__" :
    doit()


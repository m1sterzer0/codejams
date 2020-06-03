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
shells = []
def presolve() :
    shells.append(1)
    inc = 5
    while shells[-1] < 1000000 :
        x = shells[-1] + inc
        shells.append(x) 
        inc += 4

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n,x,y = IN.ints()
    return (n,x,y)

import bisect
def solve(inp) :
    (n,x,y) = inp
    if n == 1 : ans = 1.0 if (x,y) == (0,0) else 0.0
    else :
        if x < 0 : x = -x
        shell = (x+y) // 2
        nshell = bisect.bisect_left(shells,n)
        if shell > nshell : ans = 0.0                                ## Our (x,y) is outside the current shell
        elif shell < nshell : ans =  1.00                            ## Our (x,y) is inside the current shell
        else :
            totalInShell = shells[shell] - shells[shell-1]
            numLeft = n - shells[shell-1]
            if numLeft == totalInShell : ans =  1.00                 ## We have exactly enough to complete our full current shell
            elif x == 0 : ans =  0.00                                ## x == 0, and our shell isn't complete, so we won't get this one
            elif numLeft >= (totalInShell-1)//2 + (y+1) : ans = 1.0  ## Guaranteed to get to my point in the shell, even if the other side fully fills up first.
            else : ans = myprob((totalInShell-1),numLeft,y+1)
    return "%.8f" % ans

def myprob(n,numLeft,yp1) :
    denom = 2 ** numLeft
    num = 0
    for i in range(yp1,numLeft+1) : num += choose(numLeft,i)
    return 1.0 * num / denom

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
    presolve()
    doit()


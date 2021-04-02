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
    n,j = IN.ints()
    return (n,j)

def solve(inp) :
    (n,j) = inp
    ## We are greedy and only look for numbers that are divisible by primes <= 10000
    ## This will let some jamcoins slip through the cracks, but I think there are enough
    ## that this shouldn't be a problem.
    primes = list(sieve(10000))
    ans = []
    cand = 2**(n-1) - 1
    while len(ans) < j :
        cand += 2
        factors = []
        binstr = bin(cand)[2:]
        for base in range(2,11) :
            v = expand(binstr,base)
            f = findFactor(v,primes)
            if f < 0 : continue
            factors.append(f)
        if len(factors) < 9 : continue
        ansstr = binstr + ' ' + ' '.join([str(x) for x in factors])
        ans.append(ansstr)
    return ans

def expand(binstr,base) :
    ans = 0
    placeValue = 1
    for b in reversed(binstr) :
        if b == '1' : ans += placeValue
        placeValue *= base
    return ans

def findFactor(v,primes) :
    for p in primes :
        if p * p > v : return -1
        if v % p == 0 : return p
    return -1

def sieve(limit) :
    ll= limit+1
    a = [True] * ll
    a[0] = False
    a[1] = False
    a[2::2] = [False] * len(a[2::2])
    yield 2
    for i in range(3,ll,2) :
        if not a[i] : continue
        yield i
        a[i*i::2*i] = [False] * len(a[i*i::2*i])
    
#####################################################################################################
if __name__ == "__main__" :
    doit()


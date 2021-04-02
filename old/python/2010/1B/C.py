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

## The major recurrances
## 1) #(pure subsets of {2..n} with n pure) = sum_{i=1)^{n-1} #(pure subsets of {2..n} with n pure of order i)
## Let P(n,i) = # pure sets of {2..n} with n pure of order i
## Let C(n,r) = the number of combinations of n things taking r at a time
## 2) P(n,i) = sum_{k=1}^{i-1} P(i,k) * C(n-i-1,i-k-1)  ## C(n-i-1,i-k-1) represents the number of ways to choose the elements between n and i

maxn = 500
nCrdata = [[0] * (maxn+1) for x in range(maxn+1)]
dp      = [[0] * (maxn+1) for x in range(maxn+1)]
answers = [0] * (maxn+1)

def prepWork() :
    global nCrdata
    #nCr array
    for n in range(maxn+1) :
        for r in range(maxn+1) :
            if r > n : nCrdata[n][r] = 0
            elif n == r : nCrdata[n][r] = 1
            elif r == 0 : nCrdata[n][r] = 1
            else : nCrdata[n][r] = (nCrdata[n-1][r] + nCrdata[n-1][r-1]) % 100003
            #print("n:",n,"r:",r,"nCrdata[n][r]=",nCrdata[n][r])

    global dp
    for k in range(2,maxn+1) : dp[k][1] = 1
    for i in range(2,maxn) :
        for t in range(i+1,maxn+1) :
            for k in range(1,i) :
                dp[t][i] = (dp[t][i] + nCr(t-i-1,i-k-1) * dp[i][k]) % 100003


    global answers
    for n in range(2,maxn+1) :
        answers[n] = sum(dp[n][i] for i in range(1,n)) % 100003

def nCr(n,r) : return 0 if n < r else nCrdata[n][r]
    
def getInputs(IN) :
    return int(IN.input())

def solve(inp) :
    n = inp
    return "%d" % answers[n]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    prepWork()
    doit()

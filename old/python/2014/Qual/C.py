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
    print("Case #%d:" % (tt,))
    for l in ans : print(l)

def getInputs(IN) :
    (r,c,m) = IN.ints()
    return (r,c,m)

def solve(inp) :
    (r,c,m) = inp
    transposed = False
    if (r>c) : transposed = True; (r,c) = (c,r)
    impossible,ans = lsolve(r,c,m)
    if impossible : return ["Impossible"]
    if (not impossible and transposed) : ans = flipans(r,c,ans); (r,c) = (c,r)
    return [ "".join(x) for x in ans ]
    
def initSol(r,c) : return [ ['*'] * c for x in range(r) ]

def lsolve(r,c,m) :
    n = r*c
    ans = initSol(r,c)
    holesLeft = n-m

    ## Deal with the fail cases first
    if r == 2 and holesLeft > 1 and holesLeft % 2 == 1 : return True, None
    if r >= 2  and holesLeft in (2,3,5,7) : return True, None

    ## Deal with trivial pass cases first
    if m == 0 : ans = [ ['.'] * c for x in range(r) ]
    elif holesLeft == 1 : pass
    elif r == 1 :
        for i in range(holesLeft) :
            ans[0][i] = '.'

    elif r == 2 :
        for i  in range(holesLeft//2) :
            ans[0][i] = ans[1][i] = '.'

    elif holesLeft <= 3*c :
        i = 0
        while holesLeft > 4 :
            ans[0][i] = ans[1][i] = ans[2][i] = '.'
            holesLeft -= 3
            i += 1
        if holesLeft == 4 :  ans[0][i] = ans[1][i] = ans[0][i+1] = ans[1][i+1] = '.'
        elif holesLeft == 3: ans[0][i] = ans[1][i] = ans[2][i] = '.'
        else :               ans[0][i] = ans[1][i] = '.'

    else :
        ridx = 0
        while holesLeft >= c :
            for j in range(c) : ans[ridx][j] = '.'
            holesLeft -= c
            ridx += 1
        if holesLeft == 1 :
            ans[ridx][0] = ans[ridx][1] = '.'
            ans[ridx-1][c-1] = '*'
        else :
            for j in range(holesLeft) :
                ans[ridx][j] = '.' 

    ans[0][0] = 'c'
    return False,ans

def flipans(r,c,ans) :
    ans2 = initSol(c,r)
    for i in range(r) :
        for j in range(c) :
            ans2[j][i] = ans[i][j]
    return ans2

#####################################################################################################
if __name__ == "__main__" :
    doit()


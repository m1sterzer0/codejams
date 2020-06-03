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
    n = int(IN.input())
    board = [IN.input().rstrip() for x in range(n)]
    return n,board

def solve(inp) :
    (n,board) = inp
    numGames = [n - b.count('.') for b in board ]
    numWins  = [b.count('1') for b in board ]
    wp       = [ x/y for x,y in zip(numWins,numGames) ]
    owp      = [0] * n
    for i in range(n) :
        for j in range(n) :
            if board[i][j] == '1'   : owp[i] += numWins[j]/(numGames[j]-1)
            elif board[i][j] == '0' : owp[i] += (numWins[j]-1)/(numGames[j]-1)
        owp[i] /= numGames[i]

    oowp     = [0] * n
    for i in range(n) :
        for j in range(n) :
            if board[i][j] in '01' : oowp[i] += owp[j]
        oowp[i] /= numGames[i]

    rpi = [0.25 * x + 0.50 * y + 0.25 * z for x,y,z in zip(wp,owp,oowp)]
    return rpi

def printOutput(tt,ans) :
    print("Case #%d:" % (tt,))
    for a in ans : print("%.8f" % a)

#####################################################################################################
if __name__ == "__main__" :
    doit()

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
    n = int(IN.input())
    board = []
    for x in range(n) : board.append(list(IN.ints()))
    return (n,board)

def solve(inp) :
    (n,board) = inp
    spaces = set( (i,j) for i in range(n) for j in range(n) )
    lspaces = list(spaces)
    if boardFine(n,board,set()) : return str(0)
    for k in range(1,n*n) :
        for x in itertools.combinations(lspaces,k) : 
            if boardFine(n,board,set(x)) : return str(k)
    return str(n*n)

def boardFine(n,board,x) :
    ## Check rows
    for i in range(n) :
        values = set()
        for j in range(n) :
            if (i,j) in x : continue
            if board[i][j] in values : return False
            values.add(board[i][j])
        
    ## Check columns
    for j in range(n) :
        values = set()
        for i in range(n) :
            if (i,j) in x : continue
            if board[i][j] in values : return False
            values.add(board[i][j])

    return True

#####################################################################################################
if __name__ == "__main__" :
    doit()

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
    k, = IN.ints()
    w = 2*k-1
    board = [ [-1] * w for x in range(w) ]
    start = k-1
    for i in range(k):
        s = tuple(IN.ints())
        for x,n in enumerate(s) :
            board[i][start+2*x] = n
        start -= 1
    start += 2
    for i in range(k,2*k-1) :
        s = tuple(IN.ints())
        for x,n in enumerate(s) :
            board[i][start+2*x] = n
        start += 1
    #for i in range(w) : print(board[i])
    return (k,board)

def solve(inp) :
    (k,board) = inp
    htax = doHTax(k,board)
    board2 = transpose(k,board)
    vtax = doHTax(k,board2)
    newsize = k + htax + vtax
    ans = newsize*newsize-k*k
    return "%d" % ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def doHTax(k,board) :
    w = 2*k-1
    htax = k-1
    for i in range(1,w-1) :
        ltax = abs(k-i-1)
        if ltax >= htax : return htax
        symmetric = True
        i1,i2 = i-1,i+1
        while i1 >= 0 and i2 < w :
            for j in range(w) :
                if board[i1][j] >= 0 and board[i2][j] >= 0 and board[i1][j] != board[i2][j] : 
                    symmetric = False
                    break
            if symmetric == False : break
            i1 -= 1; i2 += 1
        if symmetric : htax = ltax
    return htax

def transpose(k,board) :
    w = 2*k-1
    board2 = [ [-1] * w for x in range(w) ]
    for i in range(w) :
        for j in range(w) :
            board2[i][j] = board[j][i]
    return board2    

#####################################################################################################
if __name__ == "__main__" :
    doit()

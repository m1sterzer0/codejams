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
    r,c = IN.ints()
    board = [ IN.input().rstrip() for x in range(r) ]
    return (r,c,board)
    
def solve(inp) :
    (r,c,board) = inp
    ans = 0
    for i in range(r) :
        for j in range(c) :
            if board[i][j] == '.' : continue
            up = trace(i,j,-1,0,r,c,board)
            dn = trace(i,j,1,0,r,c,board)
            left = trace(i,j,0,-1,r,c,board)
            right = trace(i,j,0,1,r,c,board)
            if board[i][j] == '^' and up : continue
            if board[i][j] == 'v' and dn : continue
            if board[i][j] == '>' and right : continue
            if board[i][j] == '<' and left : continue
            if not up and not dn and not left and not right : return "IMPOSSIBLE"
            ans += 1
    return "%d" % ans
 
def trace(i,j,di,dj,r,c,board) :
    while(True) :
        i += di; j += dj
        if i < 0 or i >= r or j < 0 or j >= c : return False
        if board[i][j] != '.' : return True
    return False

#####################################################################################################
if __name__ == "__main__" :
    doit()

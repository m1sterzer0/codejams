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
    r = int(IN.input())
    board = [ [False] * 101 for x in range(101)]
    for i in range(r) :
        x1,y1,x2,y2 = IN.ints()
        for x in range(x1,x2+1) :
            for y in range(y1,y2+1) :
                board[x][y] = True
    return board

def solve(inp) :
    board = inp 

    ans = 0; found = False
    for x in range(101) :
        for y in range(101) :
            if board[x][y] : found=True; break
        if found : break
    
    while found :
        ans += 1
        found = False
        newboard = [ [False] * 101 for x in range(101) ]
        for x in range(1,101) :
            for y in range(1,101) :
                if       board[x][y] and (board[x][y-1] or board[x-1][y]) : found = True; newboard[x][y] = True
                elif not board[x][y] and  board[x][y-1] and board[x-1][y] : found = True; newboard[x][y] = True
        board = newboard

    return "%d" % ans    

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

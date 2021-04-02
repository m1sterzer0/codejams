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
    n,k = IN.ints()
    board = [ list(IN.input().rstrip()) for x in range(n) ]
    return ((n,k,board))

def solve(inp) :
    (n,k,board) = inp
    shoveToRight(n,board)
    return checkForWin(board,n,k)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def shoveToRight(n,board) :
    for row in board :
        ## Count the number of entries
        prefix = row.count('.')
        sh = 0
        for i in range(n-1,-1,-1) :
            row[i+sh] = row[i]
            if row[i] == "." : sh += 1
        for i in range(prefix) : row[i] = "."

def checkForWin(board,n,k) :
    redpat,bluepat,redwin,bluewin = "R" * k, "B" * k, False, False
    for i in range(n) :
        for j in range(n) :
            trials = []
            if i + k <= n                 : trials.append("".join(board[i+x][j]   for x in range(k)))
            if j + k <= n                 : trials.append("".join(board[i][j+x]   for x in range(k)))
            if i + k <= n and j + k <= n  : trials.append("".join(board[i+x][j+x] for x in range(k)))
            if i + k <= n and j >= k-1    : trials.append("".join(board[i+x][j-x] for x in range(k)))
            for t in trials :
                if t == redpat :  redwin = True
                if t == bluepat : bluewin = True
    if   redwin and bluewin : return "Both"
    elif redwin             : return "Red"
    elif bluewin            : return "Blue"
    else                    : return "Neither"

#####################################################################################################
if __name__ == "__main__" :
    doit()

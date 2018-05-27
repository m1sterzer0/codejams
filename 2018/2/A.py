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
    if ans[0] == "IMPOSSIBLE" : print("Case #%d: %s" % (tt,"IMPOSSIBLE"))
    else :
        rows = len(ans)
        print("Case #%d: %d" % (tt,rows))
        for r in ans :
            print("".join(r))

def getInputs(IN) :
    c = int(IN.input())
    b = list(IN.ints())
    return (c,b)
    
def solve(inp) :
    (c,b) = inp
    if b[0] == 0 or b[-1] == 0 : return ["IMPOSSIBLE"]
    board = [ ['.'] * c for x in range(c) ]
    idx = 0
    for i,bb in enumerate(b) :
        if bb == 0 : continue
        doBoard(board,bb,i,idx)
        idx += bb
    for i,r in enumerate(board) :
        if r.count('.') == c : return board[:i+1]
    return board

def doBoard(board,bb,target,idx) :
    for i in range(idx,idx+bb) :
        if i == target : continue
        if i < target :
            numslash = target-i
            for k in range(numslash) :
                board[k][i+k] = '\\'
        elif i > target :
            numslash = i - target
            for k in range(numslash) :
                board[k][i-k] = '/'



#####################################################################################################
if __name__ == "__main__" :
    doit()

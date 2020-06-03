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
    (l1,)  = IN.strs()
    (l2,)  = IN.strs()
    (l3,)  = IN.strs()
    (l4,)  = IN.strs()
    _      = IN.strs()
    return (l1,l2,l3,l4)

def solve(inp) :
    (l1,l2,l3,l4) = inp
    xwins = set(("XXXX", "XXXT", "XXTX", "XTXX", "TXXX"))
    owins = set(("OOOO", "OOOT", "OOTO", "OTOO", "TOOO"))

    l5  = l1[0] + l2[0] + l3[0] + l4[0]
    l6  = l1[1] + l2[1] + l3[1] + l4[1]
    l7  = l1[2] + l2[2] + l3[2] + l4[2]
    l8  = l1[3] + l2[3] + l3[3] + l4[3]
    l9  = l1[0] + l2[1] + l3[2] + l4[3]
    l10 = l1[3] + l2[2] + l3[1] + l4[0]
    lines = (l1,l2,l3,l4,l5,l6,l7,l8,l9,l10)
    board = l1 + l2 + l3 + l4

    ## Check if X wins
    state = "Game has not completed"
    for l in lines :
        if l in xwins : state = "X won"; break
        if l in owins : state = "O won"; break
    if state == "Game has not completed" and '.' not in board:
        state = "Draw"

    return state

#####################################################################################################
if __name__ == "__main__" :
    doit()


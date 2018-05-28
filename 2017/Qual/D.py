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
    print("Case #%d: %s" % (tt,ans[0]))
    for l in ans[1:] : print(l)

def getInputs(IN) :
    n,m = IN.ints()
    oldboard = getBoard(n,m,IN)
    return (n,m,oldboard)

def getBoard(n,m,IN) :
    board = [['.'] * n for x in range(n) ]
    for _ in range(m) :
        c,x,y = IN.strs(); x = int(x); y = int(y)
        board[x-1][y-1] = c
    return board

def solve(inp) :
    (n,m,oldboard) = inp
    rooks,bishops = splitBoard(n,oldboard)
    doRooks(n,rooks)
    doBishops(n,bishops)
    newboard = combineBishopsAndRooks(n,rooks,bishops)
    score,subs = scoreBoard(n,oldboard,newboard)
    ans = []
    ans.append("%d %d" % (score,len(subs)))
    for c,row,col in subs : ans.append("%s %d %d" % (c,row,col))
    return ans

def splitBoard(n,board) :
    rooks = [['.'] * n for x in range(n) ]
    bishops = [['.'] * n for x in range(n) ]
    for i in range(n) :
        for j in range(n) :
            if board[i][j] == 'o' or board[i][j] == 'x' : placeRook(rooks,i,j,n)
            if board[i][j] == 'o' or board[i][j] == '+' : placeBishop(bishops,i,j,n)
    return rooks,bishops

def doRooks(n,board) :
    ## . is available, x is blocked, o is chosen
    ## Rook placement can be very greedy
    for i in range(n) :
        for j in range (n) :
            if board[i][j] == '.' : placeRook(board,i,j,n)

def placeRook(board,i,j,n) :
    for k in range(n) :
        board[k][j] = 'x'
        board[i][k] = 'x'
    board[i][j] = 'o'

def doBishops(n,board) :
    ## First, count the number of bishops on each main diagonal
    mainDiagCounts = []
    for ss in range(0,2*n-1) :
        empty = 0
        for i in range(n) :
            j = ss-i
            if j >= 0 and j < n and board[i][j] == '.' : empty += 1
        mainDiagCounts.append((empty,ss))

    ## Sort the diagonals by available squares
    mainDiagCounts.sort()

    ## Place the bishops from least avaiable squares to greates
    for (_,s) in mainDiagCounts :
        for i in range(n) :
            j = s-i
            if j >= 0 and j < n and board[i][j] == '.' :
                placeBishop(board,i,j,n)
                break

def placeBishop(board,i,j,n) :
    sumij = i + j
    diffij = i - j
    for ii in range(n) :
        jj1 = sumij - ii
        jj2 = ii - diffij
        if jj1 >= 0 and jj1 < n : board[ii][jj1] = 'x'
        if jj2 >= 0 and jj2 < n : board[ii][jj2] = 'x'
    board[i][j] = 'o'


def combineBishopsAndRooks(n,rooks,bishops) :
    board = [['.'] * n for x in range(n)]
    for i in range(n) :
        for j in range(n) :
            if rooks[i][j] == 'o' and bishops[i][j] == 'o' : board[i][j] = 'o'
            elif rooks[i][j] == 'o'                        : board[i][j] = 'x'
            elif bishops[i][j] == 'o'                      : board[i][j] = '+'
    return board

def scoreBoard(n,oldboard,newboard) :
    score,subs = 0,[]
    scoreDict = { '.' : 0, 'x' : 1, '+' : 1, 'o' : 2 }
    for i in range(n) :
        for j in range(n) :
            score += scoreDict[newboard[i][j]]
            if oldboard[i][j] != newboard[i][j] :
                subs.append( (newboard[i][j],i+1,j+1) )
    return score,subs

#####################################################################################################
if __name__ == "__main__" :
    doit()


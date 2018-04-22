import sys
import math
import heapq
from operator import itemgetter
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

class minheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,a)
    def pop(self)      : return heapq.heappop(self.h)
    def top(self)      : return self.h[0]
    def empty(self)    : return False if self.h else True

def printRes(res) :
    kk = sorted(res.keys())[::-1]
    for k in kk :
        print("%d %d" % (k,res[k]))

def cleanup(dp,y,x,m,n) :
    s = dp[y][x]
    t = max(0,y-s+1)
    l = max(0,x-s+1)
    for yy in range(t,y+s) :
        for xx in range(l,x+s) :
            if yy >= y and xx >= x : dp[yy][xx] = 0
            elif yy >= y : dp[yy][xx] = min(dp[yy][xx],x-xx)
            elif xx >= x : dp[yy][xx] = min(dp[yy][xx],y-yy)
            else         : dp[yy][xx] = min(dp[yy][xx],max(x-xx,y-yy)) 

def solve(inp) :
    (m,n,board) = inp
    res = {}
    dp = dpBoard(m,n,board)
    #print(dp)
    mh = minheap()
    for y in range(m) :
        for x in range(n) :
            mh.push( (-dp[y][x], y, x) )
    while not mh.empty() :
        (v,y,x) = mh.pop(); v = -v
        #print("DBG:     popped:",(v,y,x))
        if v != dp[y][x] :
            if dp[y][x] > 0 : mh.push( (-dp[y][x], y, x) );  #print("DBG:         pushed:",(dp[y][x],y,x))
            continue
        if v not in res : res[v] = 1
        else            : res[v] += 1
        #print("DBG: FOUND:",(v,y,x))
        cleanup(dp,y,x,m,n)
    return res

def dpBoard(m,n,board) :
    dp = [ [1] * n for x in range(m) ]
    for y in range(m-2,-1,-1) :
        for x in range(n-2,-1,-1) :
            if board[y+1][x] == board[y][x+1] and board[y][x] == board[y+1][x+1] and board[y][x] != board[y][x+1] :
                dp[y][x] = 1 + min(dp[y][x+1], dp[y+1][x], dp[y+1][x+1])
    return dp

def getInputs(IN) :
    m,n = IN.ints()
    board = [[False]*n for x in range(m)]
    for y in range(m) :
        s = bin(int(IN.input().rstrip(),16))[2:].zfill(n)
        for x,c in enumerate(s) :
            if c == '1' : board[y][x] = True
    return (m,n,board)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,len(ans)))
        printRes(ans)

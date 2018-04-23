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

def buildMinTree(p,n,ma) :
    ans = [0] * n
    startIdx = n
    for i in range(p) :
        startIdx = startIdx >> 1
        if i == 0 :  ans[startIdx:2*startIdx] = [ min(ma[2*x], ma[2*x+1] ) for x in range(startIdx) ]
        else      :
            offset = startIdx << 1  
            ans[startIdx:2*startIdx] = [ min(ans[offset+2*x],ans[offset+2*x+1]) for x in range(startIdx) ]
    return ans

def buildCostTree(p,n,levels) :
    ans = [0] * n
    startIdx = n
    for i in range(p) :
        startIdx = startIdx >> 1
        ans[startIdx:2*startIdx] = levels[i][:]
    return ans

cache = {}
def doTreeTraversal(idx,minTree,costTree,levelsLeft,skips) :
    global cache
    if (idx,skips) not in cache :
        if minTree[idx] - skips >= levelsLeft : return 0
        if skips > minTree[idx]               : return 1e99  ## Shouldn't get here
        if levelsLeft == 1                    : return costTree[idx]

        ## Case 1, we buy our ticket
        best1 = costTree[idx] + doTreeTraversal(2*idx,minTree,costTree,levelsLeft-1,skips) + doTreeTraversal(2*idx+1,minTree,costTree,levelsLeft-1,skips)
        best2 = 0  + doTreeTraversal(2*idx,minTree,costTree,levelsLeft-1,skips+1)   + doTreeTraversal(2*idx+1,minTree,costTree,levelsLeft-1,skips+1)
        cache[(idx,skips)] = min(best1,best2)
    return cache[(idx,skips)]

def solve(inp) :
    global cache
    cache = {}
    (p,n,ma,levels) = inp
    minTree = buildMinTree(p,n,ma)
    costTree = buildCostTree(p,n,levels)
    ans =  doTreeTraversal(1,minTree,costTree,p,0)
    return ans

def getInputs(IN) :
    p = int(IN.input())
    n = 1 << p
    ma = tuple(IN.ints())
    levels = []
    for i in range(p) :
        levels.append(tuple(IN.ints()))
    return (p,n,ma,levels)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))

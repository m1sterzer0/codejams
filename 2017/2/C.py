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

def kosaraju(nodes,adj) :
    def makeInv(nodes,adj) :
        adjInv = {}
        for n in nodes : adjInv[n] = {}
        for n in adj :
            for nn in adj[n] :
                adjInv[nn][n] = adj[n][nn]
        return adjInv

    def dfs1(adj,n,s,visited) :
        if n in visited : return
        visited.add(n)
        for nn in adj[n] : dfs1(adj,nn,s,visited)
        s.append(n)

    def dfs2(adjInv,n,sccnum,counter,visited) :
        if n in visited : return
        visited.add(n)
        for nn in adjInv[n] : dfs2(adjInv,nn,sccnum,counter,visited)
        sccnum[n] = counter

    visited = set()
    visitedInv = set()
    counter = 0
    s = []
    sccnum = {}
    
    adjInv = makeInv(nodes,adj)
    for n in nodes :
        if n not in visited : dfs1(adj,n,s,visited)
    while s :
        n = s.pop()
        if n not in visitedInv : dfs2(adjInv,n,sccnum,counter,visitedInv); counter += 1
    scc = [ [] for x in range(counter) ]
    for n in nodes : scc[sccnum[n]].append(n)
    return counter, sccnum, scc

def twosat(nlist,ninvlist,orterms) :
    assert len(nlist) == len(ninvlist)
    nn = len(nlist)
    numnodes = 2*nn
    t2n = {}
    for i,n in enumerate(nlist)    : t2n[n] = i
    for i,n in enumerate(ninvlist) : t2n[n] = i + nn
    adj = {}
    for i in range(numnodes) : adj[i] = {}
    for t1,t2 in orterms :
        n1,n2       = t2n[t1],t2n[t2]
        n1inv,n2inv = (n1 + nn) % numnodes, (n2 + nn) % numnodes
        adj[n1inv][n2] = 1
        adj[n2inv][n1] = 1
    _,sccNum,sccs = kosaraju(list(range(numnodes)),adj)
    for i in range(nn) :
        if sccNum[i] == sccNum[i+nn] : return False,[]
    ## Now we are satisfyable, we just need to assign the values.
    ## Process the sscs in topological order, and assign them to False unless already
    ## forced to True by a previous assignment
    value = [None] * numnodes
    for scc in sccs :
        sccval = False
        values = [value[n] for n in scc]
        if True in values : sccval = True
        assert (False not in values)
        for n in scc : 
            value[n] = sccval
            value[ (n + nn) % numnodes ] = not sccval
    return True, value[:nn]

def printOutput(tt,ans) :
    s,newboard = ans
    print("Case #%d: %s" % (tt,s))
    for row in newboard :
        print("".join(row))

def getInputs(IN) :
    r,c = IN.ints()
    board = [ ['.'] * c for x in range(r) ]
    for x in range(r) :
        board[x] = list(IN.input().rstrip())
    return(r,c,board)

def solve(inp) :
    (r,c,board) = inp
    (lasers,empties) = parseBoard(r,c,board)
    constraints = collections.defaultdict(list)
    for l in lasers :
        horizOK,horizSet = traceLaser('-',l,board,empties,r,c)
        vertOK, vertSet = traceLaser( '|',l,board,empties,r,c)
        if not horizOK and not vertOK : return ("IMPOSSIBLE", [])
        if horizOK :
            for e in horizSet : constraints[e].append( ("-", l[0], l[1]) )
            constraints[l].append( ("-", l[0], l[1]) )
        if vertOK :
            for e in vertSet  : constraints[e].append( ("|", l[0], l[1]) )
            constraints[l].append( ("|", l[0], l[1]) )

    solvable,solution = solveConstraints(constraints,lasers,empties)
    if not solvable : return ("IMPOSSIBLE", [])
    newboard = genBoard(board,solution)
    return ("POSSIBLE",newboard) 

def parseBoard(r,c,board) :
    lasers = set()
    empties = set()
    for i in range(r) :
        for j in range(c) :
            if board[i][j] == '.' : empties.add((i,j))
            if board[i][j] == '|' : lasers.add((i,j))
            if board[i][j] == '-' : lasers.add((i,j))
    return (lasers,empties)

def traceLaser(dir,l,board,empties,r,c) :
    (y,x) = l
    res = set()
    queue = []
    if dir == '-' : queue.append((y,x,0,-1)); queue.append((y,x,0,1))
    else          : queue.append((y,x,-1,0)); queue.append((y,x,1,0))
    while queue :
        yy,xx,incy,incx = queue.pop()
        nx,ny = xx+incx,yy+incy
        if nx < 0 or ny < 0 or nx >= c or ny >= r : continue
        cc = board[ny][nx]
        if (cc == '.')   : res.add((ny,nx)); queue.append((ny,nx,incy,incx))
        elif (cc == '#') : continue
        elif (cc == '-') : return False, set()
        elif (cc == '|') : return False, set()
        elif (cc == '/') : 
            if   (incy,incx) == (0,1)  : queue.append( (ny,nx,-1,0) )
            elif (incy,incx) == (0,-1) : queue.append( (ny,nx,1,0) ) 
            elif (incy,incx) == (-1,0) : queue.append( (ny,nx,0,1) ) 
            elif (incy,incx) == (1,0)  : queue.append( (ny,nx,0,-1) )
        elif (cc == "\\") :
            if   (incy,incx) == (0,1)  : queue.append( (ny,nx,1,0) )
            elif (incy,incx) == (0,-1) : queue.append( (ny,nx,-1,0) ) 
            elif (incy,incx) == (-1,0) : queue.append( (ny,nx,0,-1) ) 
            elif (incy,incx) == (1,0)  : queue.append( (ny,nx,0,1) )
    return True, res

def solveConstraints(constraints,lasers,empties) :
    sorterms = set()
    clists = [ constraints[e] for e in empties.union(lasers) ]
    for c in clists :
        assert len(c) <= 2
        if len(c) == 0  : return False, []
        elif len(c) == 1 : sorterms.add( (c[0], c[0]) )
        else             : sorterms.add( (c[0], c[1]) )
    nlist    = [ ('-',i,j) for i,j in lasers ]
    ninvlist = [ ('|',i,j) for i,j in lasers ]
    orterms  = list(sorterms)
    possible,ans = twosat(nlist,ninvlist,orterms)
    if not possible : return False, []
    else            : return True, [ y if x else z for x,y,z in zip(ans,nlist,ninvlist) ]

import copy
def genBoard(board,solutions) :
    newboard = copy.deepcopy(board)
    for (c,i,j) in solutions :
        newboard[i][j] = c
    return newboard

#####################################################################################################
if __name__ == "__main__" :
    doit()

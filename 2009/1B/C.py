import collections
import functools
import heapq
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
    w,q = IN.ints()
    sq = parseSquare(w,IN)
    qlist = tuple(IN.ints())
    return (w,q,sq,qlist)

def parseSquare(w,IN) :
    sq = [0] * w
    for i in range(w) :
        s, = IN.strs()
        sq[i] = [ int(x) if x in "0123456789" else x for x in s ]
    return sq

def solve(inp) :
    (w,q,sq,qlist) = inp
    ans = []
    posarr,negarr,maxpos,maxneg,neighbors = analyzeSquare(w,sq)
    for qq in qlist :
        lans = doQuery(sq,qq,posarr,negarr,maxpos,maxneg)
        ans.append(lans)
    return ans

def printOutput(tt,ans) :
    print("Case #%d:" % tt)
    for a in ans : print(a)

def analyzeSquare(w,sq) :
    posarr = [ [False] * w for x in range(w) ]
    negarr = [ [False] * w for x in range(w) ]
    neighbors = [ [ [] for x in range(w) ] for y in range(w) ]
    maxpos = 0
    maxneg = 0
    for i in range(w) :
        for j in range(w) :
            if sq[i][j] in (0,1,2,3,4,5,6,7,8,9) :
                if i != 0 :   neighbors[i][j].append((i-1,j))
                if i != w-1 : neighbors[i][j].append((i+1,j))
                if j != 0 :   neighbors[i][j].append((i,j-1))
                if j != w-1 : neighbors[i][j].append((i,j+1))
                signs = [ sq[x][y] for (x,y) in neighbors[i][j] ]
                if '+' in signs :
                    posarr[i][j] = True
                    maxpos = max(maxpos,sq[i][j])
                if '-' in signs :
                    negarr[i][j] = True
                    maxneg = max(maxneg,sq[i][j])
    return posarr,negarr,maxpos,maxneg,neighbors

def calcMinSteps(val,maxinc) :
    return val // maxinc if val % maxinc == 0 else val // maxinc + 1

def evalStepsLeft(targ,maxpos,maxneg,stepsSoFar,sq,posFlag,negFlag) :
    locMaxSteps = 1e99
    if targ < 0 and maxneg == 0 : return 1e100
    locMinSteps = stepsSoFar+calcMinSteps(targ,maxpos) if targ >= 0 else stepsSoFar+calcMinSteps(-targ,maxneg)
    if targ >  0 and sq > 0 and posFlag and targ % sq == 0 : locMaxSteps = min(locMaxSteps,stepsSoFar+targ//sq)
    if targ <  0 and sq > 0 and negFlag and -targ % sq == 0 : locaMaxSteps = min(locMaxSteps,stepsSoFar+(-targ)//sq)
    return locMinSteps,locMaxSteps 

def getSignAlternatives(i,j,resstr,sq,w) :
    res = []
    steps = [(-1,0),(1,0),(0,-1),(0,1)]
    for s1 in steps :
        signi = i + s1[0]; signj = j + s1[1]
        if signi < 0 or signi >= w or signj < 0 or signj >= w : continue
        sign = sq[signi][signj]
        res.append((signi,signj,resstr+sign))
    return res

def getNumAlternatives(i,j,val,level,resstr,sq,w) :
    res = []
    steps = [(-1,0),(1,0),(0,-1),(0,1)]
    for s1 in steps :
        numi = i + s1[0]; numj = j + s1[1]
        if numi < 0 or numi >= w or numj < 0 or numj >= w : continue
        sign = resstr[-1]
        newSq = sq[numi][numj]
        newVal = val + newSq if sign == '+' else val - newSq
        res.append((numi,numj,newVal,level+1,resstr+str(newSq)))
    return res

def doQuery(sq,target,posarr,negarr,maxpos,maxneg) :
    w = len(sq) 
    maxSteps = 1e99
    visited = set()
    queue = []
    for i in range(len(sq)) :
        for j in range(len(sq)) :
            if sq[i][j] in (0,1,2,3,4,5,6,7,8,9) :
                queue.append((i,j,sq[i][j],1,str(sq[i][j]))); visited.add((i,j,sq[i][j]))
    
    ## Do the levels one by one and sort the queue after by string to keep this in the right order
    ## -0 and +0 case is tricky , so need to do the signs, sort and then do the values to let -0 come before +0 cases to the same cell
    while True :
        oldqueue,queue = queue,[]
        oldqueue.sort(key=itemgetter(4))
        signqueue = []
        for (i,j,val,level,resstr)  in oldqueue :
            if val == target : return resstr
            locMinSteps,locMaxSteps = evalStepsLeft(target-val,maxpos,maxneg,level,sq[i][j],posarr[i][j],negarr[i][j])            
            if locMinSteps > maxSteps : continue
            if locMaxSteps > 0 and locMaxSteps < maxSteps : maxSteps = locMaxSteps
            alternatives = getSignAlternatives(i,j,resstr,sq,w)
            for (ni,nj,nresstr) in alternatives :
                if (ni,nj,val) in visited : continue
                visited.add((ni,nj,val))
                signqueue.append((ni,nj,val,level,nresstr))
        signqueue.sort(key=itemgetter(4))
        for (i,j,val,level,resstr) in signqueue :
            alternatives = getNumAlternatives(i,j,val,level,resstr,sq,w)
            for (ni,nj,nval,nlevel,nresstr) in alternatives :
                if (ni,nj,nval) in visited : continue
                visited.add((ni,nj,nval))
                queue.append((ni,nj,nval,nlevel,nresstr))

#####################################################################################################
if __name__ == "__main__" :
    doit(multi=True)

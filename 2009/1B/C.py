import sys
import math
import operator
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

def parseSquare(w,IN) :
    sq = [0] * w
    for i in range(w) :
        s, = IN.strs()
        sq[i] = [ int(x) if x in "0123456789" else x for x in s ]
    return sq

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
                elif '+' in signs :
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

def getAlternatives(i,j,val,level,resstr,sq,w) :
    res = []
    steps = [(-1,0),(1,0),(0,-1),(0,1)]
    for s1 in steps :
        signi = i + s1[0]; signj = j + s1[1]
        if signi < 0 or signi >= w or signj < 0 or signj >= w : continue
        sign = sq[signi][signj]
        assert sign in ('+','-')
        for s2 in steps :
            numi = signi + s2[0], numj = j + signj
            if numi < 0 or numi >= w or numj < 0 or numj >= w : continue
            newSq = sq[numi][numj]
            newVal = val + newSq if sign == '+' else val - newSq
            res.append((numi,numj,newVal,level+1,resstr+sign+str(newSq)))
    return res


def doQuery(sq,val,posarr,negarr,maxpos,maxneg,target) :
    w = len(sq) 
    maxSteps = 1e99
    visited = {}
    queue = []
    for i in range(len(sq)) :
        for j in range(len(sq)) :
            if sq[i][j] in (0,1,2,3,4,5,6,7,8,9) :
                queue.append((i,j,val,1,str(sq[i][j]))); visited.add((i,j,val))
    
    ## Do the levels one by one and sort the queue after by string to keep this in the right order
    while True :
        oldqueue,queue = queue,[]
        oldqueue.sort(key=itemgetter(4))
        for (i,j,val.level,resstr) in oldqueue :
            (i,j,val,level,resstr) = queue.pop(0)
            if val == target : return resstr

            locMinSteps,locMaxSteps = evalStepsLeft(target-val,maxpos,maxneg,level,sq[i][j],posarr[i][j],negarr[i][j])            
            if locMinSteps > maxSteps : continue
            if locMaxSteps > 0 and locMaxSteps < maxSteps : maxSteps = locMaxSteps

            alternatives = getAlternatives(i,j,val,level,resstr,sq,w)
            for (ni,nj,nval,nlev,nresstr) in alternatives :
                if (ni,nj,nval) in visited : continue
                visited.add((ni,nj,nval))
                queue.append((ni,nj,nval,nlev,nresstr))

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        w,q = IN.ints()
        sq = parseSquare(w,IN)
        qlist = IN.ints()
        posarr,negarr,maxpos,maxneg,neighbors = analyzeSquare(w,sq)
        print("Case #%d:" % tt)
        for qq in qlist :
            ans = doQuery(sq,qq,posarr,negarr,maxpos,maxneg,target)
            print(ans)

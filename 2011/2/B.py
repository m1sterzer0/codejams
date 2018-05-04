import sys
import math
import collections
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

def solve(inp) :
    (r,c,d,mass) = inp
    xmom = [ [0] * c for x in range(r) ]
    ymom = [ [0] * c for x in range(r) ]
    for i in range(r) :
        for j in range(c) :
            xmom[i][j] = i * mass[i][j]
            ymom[i][j] = j * mass[i][j]
    cummass = accumulate(r,c,mass) ## Sum of masses in rectangle from (0,0) to (i,j) inclusive
    cumxmom = accumulate(r,c,xmom) ## Sum of x moments in rectangle from (0,0) to (i,j) inclusive
    cumymom = accumulate(r,c,ymom) ## Sum of y moments in rectangle from (0,0) to (i,j) inclusive
    maxs = min(r,c)
    for s in range(maxs,3-1,-1) :
        for i in range(r-s+1) :
            for j in range(c-s+1) :
                x1,x2 = i,i+s-1
                y1,y2 = j,j+s-1
                locmass = cummass[x2][y2] - (0 if x1 == 0 else cummass[x1-1][y2]) - (0 if y1 == 0 else cummass[x2][y1-1]) + (0 if x1==0 or y1==0 else cummass[x1-1][y1-1]) \
                                          - mass[x1][y1] - mass[x1][y2] - mass[x2][y1] - mass[x2][y2]
                locxmom = cumxmom[x2][y2] - (0 if x1 == 0 else cumxmom[x1-1][y2]) - (0 if y1 == 0 else cumxmom[x2][y1-1]) + (0 if x1==0 or y1==0 else cumxmom[x1-1][y1-1]) \
                                          - xmom[x1][y1] - xmom[x1][y2] - xmom[x2][y1] - xmom[x2][y2]
                if (x1+x2) * locmass != 2 * locxmom : continue
                locymom = cumymom[x2][y2] - (0 if x1 == 0 else cumymom[x1-1][y2]) - (0 if y1 == 0 else cumymom[x2][y1-1]) + (0 if x1==0 or y1==0 else cumymom[x1-1][y1-1]) \
                                          - ymom[x1][y1] - ymom[x1][y2] - ymom[x2][y1] - ymom[x2][y2]
                if (y1+y2) * locmass != 2 * locymom : continue
                return str(s)
    return "IMPOSSIBLE"

def accumulate(r,c,arr) :
    ans = [ [0] * c for x in range(r) ]
    ans[0][0] = arr[0][0]
    for j in range(1,c) : ans[0][j] = ans[0][j-1] + arr[0][j]
    for i in range(1,r) : ans[i][0] = ans[i-1][0] + arr[i][0]
    for i in range(1,r) :
        for j in range(1,c) :
            ans[i][j] = arr[i][j] + ans[i][j-1] + ans[i-1][j] - ans[i-1][j-1]
    return ans

def getInputs(IN) :
    r,c,d = IN.ints()
    mass = [0] * r ## placeholder
    for i in range(r) :
        mass[i] = [ d + int(x) for x in IN.input().rstrip() ]
    return (r,c,d,mass)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (False) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))

    ## Multithreaded case
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))
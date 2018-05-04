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
    (p,w,wh) = inp
    adj,adjm = makeGraph(p,w,wh)
    a2 = dist(1,p,adj)
    if a2[0] == 1 : score = len(adj[0]) 
    else :
        qq = collections.deque()
        dp = {}
        for n in adj[0] :
            if a2[n] != a2[0]-1 : continue
            qq.append( (0,n) )
        while qq :
            (b,c) = qq.popleft()
            if (b,c) in dp : continue
            if b == 0 :
                x = len(adj[0])-1
                for n in adj[c] :
                    if not adjm[0][n] : x += 1
                dp[(b,c)] = x-1 #(we counted n == 0, need to subtract that out)
            else :
                aarr = [ x for x in adj[b] if (x,b) in dp ]
                scores = [ dodp(a,b,c,dp,adj,adjm) for a in aarr ]
                dp[(b,c)] = max(scores)
                #print("dp[(%d,%d)] = %d" % (b,c,max(scores)))
            if not adjm[c][1] :
                darr = [ x for x in adj[c] if a2[x] == a2[c] - 1 ]
                for d in darr : qq.append( (c,d) )
        score = max(dp[x] for x in dp)
    return "%d %d" % (a2[0]-1,score)

def makeGraph(p,w,wh) :
    adj = collections.defaultdict(list)
    adjm = [ [False] * p for x in range(p) ]
    for (x,y) in wh :
        adj[x].append(y)
        adj[y].append(x)
        adjm[x][y] = True
        adjm[y][x] = True
    return adj,adjm
                    
def dist(n,p,adj) :
    ans = [-1] * p
    ans[n] = 0
    ## BFS will give distances
    qq = collections.deque()
    qq.append(n)
    while qq :
        n1 = qq.popleft()
        for n2 in adj[n1] :
            if ans[n2] >= 0 : continue
            ans[n2] = ans[n1] + 1
            qq.append(n2)
    return ans

def dodp(a,b,c,dp,adj,adjm) :
    score = dp[(a,b)]-1  ## Have to subtract off c
    for x in adj[c] :
        ## Don't have to subtract off b since it is adj to a
        if not adjm[a][x] and not adjm[b][x] : score += 1  
    return score

def getInputs(IN) :
    p,w = IN.ints()
    wh = []
    edgestrs = IN.input().rstrip().split()
    for e in edgestrs :
        b = tuple(int(x) for x in e.split(','))
        wh.append(b)
    return (p,w,wh)    

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (True) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))

    ## Multithreaded case
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))
import fileinput
import sys
import functools
from statistics import median

class MyInput(object) :
    def __init__(self,default_file="A.in") :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input(default_file)]
        #if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.short")]
        else                   : self.lines = [x for x in fileinput.input()]
        self.lineno = 0
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans

def getInputs(myin) :
        (n,m) = myin.getintline(2)
        zips = [0] * (n+1)
        for i in range(1,n+1) : (zips[i],) = myin.getintline(1)
        edges = [ [] for x in range(n+1)]
        for i in range(m) :
            (a,b) = myin.getintline(2)
            edges[a].append(b)
            edges[b].append(a)
        return (n,m,zips,edges)

def adjustStack(stack, nn, edges) :
    for n in reversed(stack) :
        if nn in edges[n] :
            stack.append(nn)
            return
        else :
            stack.pop()

def getConnected(stack,edges) :
    ans = {}
    for n in stack :
        for nn in edges[n] :
            ans[nn] = 1
    return ans

def connectedAfterNode(stack, nodesToVisit, edges, nn) :
    locstack = stack[:]
    adjustStack(locstack,nn,edges)
    toVisit = set(nodesToVisit)
    toVisit.remove(nn)
    while(locstack) :
        n = locstack.pop()
        for n2 in edges[n] :
            if n2 in toVisit :
                toVisit.remove(n2)
                locstack.append(n2)
    return False if toVisit else True

def solve(n,m,zips,edges) :
    #On^3 is fine.  On^4 is even probably fine.  We can be a bit sloppy
    nodesToVisit = [ x for x in range(1,n+1)]
    nodesToVisit.sort(key=lambda n: zips[n])

    nn = nodesToVisit.pop(0)
    ansNodes = [nn]
    stack = [nn]
    connected = getConnected(stack,edges)
    while (nodesToVisit) :
        for idx,nn in enumerate(nodesToVisit) :
            if nn not in connected : continue
            if connectedAfterNode(stack,nodesToVisit,edges,nn) : break
        ansNodes.append(nn)
        nodesToVisit.pop(idx)
        adjustStack(stack,nn,edges)
        connected = getConnected(stack,edges)
    return "".join(str(zips[x]) for x in ansNodes)

if __name__ == "__main__" :
    myin = MyInput("C.in")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,m,zips,edges) = getInputs(myin)
        ans = solve(n,m,zips,edges)
        print("Case #%d: %s" % (tt+1,ans))

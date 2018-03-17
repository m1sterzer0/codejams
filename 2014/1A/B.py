import fileinput
import sys

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
        
## KEY INSIGHT:
## Minimizing number of pruned nodes is just maximizing depth of pruned tree
## We just cycle through the possible roots and do DFS on each, reporting the max depth for that root
##    we then just take the max depth achieved.  We calculate the anser from this max depth
##
## We can do better if we need to, by processing nodes that have 1 remaining connection


def doTraversal(connections,parent,node) :
    numChildren = len(connections[node]) - (0 if parent == -1 else 1)
    if numChildren < 2 : return 1
    max1,max2 = 1,1
    for n in connections[node] :
        if n == parent : continue
        s = doTraversal(connections,node,n)
        if s > max1 : max1,max2 = s,max1
        elif s > max2 : max2 = s
    return 1 + max1 + max2

if __name__ == "__main__" :
    myin = MyInput("B.in")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,) = myin.getintline(1)
        connections = [ [] for x in range(n+1)]

        for i in range(n-1) :
            (x,y) = myin.getintline(2)
            connections[x].append(y)
            connections[y].append(x)

        maxTreeSize = -1

        for root in range(1,n+1) :
            treeSize = doTraversal(connections,-1,root)
            if treeSize > maxTreeSize : maxTreeSize = treeSize

        numberPruned = n - maxTreeSize
        print("Case #%d: %d" % (tt+1, numberPruned)) 

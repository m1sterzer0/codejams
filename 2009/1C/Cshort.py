import sys
import math
from operator import itemgetter
import itertools
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

class unionFind(object) :
    def __init__(self) :
        self.weight = {}
        self.parent = {}
        self.size   = {}
    def insert(self,x) : self.find(x)
    def insertList(self,l) :
        for x in l : self.find(x)
    def find(self,x) :
        if x not in self.parent :
            self.weight[x] = 1
            self.parent[x] = x
            return x
        stk = [x]; par = self.parent[stk[-1]]
        while par != stk[-1] :
            stk.append(par)
            par = self.parent[stk[-1]]
        for i in stk : self.parent[i] = par
        return par
    def union(self,x,y) :
        px = self.find(x)
        py = self.find(y)
        if px != py :
            wx = self.weight[px]
            wy = self.weight[py]
            if wx >= wy : self.weight[px] = wx + wy; del self.weight[py]; self.parent[py] = px
            else        : self.weight[py] = wx + wy; del self.weight[px]; self.parent[px] = py
    def nodeSize(self,x) :
        px = self.find(x)
        return self.weight[px]

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        p,_ = IN.ints()
        qarr = tuple(IN.ints())

        ## Key is to do this in reverse order
        ## qarr = qarr[::-1]
        sb = [0] + [1] * p
        for q in qarr : sb[q] = 0

        globans = 1e99
        for qa in itertools.permutations(qarr) :
            uf = unionFind()
            for i in range(1,p+1) :
                if sb[i] == 1 :
                    if sb[i-1] == 0 : parent = i
                    uf.insert(i)
                    if i != parent : uf.union(i,parent)
    
            ans = 0
            for q in qa :
                uf.insert(q)
                if q-1 in uf.parent :
                    node = uf.find(q-1)
                    ans += uf.nodeSize(q-1)
                    uf.union(q,q-1)
                if q+1 in uf.parent :
                    node = uf.find(q-1)
                    ans += uf.nodeSize(q+1)
                    uf.union(q,q+1)
            if (ans < globans) :
                globans = ans
                best = qa

        print("Case #%d: %d" % (tt,globans))
            

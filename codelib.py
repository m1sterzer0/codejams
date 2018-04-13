import heapq
import sys

class minheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,a)
    def pop(self)      : return heapq.heappop(self.h)
    def top(self)      : return self.h[0]
    def empty(self)    : return False if self.h else True

## This assumes you use numbers.  Wrap a class and overload comparison operations for maxheap with nonstandard stuff
class maxheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,-a)
    def pop(self,a)    : return -heapq.heappop(self.h)
    def top(self,a)    : return -self.h[0]
    def empty(self)    : return False if self.h else True

class unionFind(object) :
    def __init__(self) :
        self.weight = {}
        self.parent = {}
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
    
class graph1(object) :
    def __init__(self,nodes,edges,bidir=False,weighted=True) :
        self.g = {}
        self.nodes = []
        for n in nodes : self.nodes.append(n); self.g[n] = {}
        for e in edges :
            w = 1 if not weighted else e[2]
            self.g[e[0]][e[1]] = w
            if bidir : self.g[e[1]][e[0]] = w

    def dijkstra(self,src) :
        d = {}
        for n in self.nodes : d[n] = 1e99  ## Use 1e99 as infty
        s = set()
        h = minheap(); h.push((0,src))
        while not h.empty() :
            (dist,n) = h.pop()
            if n in s : continue
            d[n] = dist; s.add(n)
            for nn in self.g[n] :
                if nn in s : continue
                h.push( (dist+self.g[n][nn], nn) )  ## Late binding costs can be put here
        return d

    def bellmanFord(self,src) :
        d = {}
        for n in self.nodes : d[n] = 1e99
        d[src] = 0
        numnodes = len(self.nodes)
        edgelist = [(x,y,self.g[x][y]) for x in self.nodes for y in self.g[x]]
        for _ in range(numnodes-1) :
            for (x,y,dist) in edgelist :
                if d[x] < 1e99 and d[x] + dist < d[y] : d[y] = d[x] + dist

        negCycles = False
        for (x,y,dist) in edgelist :
            if d[x] < 1e99 and d[x] + dist < d[y] : negCycles = True

        return d, negCycles

    def floydWarshall(self) :
        d = {}
        for n in self.nodes : 
            d[n] = {}
            for n2 in self.nodes : d[n][n2] = 1e99
            d[n][n] = 0
            for n2 in self.g[n] : d[n][n2] = self.g[n][n2]
        
        for k in self.nodes :
            for i in self.nodes :
                for j in self.nodes :
                    d[i][j] = min(d[i][j],d[i][k] + d[k][j])
        return d

    def prim(self) :
        src = self.nodes[0]
        parent = {}
        for n in self.g : parent[n] = n
        s = set()
        h = minheap(); h.push((0,src,src))
        while not h.empty() :
            (_,n,p) = h.pop()
            if n in s : continue
            s.add(n)
            parent[n] = p
            for nn in self.g[n] :
                if nn in s : continue
                h.push( (self.g[n][nn], nn, n) )
        mst = []
        for n in self.nodes :
            if n != parent[n] :
                mst.append( (parent[n], n, self.g[parent[n]][n]) )
        return mst

    def kruskal(self) :
        edgelist = [(x,y,self.g[x][y]) for x in self.nodes for y in self.g[x]]
        sortedEdgeList = sorted(edgelist,key=lambda x: x[2])
        mst = []; targetEdges = len(self.nodes)-1
        uf = unionFind()
        for n in self.nodes : uf.insert(n)
        for (x,y,d) in sortedEdgeList :
            px = uf.find(x)
            py = uf.find(y)
            if px != py:
                mst.append( (x,y,d) )
                uf.union(x,y)
            if len(mst) == targetEdges : break
        return mst

    def _ffbfs(self,s,t,parent) : ## Parent here is a dictionary
        visited = {}
        for n in self.nodes : visited[n] = False
        queue = []; queue.append(s); visited[s] = True
        while queue :
            u = queue.pop(0)
            for nn in self.g[u] :
                if visited[nn] : continue
                val = self.g[u][nn]
                if val <= 0 : continue
                queue.append(nn)
                visited[nn] = True
                parent[nn] = u
        return visited[t]

    def fordFulkerson(self, source, sink) :
        parent = {}
        for n in self.nodes : parent[n] = -1
        maxFlow = 0
        while self._ffbfs(source,sink,parent) :
            pathFlow = 1e99
            s = sink
            while (s != source) :
                u = parent[s]
                pathFlow = min(pathFlow,self.g[u][s])
                s = parent[s]
            maxFlow += pathFlow
            s = sink
            while (s != source) :
                u = parent[s]
                self.g[u][s] -= pathFlow
                if u in self.g[s] : self.g[s][u] += pathFlow
                else              : self.g[s][u] =  pathFlow
                s = parent[s]
        return maxFlow

def _tc1() :
    ## From https://www.cs.princeton.edu/~rs/AlgsDS07/15ShortestPaths.pdf
    n1 = ['s', 2, 3, 4, 5, 6, 7, 't']
    e1 = [ ('s', 2, 9),
           ('s', 6, 14),
           ('s', 7, 15),
           (6, 3, 18),
           (3, 5, 2),
           (5,4,11),
           (5,'t',16),
           (6,7,5),
           (7,5,20),
           (6,5,30),
           (4,3,6),
           (4,'t',6),
           (3,'t',19),
           (7,'t',44),
           (2,3,24)
        ]
    g1 = graph1(n1,e1)
    d = g1.dijkstra('s')
    d2,_ = g1.bellmanFord('s')
    d3 = g1.floydWarshall()
    print("_tc1:")
    for n in n1 : print("%s --> %s: %d %d %d" % ('s', str(n), d[n], d2[n], d3['s'][n]))

def _tc2() :
    n1 = [1, 2, 3, 4, 5, 6, 7, 8]
    e1 = [ (1, 2, 9),
           (1, 6, 14),
           (1, 7, 15),
           (6, 3, 18),
           (3, 5, 2),
           (5,4,11),
           (5,8,16),
           (6,7,5),
           (7,5,20),
           (6,5,30),
           (4,3,6),
           (4,8,6),
           (3,8,19),
           (7,8,44),
           (2,3,24)
        ]
    g1 = graph1(n1,e1,bidir=True)
    t1 = g1.prim()
    print(sorted(t1))
    t2 = g1.kruskal()
    print(sorted(t2))

def _tc3() :
    n1 = [1, 2, 3, 4, 5, 6, 7, 8]
    e1 = [ (1, 2, 9),
           (1, 6, 14),
           (1, 7, 15),
           (6, 3, 18),
           (3, 5, 2),
           (5,4,11),
           (5,8,16),
           (6,7,5),
           (7,5,20),
           (6,5,30),
           (4,3,6),
           (4,8,6),
           (3,8,19),
           (7,8,44),
           (2,3,24) ]
    g1 = graph1(n1,e1)
    f = g1.fordFulkerson(1,8)
    print(f)

if __name__ == "__main__" :
    _tc1()
    _tc2()
    _tc3()

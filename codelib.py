import heapq
import sys

class minheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,a)
    def pop(self)      : return heapq.heappop(self.h)
    def top(self)      : return self.h[0]
    def empty(self)    : return True if self.h else False

## This assumes you use numbers.  Wrap a class and overload comparison operations for maxheap with nonstandard stuff
class maxheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,-a)
    def pop(self,a)    : return -heapq.heappop(self.h)
    def top(self,a)    : return -self.h[0]
    def empty(self)    : return True if self.h else False

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
        edgelist = [(x,y,self.g[x][y]) for y in self.g[x] for x in self.nodes]
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
        h = minheap(); h.push((0,src,-1))
        while not h.empty() :
            (_,n,p) = h.pop()
            if n in s : continue
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
        edgelist = [(x,y,self.g[x][y]) for y in self.g[x] for x in self.nodes]
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

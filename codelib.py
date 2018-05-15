import heapq
import sys
import collections
import copy

class MaxHeapObj(object):
  def __init__(self,val): self.val = val
  def __lt__(self,other): return self.val > other.val
  def __eq__(self,other): return self.val == other.val

class MinHeap(object):
  def __init__(self): self.h = []
  def __len__(self): return len(self.h)
  def __getitem__(self,i): return self.h[i]
  def push(self,x): heapq.heappush(self.h,x)
  def pop(self): return heapq.heappop(self.h)
  def empty(self) : return False if self.h else True
  def top(self) : return self.h[0]

class MaxHeap(MinHeap):
  def __getitem__(self,i): return self.h[i].val
  def push(self,x): heapq.heappush(self.h,MaxHeapObj(x))
  def pop(self): return heapq.heappop(self.h).val
  def top(self) : return self.h[0].val

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
    
def dijkstra(src,nodes,adj) :
    d = {}
    for n in nodes : d[n] = 1e99
    s = set()
    h = MinHeap(); h.push((0,src))
    while not h.empty() :
        (dist,n) = h.pop()
        if n in s : continue
        d[n] = dist; s.add(n)
        for nn in adj[n] :
            if nn in s : continue
            h.push( (dist + g[n][nn], nn) )
    return d

def bellmanFord(src,nodes,adj) :
    d = {}
    for n in nodes : d[n] = 1e99
    d[src] = 0
    numnodes = len(nodes)
    edgelist = [(x,y,adj[x][y]) for x in nodes for y in adj[x]]
    for _ in range(numnodes-1) :
        for (x,y,dist) in edgelist :
            if d[x] < 1e99 and d[x] + dist < d[y] : d[y] = d[x] + dist
    negCycles = False
    for (x,y,dist) in edgelist :
        if d[x] < 1e99 and d[x] + dist < d[y] : negCycles = True
    return d, negCycles

def floydWarshall(nodes,adj) :
    d = {}
    for n in nodes : 
        d[n] = {}
        for n2 in nodes : d[n][n2] = 1e99
        d[n][n] = 0
        for n2 in adj[n] : d[n][n2] = adj[n][n2]
    
    for k in nodes :
        for i in nodes :
            for j in nodes :
                d[i][j] = min(d[i][j],d[i][k] + d[k][j])
    return d

def prim(nodes,adj) :
    ln = list(nodes)
    src = ln[0]
    parent = {}
    for n in nodes : parent[n] = n
    s = set()
    h = MinHeap(); h.push((0,src,src))
    while not h.empty() :
        (_,n,p) = h.pop()
        if n in s : continue
        s.add(n)
        parent[n] = p
        for nn in adj[n] :
            if nn in s : continue
            h.push( (adj[n][nn], nn, n) )
    mst = []
    for n in nodes :
        if n != parent[n] :
            mst.append( (parent[n], n, adj[parent[n]][n]) )
    return mst

def kruskal(nodes,adj) :
    edgelist = [(x,y,adj[x][y]) for x in nodes for y in adj[x]]
    sortedEdgeList = sorted(edgelist,key=lambda x: x[2])
    mst = []; targetEdges = len(nodes)-1
    uf = unionFind()
    for n in nodes : uf.insert(n)
    for (x,y,d) in sortedEdgeList :
        px = uf.find(x)
        py = uf.find(y)
        if px != py:
            mst.append( (x,y,d) )
            uf.union(x,y)
        if len(mst) == targetEdges : break
    return mst

def fordFulkerson(src,sink,nodes,adj) :
    def _ffbfs(src,sink,parent,nodes,adj) : ## Parent here is a dictionary
        visited = {}
        for n in nodes : visited[n] = False
        queue = collections.deque(); queue.append(src); visited[src] = True
        while queue :
            u = queue.popleft()
            for nn in adj[u] :
                if visited[nn] : continue
                val = adj[u][nn]
                if val <= 0 : continue
                queue.append(nn)
                visited[nn] = True
                parent[nn] = u
        return visited[sink]

    myadj = copy.deepcopy(adj)
    parent = {}
    for n in nodes : parent[n] = -1
    maxFlow = 0
    while _ffbfs(src,sink,parent,nodes,myadj) :
        pathFlow = 1e99
        s = sink
        while (s != src) :
            u = parent[s]
            pathFlow = min(pathFlow,myadj[u][s])
            s = parent[s]
        maxFlow += pathFlow
        s = sink
        while (s != src) :
            u = parent[s]
            myadj[u][s] -= pathFlow
            if u in myadj[s] : myadj[s][u] += pathFlow
            else             : myadj[s][u] =  pathFlow
            s = parent[s]

    flows = []
    for n in nodes :
        for nn in adj[nodes] :
            if adj[n][nn] == myadj[n][nn] : continue
            flows.append((adj[n][nn] - myadj[n][nn], n, nn))
    
    return maxFlow,flows

def maxBipartiteMatching(leftNodes,rightNodes,edges) :
    ## Use node -999999 for the source
    ## Use node  999999 for the sink
    nodes = [-999999,999999] + list(leftNodes) + list(rightNodes)
    adj = collections.defaultdict(list)
    for s,t in edges : adj[s][t] = 1
    for n in leftNodes : adj[-999999][n] = 1
    for n in rightNodes : adj[n][999999] = 1
    mf,f = fordFulkerson(-999999,999999,nodes,adj)
    pairs = [ (b,c) for a,b,c in f if b != -999999 and c != 999999 ]
    return mf,pairs

##def _tc1() :
##    ## From https://www.cs.princeton.edu/~rs/AlgsDS07/15ShortestPaths.pdf
##    n1 = ['s', 2, 3, 4, 5, 6, 7, 't']
##    e1 = [ ('s', 2, 9),
##           ('s', 6, 14),
##           ('s', 7, 15),
##           (6, 3, 18),
##           (3, 5, 2),
##           (5,4,11),
##           (5,'t',16),
##           (6,7,5),
##           (7,5,20),
##           (6,5,30),
##           (4,3,6),
##           (4,'t',6),
##           (3,'t',19),
##           (7,'t',44),
##           (2,3,24)
##        ]
##    g1 = graph1(n1,e1)
##    d = g1.dijkstra('s')
##    d2,_ = g1.bellmanFord('s')
##    d3 = g1.floydWarshall()
##    print("_tc1:")
##    for n in n1 : print("%s --> %s: %d %d %d" % ('s', str(n), d[n], d2[n], d3['s'][n]))
##
##def _tc2() :
##    n1 = [1, 2, 3, 4, 5, 6, 7, 8]
##    e1 = [ (1, 2, 9),
##           (1, 6, 14),
##           (1, 7, 15),
##           (6, 3, 18),
##           (3, 5, 2),
##           (5,4,11),
##           (5,8,16),
##           (6,7,5),
##           (7,5,20),
##           (6,5,30),
##           (4,3,6),
##           (4,8,6),
##           (3,8,19),
##           (7,8,44),
##           (2,3,24)
##        ]
##    g1 = graph1(n1,e1,bidir=True)
##    t1 = g1.prim()
##    print(sorted(t1))
##    t2 = g1.kruskal()
##    print(sorted(t2))
##
##def _tc3() :
##    n1 = [1, 2, 3, 4, 5, 6, 7, 8]
##    e1 = [ (1, 2, 9),
##           (1, 6, 14),
##           (1, 7, 15),
##           (6, 3, 18),
##           (3, 5, 2),
##           (5,4,11),
##           (5,8,16),
##           (6,7,5),
##           (7,5,20),
##           (6,5,30),
##           (4,3,6),
##           (4,8,6),
##           (3,8,19),
##           (7,8,44),
##           (2,3,24) ]
##    g1 = graph1(n1,e1)
##    f = g1.fordFulkerson(1,8)
##    print(f)
##
##if __name__ == "__main__" :
##    _tc1()
##    _tc2()
##    _tc3()

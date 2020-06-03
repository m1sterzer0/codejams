import collections
import functools
import heapq
import itertools
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

class graph(object) :
    def __init__(self,nodes,edges,bidir=False,weighted=True) :
        self.g = {}
        self.nodes = []
        for n in nodes : self.nodes.append(n); self.g[n] = {}
        for e in edges :
            w = 1 if not weighted else e[2]
            self.g[e[0]][e[1]] = w
            if bidir : self.g[e[1]][e[0]] = w

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
                else              : self.g[s][u] = pathFlow  ## In case reverse edge does not yet exist
                s = parent[s]
        return maxFlow

def maxBipartiteMatching(leftNodes,rightNodes,edges) :
    ## Use node -999999 for the source
    ## Use node  999999 for the sink
    nodes = [-999999,999999] + list(leftNodes) + list(rightNodes)
    myEdges = []
    for e in edges      : myEdges.append( (e[0], e[1], 1) )
    for i in leftNodes  : myEdges.append( (-999999, i, 1) )
    for i in rightNodes : myEdges.append( (i, 999999, 1) )
    gr = graph(nodes,myEdges)
    flow = gr.fordFulkerson(-999999,999999)
    pairs = []
    for (x,y) in edges :
        if gr.g[x][y] == 0 : pairs.append( (x,y) )
    return flow,pairs 

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    topics = [ tuple(IN.strs()) for i in range(n) ]
    return (n,topics)

def solve(inp) :
    (n,topics) = inp
    edges = [ ("l"+x[0],"r"+x[1]) for x in topics ]
    words1 = set([x[0] for x in edges])
    words2 = set([x[1] for x in edges])
    flow,pairs = maxBipartiteMatching(words1,words2,edges)  ## How many two word topics can we make with no repeats
    singles = len(words1) + len(words2) - 2 * flow          ## How many more topics do we need to add to cover all the words
    fakes = n - flow - singles
    return "%d" % fakes

#####################################################################################################
if __name__ == "__main__" :
    doit()

import sys
import math
import collections
import heapq
from operator import itemgetter

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

def getDist(i,j,dist,x,y,h,top,bot) :
    if bot[i][j] > top[x][y] - 50 : return -1
    if bot[x][y] > top[x][y] - 50 : return -1
    if bot[x][y] > top[i][j] - 50 : return -1

    wl = h - 10*dist
    if wl <= top[x][y] - 50 :    ## Water is already low enough
        cost = 0 if dist == 0 else 1 if wl >= bot[i][j] + 20 else 10

    else : ## Need to wait for the water to drop
        cost1 =  (wl - (top[x][y] - 50)) * 0.1
        newwl = top[x][y] - 50
        cost2 = 1 if newwl >= bot[i][j] + 20 else 10
        cost = cost1+cost2 

    return dist+cost 

def solve(inp) :
    (h,n,m,top,bot) = inp
    ## Dijkstra
    minh = MinHeap(); d = {}; s = set()
    minh.push(  (0, (0,0)) )
    while not minh.empty() :
        (dist,node) = minh.pop()
        (i,j) = node
        if node in s : continue
        d[node] = dist; s.add(node)
        conn = []
        if i > 0 : conn.append( (i-1,j) )
        if j > 0 : conn.append( (i,j-1) )
        if i < n-1 : conn.append ( (i+1,j) )
        if j < m-1 : conn.append ( (i,j+1) )
        for (x,y) in conn :
            t = getDist(i,j,dist,x,y,h,top,bot)
            if t >= 0 : minh.push( (t, (x,y)) )
    return "%.8f" % d[(n-1,m-1)]

def getInputs(IN) :
    h,n,m = IN.ints()
    top = [0] * n; bot = [0] * n
    for i in range(n) : top[i] = list(IN.ints())
    for i in range(n) : bot[i] = list(IN.ints())
    return (h,n,m,top,bot)

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
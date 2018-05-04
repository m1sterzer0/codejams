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


def solve(inp) :
    (n,levels) = inp

    mylevels = [ (x[1],x[0],i) for i,x in enumerate(levels) ]
    mylevels_by_2 = sorted(mylevels,reverse=True)
    mylevels_by_1 = sorted(mylevels,key=itemgetter(1,0,2),reverse=True)
    minh = MinHeap()
    maxh = MaxHeap()
    used2 = set()
    used1 = set()
    score = 0
    levels = 0
    while(True) :
        ## Priority 1: second level for levels where we have already completed the first star
        ## Priority 2: levels where we can do 2 stars in one go
        ## Priority 3: levels where we can do 1 star.  Among those, we should choose the one with the highest second level
        if not minh.empty() and minh.top()[0] <= score :
            t = minh.pop()
            if t not in used2 :
                used2.add(t); score += 1; levels += 1

        elif mylevels_by_2 and score >= mylevels_by_2[-1][0] :
            t = mylevels_by_2.pop()
            if t not in used1 and t not in used2 :
                used2.add(t); score += 2; levels += 1

        else :
            while mylevels_by_1 and mylevels_by_1[-1][1] <= score : maxh.push(mylevels_by_1.pop())
            if not maxh.empty():
                t = maxh.pop()
                if t not in used2 :
                    used1.add(t); score += 1; levels += 1; minh.push(t) 
            else : 
                break

    if score == 2 * n : return "%d" % levels
    else : return "Too Bad"

def getInputs(IN) :
    n = int(IN.input())
    levels = []
    for i in range(1,n+1) :
        a,b = IN.ints()
        levels.append( (a,b) )
    return (n,levels)  

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
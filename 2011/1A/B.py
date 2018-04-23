import sys
import math

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

import heapq
class minheap(object) :
    def __init__(self) : self.h = []
    def push(self,a)   : heapq.heappush(self.h,a)
    def pop(self)      : return heapq.heappop(self.h)
    def top(self)      : return self.h[0]
    def empty(self)    : return False if self.h else True

def processLetter(mh,larr,s,lidx,wl) :
    ## Look for the next letter in the first word
    d = {}
    l = larr[lidx]
    pos = [ tuple(i for i,v in enumerate(x) if v == l) for x in wl ]
    for i,p in enumerate(pos) :
        if p in d : d[p].append(wl[i])
        else      : d[p] = [ wl[i] ]
    ## If there is only one group, then we just repush the whole thing with the letter incremented
    if len(d) == 1 :
        ms = s + len(wl) - 1
        mh.push( (-ms,s,lidx+1,wl) )
    else :
        for k in d :
            ss = s if len(k) > 0 else s+1
            ms = ss + len(d[k]) - 1
            mh.push( (-ms,ss,lidx+1,d[k]) )

def solveProblem(warr,larr,words) :
    #Split the words by length
    #Use a heap for the problems -- tuple (maxScore, scoreSoFar, idx, wordList) 
    mh = minheap()  ## Use negatives on maxscore to deal with minheap
    for w in warr :
        mh.push( (-(len(w)-1), 0, 0, w) )
    candidates = []
    minScore = 0
    while not mh.empty() :
        (ms,s,i,wl) = mh.pop(); ms = -ms
        if ms < minScore : break
        if len(wl) == 1 : minScore = s; candidates.append(wl[0]); continue
        processLetter(mh,larr,s,i,wl)
    if len(candidates) == 1 : return candidates[0]
    for w in words :
        if w in candidates : return w

def splitWordsByLength(n,words) :
    d = {}
    ans = []
    for w in words :
        l = len(w)
        if l in d : d[l].append(w)
        else      : d[l] = [w]
    for k in sorted(d.keys()) :
        ans.append(d[k])
    return ans

def solve(inp) :
    (n,m,words,letters) = inp
    warr = splitWordsByLength(n,words)
    arr = []
    for l in letters :
        ans = solveProblem(warr,l,words)
        arr.append(ans)
    return " ".join(arr)

def getInputs(IN) :
    n,m = IN.ints()
    words   = [ IN.input().rstrip() for x in range(n) ]
    letters = [ IN.input().rstrip() for x in range(m) ]
    return (n,m,words,letters)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (False) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))

    ## Multithreaded case
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))

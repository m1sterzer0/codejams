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

Card = collections.namedtuple('Card',['s','t','c','idx'])

## Observations:
## 1) You should always play cards that give you more turns.  No penalty for playing them right away.
## 2) If you play 2 different C1 (or C2) cards in the optimal case, then you can always play them in the order received.  There is no advantage to playing the later one first.
##    -- This allows us to process the cards in the order in which we receive them
## 3) That gives us 5 choices per turn
##    a) Cash out with our best (up to T) no-card-draw cards
##    b) Play our earliest C1 card
##    c) (Virtually) discard a C1 card
##    d) Play our earliest C2 card
##    e (Virtually) discard a C2 card

class searcher(object) :
    def __init__(self) :
        self.cache = {}
        self.c0cache = {}
        self.numcards = 0
        self.deckt  = []
        self.deckc0 = []
        self.deckc1 = []
        self.deckc2 = []

    def populate(self,deck) :
        self.numcards = len(deck)
        for c in deck :
            if   c.t > 0  : self.deckt.append(c)
            elif c.c == 2 : self.deckc2.append(c)
            elif c.c == 1 : self.deckc1.append(c)
            else          : self.deckc0.append(c)
        self.analyzec0()

    def search(self,turns,tidx,c1idx,c2idx,deckidx) :
        if turns == 0 : return 0
        myid = (turns,tidx,c1idx,c2idx,deckidx)
        if myid not in self.cache :
            if tidx < len(self.deckt) and deckidx >= self.deckt[tidx].idx :
                c = self.deckt[tidx]
                self.cache[myid] = c.s + self.search(turns-1+c.t, tidx+1, c1idx, c2idx, deckidx + c.c)
            else :
                ans = self.solvec0(turns,deckidx)
                if c1idx < len(self.deckc1) and deckidx >= self.deckc1[c1idx].idx :
                    c = self.deckc1[c1idx]
                    ans2 = c.s + self.search(turns-1+c.t, tidx, c1idx+1, c2idx, deckidx + c.c)
                    ans3 = self.search(turns, tidx, c1idx+1, c2idx, deckidx) ## Skip the card
                    ans = max(ans,ans2,ans3)
                if c2idx < len(self.deckc2) and deckidx >= self.deckc2[c2idx].idx :
                    c = self.deckc2[c2idx]
                    ans2 = c.s + self.search(turns-1+c.t, tidx, c1idx, c2idx+1, deckidx + c.c)
                    ans3 = self.search(turns, tidx, c1idx, c2idx+1, deckidx) ## Skip the card
                    ans = max(ans,ans2,ans3)
                self.cache[myid] = ans
        return self.cache[myid]

    def solvec0(self,turns,deckidx) :
        if turns   > self.numcards   : turns = self.numcards
        if deckidx >= self.numcards  : deckidx = self.numcards-1
        return self.c0cache[(turns,deckidx)]

    def analyzec0(self) :
        ## Solve the local problems first, then extrapolate to the variables of interest
        self.c0cache = {}
        locans = {}
        locans[(0,0)] = 0
        for i in range(1,len(self.deckc0)+1) :
            x = sorted(self.deckc0[:i])
            score = 0
            for j in range(1,i+1) :
                c = x.pop(); score += c.s; locans[(i,j)] = score
        
        cards = 0
        for idx in range(self.numcards) :
            if cards < len(self.deckc0) and self.deckc0[cards].idx == idx : cards += 1
            for turns in range(1,self.numcards+1) :
                if turns >= cards : self.c0cache[(turns,idx)] = locans[(cards,cards)]
                else              : self.c0cache[(turns,idx)] = locans[(cards,turns)]

def getInputs(IN) :
    n = int(IN.input())
    deck = []
    for i in range(n) :
        c,s,t = IN.ints()
        deck.append(Card(s,t,c,i))
    m = int(IN.input())
    for i in range(m) :
        c,s,t = IN.ints()
        deck.append(Card(s,t,c,n+i))
    return (n,m,deck)

def solve(inp) :
    (n,m,deck) = inp
    s = searcher()
    s.populate(deck)
    ans = s.search(1,0,0,0,n-1)
    return str(ans)


def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

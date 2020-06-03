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

def doitInteractive() :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) : solveInteractive(IN)

#####################################################################################################

def solveInteractive(IN) :
    a = int(IN.input())
    scoreboard = [[False] * 30 for x in range(30)]
    (xb,yb) = gopher(IN,2,2)
    scoreboard[xb][yb] = True
    minx,miny = xb,yb
    maxx,maxy = xb+9,yb+19
    for x in range(minx,minx+10) :
        xx = x + 1 if x + 1 < maxx else x if x < maxx else x-1
        for y in range(miny,miny+20) :
            while not scoreboard[x][y] :
                yy = y+1 if y+1 < maxy else y if y < maxy else y-1
                (xb,yb) = gopher(IN,xx,yy)
                if (xb,yb) == (0,0) : return True
                if (xb,yb) == (-1,-1) : return False
                scoreboard[xb][yb] = True
    return False

def gopher(IN,x,y) :
    print("%d %d" % (x,y), flush=True)
    xb,yb = IN.ints()
    return (xb,yb)

#####################################################################################################
if __name__ == "__main__" :
    doitInteractive()

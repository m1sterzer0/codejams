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

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    x,r,c = IN.ints()
    return (x,r,c)

def solve(inp) :
    (x,r,c) = inp

    ## WLOG, R <= C
    ## a) If X >= 7, Gabriel loses, since Richard can pick a piece
    ##    with a hole
    ## b) If X doesn't divide R*C, then clearly Gabriel loses
    ## c) If (a) and (b) hold and Gabriel can create a S x T
    ##    rectange, with S <= R and T <= C, then Gabriel wins.
    ##    The remaining squres can be filled in by dividing a space-filling
    ##    Hamiltonian path into n-ominoes.
    ##
    ## Thus, we must figure out, for each of the N-ominoes, what is the smallest SxT rectangle we can make
    ##
    ## X == 1: Only one monomino.  They all work
    ## x == 2: Only 1 Domino: ## -- 1x2 -- No restrictions
    ## X == 3 : 2 trominos:  Limiting case is
    ##   #aa
    ##   ##a
    ## Thus, R==1 doesn't work, but any other R will work
    ##
    ## X == 4 : 5 tetrominos.  Limiting case is 
    ##   aaab
    ##   a#bb
    ##   ###b
    ## We can't find a 1 x n or 2 x n configuration that works for that tetronimo, so R==1 and R==2 are out.
    ## All other Rs work.
    ##
    ## X == 5 : 12 Pentominos.  The limiting case is
    ##
    ##  eedccc#abb     aaa#c
    ##  eedcc##abb or  aa##c
    ##  eddd##aaab     b##cc
    ##                 bbbbc
    ##
    ## So 3x5 is out (as is R==2 and R==1).  All other cases work.
    ##
    ## X == 6 : 35 Hexonimos.  One limiting case is:
    ##
    ##      #
    ##      #
    ##     ####
    ##   Is a problem for R = 3, since it partitions the space into 2 disjoint spaces that can't be made to be a multiple of 6
    ##
    ## All of the hexonimos are no taller than 3 in their shortest dimension.  4x6 works for them all.  Thus, R in {1,2,3} doen't work,
    ## but others do.

    if r > c : r,c = c,r
    if x >= 7 : return "RICHARD"
    if r * c % x != 0 : return "RICHARD"
    if x == 3 and r == 1 : return "RICHARD"
    if x >= 4 and r <= 2 : return "RICHARD"
    if x == 5 and r == 3 and c == 5 : return "RICHARD"
    if x == 6 and r == 3 : return "RICHARD"
    return "GABRIEL" 

#####################################################################################################
if __name__ == "__main__" :
    doit()


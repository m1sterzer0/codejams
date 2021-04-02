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
    presolve(IN)
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

import urllib
import urllib.request
wordsByPrefix = collections.defaultdict(list)
def presolve(IN) :
    #url = "https://code.google.com/codejam/contest/static/garbled_email_dictionary.txt"
    #response = urllib.request.urlopen(url)
    #data = response.read()
    #text = data.decode('utf-8')
    #words = text.rstrip().split('\n')
    ##fh = open("words.txt","r")
    nwords, = IN.ints()
    words = [IN.input().rstrip() for x in range(nwords)]
    #words = [ x.rstrip() for x in fh.readlines() ]
    #fh.close()
    for w in words :
        prefix = w if len(w) < 5 else w[:5]
        wordsByPrefix[prefix].append(w)
        for i in range(len(prefix)) :
            x = prefix[0:i] + '*' + prefix[i+1:]
            wordsByPrefix[x].append(w)

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    s = IN.input().rstrip()
    return (s,)

def solve(inp) :
    (s,) = inp
    ls = len(s)
    dp = [ [1e99] * 5 for x in range(len(s)) ]
    for i in reversed(range(len(s))) :
        prefixes = ['*',s[i]]
        if (i+2 <= ls) : 
            prefixes.append(s[i:i+3])
            prefixes.append(s[i:i]   + '*' + s[i+1:i+2])
            prefixes.append(s[i:i+1] + '*' + s[i+2:i+2])
        if (i+3 <= ls) : 
            prefixes.append(s[i:i+3])
            prefixes.append(s[i:i]   + '*' + s[i+1:i+3])
            prefixes.append(s[i:i+1] + '*' + s[i+2:i+3])
            prefixes.append(s[i:i+2] + '*' + s[i+3:i+3])
        if (i+4 <= ls) : 
            prefixes.append(s[i:i+4])
            prefixes.append(s[i:i]   + '*' + s[i+1:i+4])
            prefixes.append(s[i:i+1] + '*' + s[i+2:i+4])
            prefixes.append(s[i:i+2] + '*' + s[i+3:i+4])
            prefixes.append(s[i:i+3] + '*' + s[i+4:i+4])
        if (i+5 <= ls) :
            prefixes.append(s[i:i+5])
            prefixes.append(s[i:i]   + '*' + s[i+1:i+5])
            prefixes.append(s[i:i+1] + '*' + s[i+2:i+5])
            prefixes.append(s[i:i+2] + '*' + s[i+3:i+5])
            prefixes.append(s[i:i+3] + '*' + s[i+4:i+5])
            prefixes.append(s[i:i+4] + '*' + s[i+5:i+5])
        w = set()
        for p in prefixes :
            for word in wordsByPrefix[p] :
                if word in w : continue
                w.add(word)
                lw = len(word)
                if i + len(word) > ls : continue
                matches = [ l1 == l2 for l1,l2 in zip(word,s[i:i+lw])]
                ## Check mismatches
                firstMismatch = -99
                lastMismatch = -99
                numMismatches = 0
                goodWord = True
                for ii,m in enumerate(matches) :
                    if m : continue
                    if i - lastMismatch < 5 : goodWord = False; break
                    lastMismatch = ii
                    if firstMismatch < 0 : firstMismatch = ii
                    numMismatches += 1
                if not goodWord : continue
                maxj = 4 if numMismatches == 0 else min(4,firstMismatch)
                for j in range(0,maxj+1) :
                    if i + lw == ls : ans = numMismatches
                    else :
                        nextj = j-lw if numMismatches == 0 else 4 - ( (lw-1) - lastMismatch)
                        nextj = max(0,nextj)
                        ans = numMismatches + dp[i+lw][nextj]
                    if ans < dp[i][j] : dp[i][j] = ans
    for i in range(len(s)) :
        for j in range(5) :
            print(f"DBG: dp[{i}][{j}]={dp[i][j]}")
    return "%d" % dp[0][0]

#####################################################################################################
if __name__ == "__main__" :
    doit("Btc3.in")


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

def getInputs(IN) :
    n,m = IN.ints()
    u = tuple(IN.ints())
    v = tuple(IN.ints())
    return (n,m,u,v)

def solve(inp) :
    (n,m,u,v) = inp
    rooms,minSize = splitRooms(n,m,u,v)
    colors = colorRooms(rooms,n,minSize)
    return (minSize,colors)

def printOutput(tt,ans) :
    (minSize,colors) = ans
    print("Case #%d: %d" % (tt,minSize))
    print(" ".join(str(x) for x in colors))

def splitRooms(n,m,u,v) :
    rooms = [ list(range(1,n+1)) ]
    ## Iterate through each edge
    ##    find the room that contains both vertices
    ##    split that room up

    for uu,vv in zip(u,v) :
        for room in rooms :
            if uu not in room or vv not in room : continue
            rooms.remove(room)
            idx1 = room.index(uu)
            idx2 = room.index(vv)
            if idx1 > idx2 : idx1,idx2 = idx2,idx1
            room1 = room[idx1:idx2+1]
            room2 = room[0:idx1+1] + room[idx2:]
            rooms.append(room1)
            rooms.append(room2)
            break
    sizes = [ len(x) for x in rooms ]
    return rooms, min(sizes)

def categorizeRoomsByEdges(rooms,n) :
    rwe = collections.defaultdict(list)
    eir = collections.defaultdict(list)
    for i,r in enumerate(rooms) :
        for j in range(1,len(r)) :
            if r[j] - r[j-1] > 1 :
                e = (r[j-1],r[j])
                rwe[e].append(i)
                eir[i].append(e)
        if r[-1]-r[0] < n-1 :
            e = (r[0],r[-1])
            rwe[e].append(i)
            eir[i].append(e)
    return rwe,eir

def colorRoom(c,room,minSize) :
    colorsSoFar = [ c[x] for x in room ]
    if colorsSoFar.count(-1) == len(room) :
        for i,n in enumerate(room) : c[n] = (i % minSize) + 1 
    else : ## Should have one edge colored
        assert colorsSoFar.count(-1) == len(room)-2
        f = next(i for i,x in enumerate(colorsSoFar) if x > 0)  ##First non-zero element
        if f == 0 and colorsSoFar[1] < 0 : f = len(room)-1
        colors = list(range(1,minSize+1))
        colors.remove(colorsSoFar[f])
        colors.remove(colorsSoFar[f+1 if f+1 < len(room) else 0])
        rr2 = room + room
        for idx in range(f+2,f+len(room)) :
            if colors : c[rr2[idx]] = colors.pop()
            elif c[rr2[idx-1]] != 1 and c[rr2[idx+1]] != 1 : c[rr2[idx]] = 1
            elif c[rr2[idx-1]] != 2 and c[rr2[idx+1]] != 2 : c[rr2[idx]] = 2
            else                                           : c[rr2[idx]] = 3
    pass

def colorRooms(rooms,n,minSize) :
    roomsWithEdge,edgesInRoom = categorizeRoomsByEdges(rooms,n)
    rootIdx = 0
    while len(rooms[rootIdx]) != minSize : rootIdx += 1
    visited = set()
    q = collections.deque()
    q.append(rootIdx); visited.add(rootIdx)
    c = [-1] * (n+1)
    while q :
        ridx = q.popleft()
        room = rooms[ridx]
        colorRoom(c,room,minSize)
        for edge in edgesInRoom[ridx] :
            for nextRoom in roomsWithEdge[edge] :
                if nextRoom not in visited :
                    visited.add(nextRoom)
                    q.append(nextRoom)
    return c[1:]

#####################################################################################################
if __name__ == "__main__" :
    doit()

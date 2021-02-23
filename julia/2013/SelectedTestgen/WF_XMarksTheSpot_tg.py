import random
import fractions

def colinear(p1,p2,p3) :
    (x1,y1) = p1
    (x2,y2) = p2
    (x3,y3) = p3
    dx1 = x2-x1
    dy1 = y2-y1
    dx2 = x3-x1
    dy2 = y3-y1
    return dx1*dy2-dy1*dx2 == 0

random.seed(8675309)
(fn,ntc) = ("Ctc1.in",1000000)

choices1 = []
choices1 += [(1,x) for x in (3,5,10,100,1000,10000,100000,1000000) for y in range(1)]
choices1 += [(2,x) for x in (6,10,100,1000,10000,100000,1000000) for y in range(1)]
choices1 += [(3,x) for x in (10,100,1000,10000,100000,1000000) for y in range(1)]
for i in range(4,10+1) :
    choices1 += [(i,x) for x in (100,1000,10000,100000,1000000) for y in range(1)]

goodtc = [360]
with open(fn,'wt') as fp :
    with open("Ctc2.in",'wt') as fp2:
        print(ntc, file=fp)
        print(len(goodtc),file=fp2)
        for tt in range(ntc) :
            print(f"Case {tt}")
            (N,cmax) = random.choice(choices1)
            cmin = -cmax
            #(N,cmin) = ( (1,-5) if tt < 200 else
            #             (2,-8) if tt < 4000 else
            #             (3,-10) if tt < 8000 else
            #             (4,-12) if tt < 12000 else
            #             (5,-100) if tt < 16000 else
            #             (random.randrange(1,10+1),random.choice([-1000000,-100000,-10000,-500])) )
            #N = random.randrange(1,10+1)
            #cmin = -15 if tt < 400 else -100 if tt < 800 else -1000 if tt < 1200 else -1000000
            #cmax = -cmin
            fourn = 4*N
            pts = []
            slopes = set()
            vert = False
            while (len(pts) < fourn) :
                #print(len(pts))
                x1 = random.randrange(cmin,cmax+1)
                y1 = random.randrange(cmin,cmax+1)
                if (x1,y1) in pts : continue
                good = True
                for i in range(len(pts)) :
                    for j in range(i+1,len(pts)) :
                        if colinear(pts[i],pts[j],(x1,y1)) :
                            good = False
                if (good) :
                    pts.append((x1,y1))
            print(N,file=fp)
            for (x,y) in pts :
                print(f"{x} {y}",file=fp)
            if tt+1 in goodtc :
                print(N,file=fp2)
                for (x,y) in pts :
                    print(f"{x} {y}",file=fp2)


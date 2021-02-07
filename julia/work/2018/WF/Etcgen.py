import random
random.seed(8675309)
with open("Etc1.in","wt") as fp :
    ntc = 1000
    print(ntc,file=fp)
    for tt in range(ntc) :
        N = random.randrange(4,6+1)
        print(N,file=fp)
        for i in range(N) :
            (x1,y1,x2,y2) = (0,0,0,0)
            bad = True
            while bad: 
                x1 = random.randrange(-500,500+1)
                x2 = random.randrange(-2000,2000+1)
                y1 = random.randrange(-250,1250+1)
                y2 = random.randrange(-2000,2000+1)
                ## Check that we are not on the segment
                check1 = (x1 != 0) or (y1 < 0) or (y1 > 1000)
                ## Check that the ray points somewhere
                check2 = (x1 != x2) or (y1 != y2)
                bad = not check1 or not check2
            print(f"{x1} {y1} {x2} {y2}",file=fp)



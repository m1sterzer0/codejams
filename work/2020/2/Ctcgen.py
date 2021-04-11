
import random
random.seed(8675309)
ntc = 100000
goodids = [29,112,215]
with open("Ctc1.in",'wt') as fp :
    with open("Ctc1b.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
            N = random.choice([1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,7,7,7,8,8,8,8,9,9,9,9])
            #N = random.choice([1,2,2,3,3,3,4,4,4,4,5,5,5,5,5])
            Cmax = random.choice([3,5,10,20,100])
            pts = set()
            while len(pts) < N :
                x = random.randrange(-Cmax,Cmax+1)
                y = random.randrange(-Cmax,Cmax+1)
                pts.add((x,y))

            print(N,file=fp)
            for (x,y) in pts :
                print(f"{x} {y}",file=fp)

            if ttt+1 in goodids :
                print(N,file=fp2)
                for (x,y) in pts :
                    print(f"{x} {y}",file=fp2)



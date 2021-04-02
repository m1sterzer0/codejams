import random
random.seed(2345)
(r,c,n,d) = (200,200,200,1000000000)
squares = []
for i in range(r) :
    for j in range(c) :
        squares.append((i+1,j+1))

with open("Dsmall.in","wt") as fp:
    tt = 100
    print(tt,file=fp)
    for i in range(tt) :
        print(f"{r} {c} {n} {d}",file=fp)
        random.shuffle(squares)
        for i in range(n) :
            (ri,ci) = squares[i]
            bi = random.randrange(1,1000000001)
            print(f"{ri} {ci} {bi}",file=fp)

(r,c,n) = (5,5,5)
d = random.randrange(1,6)
squares = []
for i in range(r) :
    for j in range(c) :
        squares.append((i+1,j+1))
with open("Dtiny.in","wt") as fp:
    tt = 100
    print(tt,file=fp)
    for i in range(tt) :
        print(f"{r} {c} {n} {d}",file=fp)
        random.shuffle(squares)
        for i in range(n) :
            (ri,ci) = squares[i]
            bi = random.randrange(1,11)
            print(f"{ri} {ci} {bi}",file=fp)

(r,c) = (10,10)
squares = []
for i in range(r) :
    for j in range(c) :
        squares.append((i+1,j+1))
with open("Dtiny2.in","wt") as fp:
    tt = 100
    print(tt,file=fp)
    for i in range(tt) :
        n = random.randrange(5,11)
        d = random.randrange(3,11)
        print(f"{r} {c} {n} {d}",file=fp)
        random.shuffle(squares)
        for i in range(n) :
            (ri,ci) = squares[i]
            bi = random.randrange(1,11)
            print(f"{ri} {ci} {bi}",file=fp)

(r,c) = (1000000000,1000000000)
with open("Dlarge.in","wt") as fp:
    tt = 100
    print(tt,file=fp)
    for i in range(tt) :
        n = random.choice([1,2,3,50,100,150,200])
        d = 1000000000
        print(f"{r} {c} {n} {d}",file=fp)
        squares = set()
        for i in range(n) :
            while True :
                ri = random.randrange(1,r+1)
                ci = random.randrange(1,c+1)
                if (ri,ci) not in squares :
                    squares.add((ri,ci))
                    break
            bi = 1000000000
            print(f"{ri} {ci} {bi}",file=fp)

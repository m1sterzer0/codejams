### For capacity checking
import random
random.seed(2345)

with open("C.in2","wt") as fp :
    t = 10000
    print(t,file=fp)
    for tt in range(t) :
        done = False
        while not done :
            Hd = random.randrange(1,101)
            Hk = random.randrange(1,101)
            Ak = random.randrange(1,101)
            B  = random.randrange(0,3)
            D =  random.randrange(0,3) 
            Ad = random.randrange(1,4)
            if Hd >  2 * Ak - 3 * D : done = True
        print(f"{Hd} {Ad} {Hk} {Ak} {B} {D}",file=fp)

with open("C.in3","wt") as fp :
    t = 10000
    print(t,file=fp)
    for tt in range(t) :
        done = False
        while not done :
            Hd = random.randrange(1,1001)
            Hk = random.randrange(1,1001)
            Ak = random.randrange(1,1001)
            B  = random.randrange(0,3)
            D =  random.randrange(0,3) 
            Ad = random.randrange(1,4)
            if Hd >  2 * Ak - 3 * D : done = True
        print(f"{Hd} {Ad} {Hk} {Ak} {B} {D}",file=fp)

with open("C.in4","wt") as fp :
    t = 1000
    print(t,file=fp)
    for tt in range(t) :
        done = False
        while not done :
            Hd = random.randrange(1,10001)
            Hk = random.randrange(1,10001)
            Ak = random.randrange(1,10001)
            B  = random.randrange(0,3)
            D =  random.randrange(0,3) 
            Ad = random.randrange(1,4)
            if Hd >  2 * Ak - 3 * D : done = True
        print(f"{Hd} {Ad} {Hk} {Ak} {B} {D}",file=fp)

with open("C.in5","wt") as fp :
    t = 1000
    print(t,file=fp)
    for tt in range(t) :
        done = False
        while not done :
            Hd = random.randrange(1,100001)
            Hk = random.randrange(1,100001)
            Ak = random.randrange(1,100001)
            B  = random.randrange(0,3)
            D =  random.randrange(0,3) 
            Ad = random.randrange(1,4)
            if Hd >  2 * Ak - 3 * D : done = True
        print(f"{Hd} {Ad} {Hk} {Ak} {B} {D}",file=fp)

with open("C.in6","wt") as fp :
    t = 1000
    print(t,file=fp)
    for tt in range(t) :
        done = False
        while not done :
            Hd = random.randrange(1,1000000001)
            Hk = random.randrange(1,1000000001)
            Ak = random.randrange(1,1000000001)
            B  = random.randrange(0,100)
            D =  random.randrange(0,100) 
            Ad = random.randrange(1,400)
            if Hd >  2 * Ak - 3 * D : done = True
        print(f"{Hd} {Ad} {Hk} {Ak} {B} {D}",file=fp)

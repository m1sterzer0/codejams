function solveit(A::BigInt, B::BigInt, Y::BigInt, Vy::BigInt, M::BigInt, W::BigInt)
    ## Figure out the intervals.
    twoA = 2*A
    vdist1 = 2*B*Vy % twoA
    vdist = 2*B*M*Vy % twoA
    if vdist > A; vdist = twoA - vdist; Y = twoA - Y; vdist1 = twoA - vdist1; end
    pdist = 2*B*M*W
    if pdist >= vdist; return -1; end
    a = (vdist-pdist-1) ÷ 2
    (t1a,t1b) = (-a,A-vdist+a)
    (t2a,t2b) = (A+t1a,A+t1b)
    if t1a <= Y && Y <= t1b; return 1+M; end
    if t2a <= Y && Y <= t2b; return 1+M; end
    if twoA+t1a <= Y && Y <= twoA+t1b; return 1+M; end
    inc1 = twoA-Y
    inc2 = Y < t2a ? -Y : inc1
    (u1a,u1b,u2a,u2b) = (t1a+inc1,t1b+inc1,t2a+inc2,t2b+inc2)
    s1 = solveit2(twoA,vdist1,u1a,u1b)
    s2 = solveit2(twoA,vdist1,u2a,u2b)
    return s1 < 0 && s2 < 0 ? -1 : 1+M+(s1 < 0 ? s2 : s2 < 0 ? s1 : s1 < s2 ? s1 : s2)
end

function solveit2(twoA::BigInt,vdist::BigInt,l::BigInt,r::BigInt)
    if twoA-vdist < vdist; return solveit2(twoA,twoA-vdist,twoA-r,twoA-l); end
    q = l ÷ vdist
    base = q*vdist
    if base == l; return q; end
    if (base+vdist) <= r; return q+1; end

    q2 = twoA ÷ vdist
    base2 = q2 * vdist
    if base2 == twoA; return -1; end
    backward = twoA - base2
    newl,newr = l-base,r-base
    aa = solveit2(vdist,backward,vdist-newr,vdist-newl)
    if aa == -1; return -1; end
    finall,finalr = l+backward*aa,r+backward*aa
    adder = finall ÷ vdist
    if vdist*adder < finall; adder += 1; end
    return q2*aa+adder
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        N,M = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        V,W = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        Y,X,Vy,Vx = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        if Vy == 0 || Vx == 0; print("DRAW\n"); continue; end
        if Vy < 0; Y = A-Y; Vy = -Vy; end
        flipped = false
        if Vx < 0; flipped = true; X = B-X; (N,M,V,W) = (M,N,W,V); Vx = -Vx; end
        ## Now we are going up and to the right.
        ## now we deal with time units
        ## Normally, go (0,0) --> (Vx,Vy) every 1 time unit
        ## Equivalent to going (0,0) --> (1,Vy/Vx) every 1/Vx time unit
        ## If we divide up the vertical into Vx more steps for every 1, we 
        ##   go from (0,0) --> (1,Vy) every 1/Vx time unit.
        A *= Vx; Y *= Vx
        ## Wall 1 start
        twoA = 2*A

        ## Do the right side first
        W1y = (Y + (B-X) * Vy) % twoA
        n1 = solveit(A,B,W1y,Vy,M,W)

        ## Now do the left side
        W2y = (W1y + B*Vy) % twoA
        n2 = solveit(A,B,W2y,Vy,N,V)

        leftstr  = flipped ? "RIGHT" : "LEFT"
        rightstr = flipped ? "LEFT"  : "RIGHT"

        if n1 < 0 && n2 < 0; print("DRAW\n")
        ## Revisit for off-by-one errors
        elseif n1 < 0; print("$rightstr $(n2-1)\n")
        elseif n2 < 0; print("$leftstr $(n1-1)\n")
        elseif n1 <= n2; print("$leftstr $(n1-1)\n")
        else             print("$rightstr $(n2-1)\n")
        end
    end
end

main()

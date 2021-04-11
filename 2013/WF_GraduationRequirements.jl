
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solveSmall(C::I,X::I,N::I,S::VI,E::VI,T::VI)::I
    board::Array{Char,2} = fill('.',2*N,2*X+2)
    pl::I,tl::I = 2*N,2*X+1
    for i in 1:C
        s,e,t = S[i],E[i],T[i]
        xx::I,tt::I,ee::I = 2s,2t+1,2e
        board[xx,tt] = 'x'
        while true
            xx += 1; tt += 1
            if xx > pl; xx = 1; end
            board[xx,tt] = 'x'
            if xx == ee || tt >= tl; break; end
        end
    end
    best = 0
    for x in 1:N
        for t in 0:X-1
            (xx,tt) = 2*x, 2*t+1
            if board[xx,tt] == 'x'; continue; end
            l::I = 0
            while true
                xx -= 1; tt += 1
                if xx <= 0; xx = 2*N; end
                if board[xx,tt] == 'x'; break; end
                l += 1
                if tt == tl; break; end
            end
            best = max(best,l÷2)
        end
    end
    return best
end

function tryit(x::I,t::I,CC::Array{I,2},C::I,twoX::I,twoN::I)::I
    ## Double times and distances to avoid fractions
    tmin::I,tmax::I,N::I = -2,twoX+2,(twoN>>1)
    for i in 1:C
        s::I  = CC[i,1]
        t1::I = CC[i,2]
        t2::I = CC[i,4]
        x1::I = (x + (t - t1)) % twoN; if x1 <= 0; x1 += twoN; end
        startdist::I = x1 - s; if startdist < 0; startdist += twoN; end
        neededdist::I = (t2-t1)*2
        if neededdist >= startdist
            tt1::I = t1 + startdist ÷ 2
            if     tt1 == t; return 0
            elseif tt1 <= t; tmin=max(tmin,tt1)
            else;            tmax=min(tmax,tt1)
            end
            if neededdist >= startdist + twoN
                tt2::I = tt1 + (twoN >> 1)
                if     tt2 == t; return 0
                elseif tt2 <= t; tmin=max(tmin,tt2)
                else             tmax=min(tmax,tt2)
                end
            end
        end
    end
    tmin += (tmin & 1 == 0) ? 2 : 1
    tmax -= (tmax & 1 == 0) ? 2 : 1
    return tmax ÷ 2 - tmin ÷ 2
end

function solveLarge(C::I,X::I,N::I,S::VI,E::VI,T::VI)::I
    CC::Array{I,2} = fill(0,C,4)
    for i in 1:C
        s,e,t = S[i],E[i],T[i]
        t2 = e > s ? t + (e-s) : t + (N-s) + e
        CC[i,:] = [2*s,2*t,2*e,2*t2]
    end
    if C == 0; return X; end
    twoX,twoN = 2*X,2*N
    best = 0
    for i in 1:C
        for (x,t) in ((CC[i,1],CC[i,2]),(CC[i,3],CC[i,4]))
            for xdel in (-2,0,2)
                xx = x + xdel; xx = (xx == 0) ? twoN : (xx > twoN) ? xx - twoN : xx
                for tdel in (-2,0,2)
                    tt = t + tdel
                    if tt < 0 || tt > twoX; continue; end
                    a::I = tryit(xx,tt,CC,C,twoX,twoN) 
                    best = max(best,a)
                end
            end
        end
    end
    return best
end

function gencase(Cmin::I,Cmax::I,Nmin::I,Nmax::I,Xmin::I,Xmax::I)
    C = rand(Cmin:Cmax)
    N = rand(Nmin:Nmax)
    X = rand(Xmin:Xmax)
    S::VI = fill(0,C)
    E::VI = fill(0,C)
    T::VI = fill(0,C)
    for i in 1:C
        t = rand(0:X-1)
        s = rand(1:N)
        dmax = min(N-1,X-t)
        mydel = rand(1:dmax)
        e = (s + mydel) % N
        if e == 0; e = N; end
        S[i],E[i],T[i] = s,e,t
    end
    return (C,X,N,S,E,T)
end

function test(ntc::I,Cmin::I,Cmax::I,Nmin::I,Nmax::I,Xmin::I,Xmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (C,X,N,S,E,T) = gencase(Cmin,Cmax,Nmin,Nmax,Xmin,Xmax)
        ans2 = solveLarge(C,X,N,S,E,T)
        if check
            ans1 = solveSmall(C,X,N,S,E,T)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(C,X,N,S,E,T)
                ans2 = solveLarge(C,X,N,S,E,T)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        C = gi()
        X,N = gis()
        S::VI = fill(0,C)
        E::VI = fill(0,C)
        T::VI = fill(0,C)
        for i in 1:C; S[i],E[i],T[i] = gis(); end
        #ans = solveSmall(C,X,N,S,E,T)
        ans = solveLarge(C,X,N,S,E,T)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,0,10,3,10,1,10)

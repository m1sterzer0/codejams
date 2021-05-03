
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


using Random

function solve(N::I,D::I,S::I,E::I,L::VI)
    factarr = [factorial(i) for i in 1:16]
    denom = factorial(16) * N * (N-1) ÷ 2
    num = 0
    sol = Dict{Any,I}()
    digarr::VVI = []
    for i in 1:N
        push!(digarr,getRawDigits(L[i],D))
    end
    rawdig::VI = fill(-1,2D)
    mappedDig::VI = fill(-1,16)
    newrep::VI = fill(-1,2D)
    for i in 1:N-1
        for j in i+1:N
            p1 = getDigPattern(digarr[i],digarr[j],D,rawdig,mappedDig,newrep)
            p2 = getDigPattern(digarr[j],digarr[i],D,rawdig,mappedDig,newrep)
            p = min(p1,p2)
            if !haskey(sol,p)
                ans = solvea(p,D,factarr,S,E)
                sol[p] = ans
            end
            num += sol[p]
        end
    end
    g = gcd(num,denom)
    num ÷= g; denom ÷= g;
    return (num,denom)
end

function getRawDigits(a::I,D::I)::VI
    rawdig::VI = []
    for d in 1:D
        push!(rawdig, (a >> (4*(D-d))) & 0xf)
    end
    return rawdig
end

function getDigPattern(a::VI,b::VI,D::I,rawdig::VI,mappedDig::VI,newrep::VI)
    i = 1
    for d in 1:D
        rawdig[i] = a[d]; i += 1
        rawdig[i] = b[d]; i += 1
    end
    fill!(mappedDig,-1)
    nextval::I = 0
    idx::I = 1
    for i in 1:D
        x::I = rawdig[idx]
        if mappedDig[x+1] < 0; mappedDig[x+1] = nextval; nextval += 1; end
        a::I = mappedDig[x+1]
        idx += 1
        x = rawdig[idx]
        if mappedDig[x+1] < 0; mappedDig[x+1] = nextval; nextval += 1; end
        b::I = mappedDig[x+1]
        idx -= 1
        if a > b; (a,b) = (b,a); end
        newrep[idx] = a; idx += 1
        newrep[idx] = b; idx += 1
    end
    if D == 2
        return (newrep[1],newrep[2],newrep[3],newrep[4])
    elseif D == 3
        return (newrep[1],newrep[2],newrep[3],newrep[4],newrep[5],newrep[6])
    elseif D == 4
        return (newrep[1],newrep[2],newrep[3],newrep[4],newrep[5],newrep[6],newrep[7],newrep[8])
    elseif D == 5
        return (newrep[1],newrep[2],newrep[3],newrep[4],newrep[5],newrep[6],newrep[7],newrep[8],newrep[9],newrep[10])
    end
end

function solvea(p,D::I,factarr::VI,S::I,E::I)
    glbmap::VI = fill(-1,16)
    nummapped::I = 0
    working::Vector{Tuple{I,VI,I}} = [(0,fill(-1,16),0)]
    mask::I = 16^D-1
    used::Vector{Bool} = fill(false,16)
    ans = 0
    for d in 1:D
        newworking::Vector{Tuple{I,VI,I}} = []
        pv::I = 16^(D-d); twopv::I = 2pv;
        a::I,b::I = p[2d-1],p[2d]
        if glbmap[a+1] >= 0 && glbmap[b+1] >= 0
            for (cursum::I,map::VI,nummapped::I) in working
                lo::I = (cursum + pv * map[a+1] + pv * map[b+1]) & mask
                hi::I = (lo + twopv) & mask
                if d < D
                    if S <= lo <= hi <= E; ans += factarr[16-nummapped]
                    elseif lo <= S <= hi || lo <= E <= hi; push!(newworking,(lo,map,nummapped))
                    elseif hi < lo && (lo <= E || S <= hi); push!(newworking,(lo,map,nummapped))
                    end
                else
                    if S <= lo <= E; ans += factarr[16-nummapped]; end
                end
            end
        elseif glbmap[a+1] >= 0 || glbmap[b+1] >= 0
            premapped::I = glbmap[a+1] >= 0 ? a : b
            unmapped::I  = glbmap[a+1] >= 0 ? b : a
            for (cursum,map,nummapped) in working
                fill!(used,false)
                for x in map; if x >= 0; used[x+1] = true; end; end
                base = cursum + pv * map[premapped+1]
                for i in 0:15
                    if used[1+i]; continue; end
                    lo = (base + i * pv) & mask
                    hi = (lo + twopv) & mask
                    if d < D
                        if S <= lo <= hi <= E
                            ans += factarr[16-nummapped-1]
                        elseif lo <= S <= hi || lo <= E <= hi || (hi < lo && (lo <= E || S <= hi))
                            newmap = copy(map); newmap[unmapped+1] = i
                            push!(newworking,(lo,newmap,nummapped+1))
                        end
                    else
                        if S <= lo <= E; ans += factarr[16-nummapped-1]; end
                    end
                end
            end
        elseif a == b
            for (cursum,map,nummapped) in working
                fill!(used,false)
                for x in map; if x >= 0; used[x+1] = true; end; end
                base::I = cursum
                for i in 0:15
                    if used[1+i]; continue; end
                    lo = (base + i * twopv) & mask
                    hi = (lo + twopv) & mask
                    if d < D
                        if S <= lo <= hi <= E
                            ans += factarr[16-nummapped-1]
                        elseif lo <= S <= hi || lo <= E <= hi || (hi < lo && (lo <= E || S <= hi))
                            newmap = copy(map); newmap[a+1] = i
                            push!(newworking,(lo,newmap,nummapped+1))
                        end
                    else
                        if S <= lo <= E; ans += factarr[16-nummapped-1]; end
                    end
                end
            end
        else
            for (cursum,map,nummapped) in working
                fill!(used,false)
                for x in map; if x >= 0; used[x+1] = true; end; end
                base = cursum
                for i in 0:15
                    if used[1+i]; continue; end
                    for j in 0:15
                        if used[1+j] || i == j; continue; end
                        lo = (base + (i+j) * pv) & mask
                        hi = (lo + twopv) & mask
                        if d < D
                            if S <= lo <= hi <= E
                                ans += factarr[16-nummapped-2]
                            elseif lo <= S <= hi || lo <= E <= hi || (hi < lo && (lo <= E || S <= hi))
                                newmap = copy(map); newmap[a+1] = i; newmap[b+1] = j
                            push!(newworking,(lo,newmap,nummapped+2))
                        end
                        else
                            if S <= lo <= E; ans += factarr[16-nummapped-2]; end
                        end
                    end
                end
            end
        end
        glbmap[a+1] = 1; glbmap[b+1] = 1
        working = newworking
    end
    return ans
end

function test(ntc,Dmin,Dmax,Nmin,Nmax)
    for ttt in 1:ntc
        D = rand(Dmin:Dmax)
        N = rand(Nmin:Nmax)
        semax = 16^D-1
        S = rand(0:semax)
        E = rand(0:semax)
        if E < S; (S,E) = (E,S); end
        L = rand(0:semax,N)
        (num,denom) = solve(N,D,S,E,L)
        print("Case $ttt: $num $denom\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,D = gis()
        hexS,hexE = gss()
        S = parse(Int64,"0x"*hexS)
        E = parse(Int64,"0x"*hexE)
        hexL = gss()
        L::VI = fill(0,N)
        for i in 1:N; L[i] = parse(Int64,"0x"*hexL[i]); end
        ans = solve(N,D,S,E,L)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()
#test(200,3,3,400,450)
#test(100,4,4,400,450)
#test(10,5,5,400,450)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,2,2,5,5)
#Profile.clear()
#@profilehtml test(10,5,5,400,450)


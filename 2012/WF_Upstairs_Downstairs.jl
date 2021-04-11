
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

################################################################################
## We want to maximize the probabilty of either being awake the whole time or going
## to sleep once and staying asleep
## ALL AWAKE: p1*p2*p3*...*pn
## GO ASLEEP AND STAY ASLEEP: (1-p1)*...*(1-pn) +
##                            p1*(1-p2)*...*(1-pn) +
##                            p1*p2*(1-p3)*...*(1-pn) +
##                            ... +
##                            p1*p2*...*pnm1*(1-pn)
##
## Sum of both (to MAXIMIZE) is p1*p2*p3*...*pn +
##                              p1*p2*p3*...*pnm1*(1-pn) +
##                              p1*p2*p3*...*pnm2*(1-pnm1)*(1-pn) +
##                              ...
##                              p1*p2*p3*(1-p4)*(1-p5)*...*(1-pn) +
##                              p1*p2*(1-p3)*(1-p4)*(1-p5)*...*(1-pn) +
##                              p1*(1-p2)*(1-p3)*(1-p4)*(1-p5)*...*(1-pn) +
##                              (1-p1)*(1-p2)*(1-p3)*(1-p4)*(1-p5)*...*(1-pn) 
## Observation 1: 
## for pm and pmp1, which order do we prefer
## Case 1 (pm then pmp1) S1 = Common + p1*p2*pm1*pm*(1-pmp1)*(1-pmp2)*...*(1-pn)
##                         = C + a*pm*(1-pmp1) w/ a > 0
## Case 2 (pmp1 then pm) S2 = C + a*pmp1*(1-pm) w/ a > 0
## S1 > S2 iff pm > pmp1
## Thus, the final solution has the answers ordered from highest to lowest.

## Observation 2: since this is linear in the p terms, the sum is optimized when we use
## extremes.  This makes intuitive sense -- we want to frontload activities that keep folks
## awake, and then we want to backload tasks that keep folks aslee

## Memory = 1M * 6 * 8 = 48M -- no worries even in Julia
################################################################################

function solve(N::I,K::I,A::VI,B::VI,C::VI)::F
    ntot = sum(C[i] for i in 1:N)
    parr::VF    = fill(0.0,ntot)
    prea::VF    = fill(0.00,K)
    pres::VF    = fill(0.00,K)
    sufa2a::VF  = fill(0.00,K)
    sufa2s::VF  = fill(0.00,K)
    sufs2s::VF  = fill(0.00,K)
    idx = 1
    for i in 1:N
        p = Float64(A[i])/Float64(B[i])
        for j in 1:C[i]
            parr[idx] = p; idx+=1
        end
    end
    sort!(parr,rev=true)

    ## Do the prefixes
    a::Float64,s::Float64 = 1.0,0.0
    for i in 1:K 
        p = parr[i]; s = (a+s)*(1-p); a *= p
        prea[i] = a; pres[i] = s
    end

    ## Do the suffixes
    a2a::Float64,a2s::Float64,s2s::Float64 = 1.0,0.0,1.0
    for i in 1:K
        p = parr[ntot-i+1]; a2s = p * a2s + (1-p)*s2s; s2s *= 1-p; a2a *= p
        sufa2a[i] = a2a; sufa2s[i] = a2s; sufs2s[i] = s2s
    end

    nq = max(sufa2a[K] + sufa2s[K], prea[K] + pres[K])
    for i in 1:K-1
        j = K-i; a = prea[i]; s = pres[i]
        a2a = sufa2a[j]; a2s = sufa2s[j]; s2s = sufs2s[j]
        cand = a*a2a + a*a2s + s*s2s
        nq = max(nq,cand)
    end

    return 1-nq    
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        A::VI = fill(0,N)
        B::VI = fill(0,N)
        C::VI = fill(0,N)
        for i in 1:N
            ss = gss()
            ss2 = split(ss[1],'/')
            A[i] = parse(Int64,ss2[1])
            B[i] = parse(Int64,ss2[2])
            C[i] = parse(Int64,ss[2])
        end
        ans = solve(N,K,A,B,C)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


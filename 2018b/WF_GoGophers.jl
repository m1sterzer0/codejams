
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
##    Non-unique fractions         Possible Denoms   Max(pairwise LCM)
##    =========================    ===============  ===================
##    {1,3,5,7,11}/12              12,24                             24
##    {1,2,3,4,5,6,7,8,9,10}/11    11,22                             22
##    {1,3,7,9}/10                 10,20                             20
##    {1,2,4,5,7,8}/9              9,18                              18
##    {1,3,5,7}/8                  8,16,24                           48
##    {1,2,3,4,5,6}/7              7,14,21                           42
##    {1,5}/6                      6,12,18,24                        72
##    {1,2,3,4}/5                  5,10,15,20                        60
##    {1,3}/4                      4,8,12,16,20,24                  120
##    {1,2}/3                      3,6,9,12,15,18,21,24             168
##    1/2                          2,4,6,...,24                     264
################################################################################
## Worst Case Search accounting
## Cases:: ALl of the 12ths
## Prefix: search: 49*20=950    Analysis 1: 2*25*24 =1200.  Total 2150
## Case1: 12ths 1->2->3->...->11->12: (11*2*24)*21.  Total 11088
## Case2:  8th: (7*2*48)*21 = 14112
## Case3:  6ths (5*2*72)*21 = 15120
## Case4:  4ths (3*2*120)*21 = 15120
## Case5: 1/2 --> 7/12 -> 8/12 --> ... -> 11/12 -> 12/12
##         (528+5*2*24)*21 = 16128
## Case6: 1/2 -> 2/3 -> 5/6 -> 11/12 -> 12/12
##         (264+168+72+24+24)*2*21 = 23184
################################################################################

function getn(v::I,n::I)::VI
    q = join(fill(v,n),"\n")*"\n"
    print(join(fill(v,n),"\n")*"\n"); flush(stdout)
    return [gi() for i in 1:n]
end

function doans(sb::VB)
    for i in 2:25
        if sb[i]; print("$(-i)\n"); flush(stdout); return; end
    end
    print("-26\n"); flush(stdout)  ## Shouldn't get here
end

function doit(v::I,sb::VB,cnt::I)
    ## Get the biggest pairwise lcm that we can find
    cand::VI = [i for i in 2:25 if sb[i]]
    mylcm = 1; numerator = 0; denominator = 0
    for (i,j) in Iterators.product(1:length(cand),1:length(cand))
        if i >= j; continue; end
        a,b = cand[i],cand[j]
        mylcm = max(mylcm,lcm(a,b))
    end
    ## Collect double the pairwise lcm (1 for alignment, and one for analysis)
    vals::VI = getn(v,2mylcm) 
    for c in cand
        offset = cnt % c == 0 ? 0 : c - (cnt % c)
        candnum = sum(vals[offset+1:offset+c])
        while offset+c <= 2mylcm
            n2 = sum(vals[offset+1:offset+c])
            if n2 != candnum; sb[c] = false; candnum = -1; break; end
            offset += c
        end
        if candnum > 0; numerator = candnum ÷ gcd(candnum,c); denominator = c ÷ gcd(candnum,c); end
    end
    cnt += 2mylcm
    if denominator == 0; exit(1); end
    return (numerator,denominator,cnt)
end

function solveSmall()
    cnt::I = 0
    l::I,u::I = (0,1_000_000)
    ## Initial binary search
    while (u-l > 1)
        m::I = (l+u)÷2
        vals = getn(m,49); cnt += 49
        if 1 in vals; u = m; else; l = m; end
    end
    vals = getn(u,1250)
    for c in 2:25
        offset = cnt % c == 0 ? 0 : c - (cnt % c)
        good = true
        while offset+c <= 1250
            if sum(vals[offset+1:offset+c]) != 1; good = false; break; end
            offset += c
        end
        if good; print("$(-c)\n"); flush(stdout); return; end
    end
    print("-26\n"); flush(stdout)
end

function solveLarge()
    ## Do initial search
    cnt::I = 0
    l::I,u::I = (0,1_000_000)
    ## Initial binary search
    while (u-l > 1)
        m::I = (l+u)÷2
        vals = getn(m,49); cnt += 49
        if 1 in vals; u = m; else; l = m; end
    end
    ## Initial analysis
    sb::VB = fill(true,25); sb[1] = false
    (num,denom,cnt) = doit(u,sb,cnt)
    if count(x->x,sb) == 1; doans(sb); return; end

    ## Now the full loop
    while true
        (l,u) = (u,1_000_000)
        while (u-l > 1)
            m = (l+u)÷2
            (newnum,newdenom,cnt) = doit(m,sb,cnt)
            if count(x->x,sb) == 1; doans(sb); return; end
            if (num,denom) == (newnum,newdenom); l = m; else; u = m; end
        end
        (num,denom,cnt) = doit(u,sb,cnt)
        if denom == 1 || count(x->x,sb) == 1; doans(sb); return; end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        s = gi(); if s == -1; exit(0); end
        #solveSmall()
        solveLarge()
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


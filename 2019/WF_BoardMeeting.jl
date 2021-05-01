
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

function query(x::I,y::I)
    print("$x $y\n"); flush(stdout)
    ans =  gi()
    #print(stderr,"DBUG: query($x,$y) = $ans\n")
    return ans
end
function ready(); print("READY\n"); flush(stdout); end
function reqAns(a::I); print("$a\n"); flush(stdout); end
function getRequest()::Tuple{Bool,I,I}
    a = gs()
    if a == "ERROR"; exit(0); end
    if a == "DONE"; return (true,0,0); end
    x,y = [parse(Int64,x) for x in split(a)]
    return (false,x,y)
end

function solveSmall(Nmax::I,M::I,R::I)
    kingx::I,kingy::I = 0,0
    if Nmax > 1; exit(0); end
    ## 1st query -- upper left corner
    a = query(-M,-M)
    b = query(M,M)
    c = query(M-b,-M+a)
    if c == 0; (kingx,kingy) = (M-b,-M+a); else; (kingx,kingy) = (-M+a,M-b); end
    ready()
    while(true)
        (done,x,y) = getRequest()
        if done; break; end
        reqAns(max(abs(x-kingx),abs(y-kingy)))
    end
end

function solveLarge(Nmax::I,M::I,R::I)
    ## Rotate coordinates to turn Linf norm to L1 norm
    ## (x,y) --> (x+y,x-y)/2 -- deal with factor of 2 at end
    ## Step 1 -- figure out how many points we have
    ## Step 2 -- binary search along (M,-3M) --> (3M,-M) to decipher (x+y) coordinates (line has constant (x-y),
    ##           and being far enough out that we can move from white to black squares predictably)
    ## Step 3 -- binary search along (-M,-3M) --> (-3M,-M) to decipher (x-y) coordinates (line has constant (x+y),
    ##           and being far enough out that we can move from white to black sqares predictably)
    ## Budgeting: 2 queries for point total
    ##            10 binary searches, each over 2M possibilities =~ 25*10 = 250
    ##            10 binary searches, each over 2M possibilities =~ 25*10 = 250
    ##            Room for some sloppiness

    ## Step 1
    a1 = query(-8M,0)
    a2 = query(-8M+1,0)
    N = a1 - a2

    ## Step 2
    step2query(m::I,odd::Bool=false) = query(M-1+m+(odd ? 1 : 0),-3M-1+m)
    coordsums::VI = []
    ll = 0; llv = step2query(ll)
    uu = 2M+2; uuv = step2query(uu)
    slope = -N
    while (length(coordsums) < N)
        l,u = ll,uu
        while u-l > 1
            m::I = (u+l)>>1
            v::I = step2query(m) 
            if v == llv + slope * (m-ll); l = m; else; u = m; end
        end
        v1::I = step2query(l); v1b::I = step2query(l,true); v2::I = step2query(u)
        ## Gap between v1b and v1 should be slope/2 + N/2 --> slope = 2(v1b-v1)-N
        ## Gap between v2 and v1b should be slope/2 - N/2 --> slope = 2(v2-v1b)+N
        slopea = 2*(v1b-v1)-N; slopeb = 2*(v2-v1b)+N
        while slope < slopea; push!(coordsums,2*l-2*M-2); slope += 2; end
        while slope < slopeb; push!(coordsums,2*l-2*M-1); slope += 2; end
        ll = u; llv = v2
    end

    ## Step 3
    step3query(m::I,odd::Bool=false) = query(-M+1-m-(odd ? 1 : 0),-3M-1+m)
    coordiffs::VI = []
    ll = 0; llv = step3query(ll)
    uu = 2M+2; uuv = step3query(uu)
    slope = -N
    while (length(coordiffs) < N)
        l,u = ll,uu
        while u-l > 1
            m::I = (u+l)>>1
            v::I = step3query(m) 
            if v == llv + slope * (m-ll); l = m; else; u = m; end
        end
        v1::I = step3query(l); v1b::I = step3query(l,true); v2::I = step3query(u)
        slopea = 2*(v1b-v1)-N; slopeb = 2*(v2-v1b)+N
        while slope < slopea; push!(coordiffs,2M-2l+2); slope += 2; end
        while slope < slopeb; push!(coordiffs,2M-2l+1); slope += 2; end
        ll = u; llv = v2
    end

    ready()

    while(true)
        (done,x,y) = getRequest()
        if done; break; end
        ss,sd = x+y,x-y
        ans::I = sum(abs(xx-ss) for xx in coordsums) + sum(abs(xx-sd) for xx in coordiffs)
        @assert ans & 1 == 0
        reqAns(ans ÷ 2)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,Nmax,M,R = gis()
    for qq in 1:tt
        #solveSmall(Nmax,M,R)
        solveLarge(Nmax,M,R)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


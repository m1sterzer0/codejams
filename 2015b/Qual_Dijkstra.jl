
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

function buildQuaternionTable()
    ## (1,i,j,k,-1,-i,-j,-k) --> (1,2,3,4,5,6,7,8)
    a = fill(1,8,8)
    a[1,1:4] = [1,2,3,4]
    a[2,1:4] = [2,5,4,7]
    a[3,1:4] = [3,8,5,2]
    a[4,1:4] = [4,3,6,5]
    a[5:8,5:8] = a[1:4,1:4]  ## Negatives commute and 2 negatives cancel
    for i in 5:8
        for j in 1:4
            a[i,j] = a[i-4,j] + 4
            if a[i,j] > 8; a[i,j] -= 8; end
            a[j,i] = a[j,i-4] + 4
            if a[j,i] > 8; a[j,i] -= 8; end
        end
    end
    return a 
end            

function findi(qq,arr)
    val = 1
    for (i,v) in enumerate(arr)
        val = qq[val,v]
        if val == 2; return i; end
    end
    return -1
end

function findk(qq,arr)
    val = 1
    for (i,v) in enumerate(reverse(arr))
        val = qq[v,val]
        if val == 4; return i; end
    end
    return -1
end

function solve(L::I,X::I,C::String)::String
    mtable = buildQuaternionTable()
    char2code(x) = x == 'i' ? 2 : x == 'j' ? 3 : 4
    earr::VI = [char2code(x) for x in C]
    earrprod = 1
    for ee in earr; earrprod = mtable[earrprod,ee]; end
    xmod = X % 4

    ## Check if string product is -1
    if (earrprod == 1) || (xmod == 0) ||
        (xmod in [1,3] && earrprod != 5) ||
        (xmod == 2 && earrprod == 5); return "NO"; end
        
    ## Note that x^4 == 1 for all elements in Q8, so we only need to look at 4 copies of the string
    prelen = findi(mtable,repeat(earr,4))
    postlen = findk(mtable,repeat(earr,4))
    if (prelen > 0) && (postlen > 0) && (prelen+postlen < L*X)
        return "YES"; else; return "NO"; end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        L,X = gis()
        C = gs()
        ans = solve(L,X,C)
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


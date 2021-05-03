
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

function editDistance(s::String,t::String)::I
    ## Reference https://en.wikipedia.org/wiki/Levenshtein_distance
    m = length(s)
    n = length(t)
    d::Array{Int64,2} = fill(0,m+1,n+1)
    for i in 1:m; d[i+1,1] = i; end
    for j in 1:n; d[1,j+1] = j; end
    for j in 1:n
        for i in 1:m
            scost = s[i] == t[j] ? 0 : 1
            d[i+1,j+1] = min(d[i,j+1]+1,d[i+1,j]+1,d[i,j]+scost)
        end
    end
    return d[m+1,n+1]
end

function solveSmall(C::String,J::String)::String
    trylist = ["X","Y","Z"]
    for i in 2:6
        base = copy(trylist)
        for b in base
            push!(trylist,b*"X")
            push!(trylist,b*"Y")
            push!(trylist,b*"Z")
        end
    end
    best,bestsum,bestdiff = "",length(C)+length(J),abs(length(C)-length(J))
    for s in trylist
        ec = editDistance(s,C)
        ej = editDistance(s,J)
        if ec+ej < bestsum || ec+ej == bestsum && abs(ec-ej) < bestdiff
            best = s
            bestsum = ec+ej
            bestdiff = abs(ec-ej)
        end
    end
    return best
end

function solveLarge(C::String,J::String)
    if C == J; return C; end
    if length(J) < length(C); (C,J) = (J,C); end
    s,t = C,J
    m = length(s)
    n = length(t)
    d::Array{Int64,2} = fill(0,m+1,n+1)
    for i in 1:m; d[i+1,1] = i; end
    for j in 1:n; d[1,j+1] = j; end
    for j in 1:n
        for i in 1:m
            scost = s[i] == t[j] ? 0 : 1
            d[i+1,j+1] = min(d[i,j+1]+1,d[i+1,j]+1,d[i,j]+scost)
        end
    end
    w = t; ss::Vector{String} = [ w ]; i=m; j=n
    while (i > 0 || j > 0)
        if (i>0 && j>0) && (s[i] == t[j]) && (d[i+1,j+1] == d[i,j])
            i -= 1; j -=1
        elseif (i>0 && j>0) && (s[i] != t[j]) && (d[i+1,j+1] == d[i,j]+1)
            w = w[1:j-1]*s[i:i]*w[j+1:end]
            push!(ss,w)
            i -= 1; j -= 1
        elseif j > 0 && d[i+1,j+1] == d[i+1,j] + 1
            w = w[1:j-1]*w[j+1:end]
            push!(ss,w)
            j -= 1
        elseif i > 0 && d[i+1,j+1] == d[i,j+1] + 1
            w = w[1:j]*s[i:i]*w[j+1:end]
            push!(ss,w)
            i -= 1
        end
    end
    #print("DBG: $ss\n")
    return ss[length(ss)÷2+1]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        C,J = gss()
        #ans = solveSmall(C,J)
        ans = solveLarge(C,J)
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


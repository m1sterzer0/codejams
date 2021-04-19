
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

function processRow(cake2::Array{Char,2},ri::I,rj::I,charrow::VC,C::I)
    lastCol::I = 1
    for j::I in 1:C
        if charrow[j] != '?'; cake2[ri:rj,lastCol:j] .= charrow[j]; lastCol = j+1; end
    end
    cake2[ri:rj,lastCol:C] .= charrow[lastCol-1]
end

function solve(R::I,C::I,cake::Array{Char,2})::VS
    ans::VS = []
    lastRow::I = 1
    cake2::Array{Char,2} = fill('.',R,C)
    for i::I in 1:R
        if count(x->x=='?',cake[i,:]) == C; continue; end
        processRow(cake2,lastRow,i,cake[i,:],C)
        lastRow = i+1
    end
    for i in lastRow:R; cake2[i,:] = cake2[lastRow-1,:]; end
    return [join(cake2[i,:],"") for i in 1:R]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = gis()
        cake = fill('.',R,C)
        for i in 1:R; cake[i,:] = [x for x in gs()]; end
        ans = solve(R,C,cake)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


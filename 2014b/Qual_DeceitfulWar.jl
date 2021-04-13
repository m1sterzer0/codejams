
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

function solve(N::I,naomi::VF,ken::VF)::String
    naomisort = sort(naomi,rev=true)
    kensort = sort(ken,rev=true)

    kenWins = 0; kenptr = 1
    for i in 1:N
        if kensort[kenptr] > naomisort[i]; kenWins += 1; kenptr += 1; end
    end
    fairWins = N - kenWins

    deceitfulWins = 0; naomiptr = 1
    for i in 1:N
        if naomisort[naomiptr] > kensort[i]; deceitfulWins += 1; naomiptr+=1; end
    end
    
    return "$deceitfulWins $fairWins"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        naomi = gfs()
        ken = gfs()
        ans = solve(N,naomi,ken)
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


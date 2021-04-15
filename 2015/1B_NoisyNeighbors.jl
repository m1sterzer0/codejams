
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

function solve(R::I,C::I,N::I)::I
    if R > C; (R,C) = (C,R); end
    unh = (R-1)*C + (C-1)*R
    gaps = R*C - N
    #print("R:$R C:$C\n")
    if R == 1 && C % 2 == 0
        v = min(gaps,C ÷ 2 - 1); unh -= 2 * v; gaps -= v
        unh -= gaps
    elseif R == 1 && C % 2 == 1
        v = min(gaps,(C-1) ÷ 2); unh -= 2 * v; gaps -= v
        unh -= gaps
    elseif R == 2
        v = min(gaps,C-2); unh -= 3 * v; gaps -= v
        v = min(gaps,2);   unh -= 2 * v; gaps -= v
        unh -= gaps
    elseif R*C % 2 == 0
        v = min(gaps,(R-2)*(C-2)÷2); unh -= 4 * v; gaps -= v
        v = min(gaps,R+C-4);         unh -= 3 * v; gaps -= v
        v = min(gaps,2);             unh -= 2 * v; gaps -= v
        unh -= gaps
    else
        unh1,unh2 = unh,unh
        v = min(gaps,((R-2)*(C-2)-1)÷2); unh1 -= 4 * v; gaps -= v
        v = min(gaps,R+C-2);             unh1 -= 3 * v; gaps -= v
        unh1 -= gaps
        gaps = R*C - N
        v = min(gaps,((R-2)*(C-2)+1)÷2); unh2 -= 4 * v; gaps -= v
        v = min(gaps,R+C-6);             unh2 -= 3 * v; gaps -= v
        v = min(gaps,4);                 unh2 -= 2 * v; gaps -= v            
        unh2 -= gaps
        unh = min(unh1,unh2)
    end
    return max(0,unh)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,N = gis()
        ans = solve(R,C,N)
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


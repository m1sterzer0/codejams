
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

function compress(last::VPI, cur::VPI)
    sort!(cur,rev=true)
    empty!(last)
    while !isempty(cur)
        while !isempty(last) && last[end][2] <= cur[end][2]; pop!(last); end
        push!(last,cur[end])
        pop!(cur)
    end
end


function solve(P::I,Q::I,N::I,H::VI,G::VI)::I
    lastnk::VPI = [(0,0)]
    lastk::VPI = []
    curnk::VPI = []
    curk::VPI  = []

    for i in 1:N
        towerShots::I = (H[i] + Q - 1) ÷ Q
        myShots::I = (H[i] - (towerShots-1)*Q + P - 1) ÷ P

        for (g,s) in lastnk; push!(curnk,(g,s+towerShots));end    ## (last,cur) = (nk,nk) case.  Here we bank shots, and we go first.
        for (g,s) in lastk;  push!(curnk,(g,s+towerShots-1));end  ## (last,cur) = (k,nk)  case.  Here we bank shots, but tower goes first.

        netShots = towerShots-myShots
        for (g,s) in lastnk;
            if s+netShots >= 0; push!(curk,(g+G[i],s+netShots)); end
        end
        netShots -= 1 ## (for the kill->kill case, we get even one fewer free shot)
        for (g,s) in lastk;
            if s+netShots >= 0; push!(curk,(g+G[i],s+netShots)); end
        end
        compress(lastnk,curnk)
        compress(lastk,curk)
    end
    ans = 0
    if !isempty(lastnk); ans = max(ans,lastnk[end][1]); end
    if !isempty(lastk);  ans = max(ans,lastk[end][1]); end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        P,Q,N = gis()
        H::VI = fill(0,N)
        G::VI = fill(0,N)
        for i in 1:N
            H[i],G[i] = gis()
        end
        ans = solve(P,Q,N,H,G)
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


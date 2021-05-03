
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

function countzeros(NN::I)::I
    res::I,pv::I = 0,1
    while (NN > pv)
        if NN & pv == 0; res += 1; end
        pv = pv << 1
    end
    return res
end

function solve(N::I)
    NN::I = N
    while (NN + countzeros(NN) > N); NN -= 1; end
    K::I,left::Bool,ans::VPI = 0,true,[]
    for i::I in 1:60
        if (1 << (i-1)) & NN != 0;
            K += (1<<(i-1))
            if left; for j::I in 1:i; push!(ans,(i,j)); end
            else; for j::I in i:-1:1; push!(ans,(i,j)); end
            end
            left = !left
        else
            K += 1
            if left; push!(ans,(i,1)); else; push!(ans,(i,i)); end
        end
        if K == N; break; end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        N = gi()
        ans = solve(N)
        for (x,y) in ans; print("$x $y\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


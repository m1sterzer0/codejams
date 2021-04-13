
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

function dodfs(n::I,t::I,N::I,adjm::Array{Bool,2},sb::VI)
    sb[n] = 1
    if n != t  ## Don't trace through t
        for i in 1:N
            if sb[i] == 0 && adjm[n,i]
                dodfs(i,t,N,adjm,sb)
            end
        end
    end
end

function tryit(perm::VI,A::I,N::I,adjm::Array{Bool,2},sb::VI)::Bool
    fill!(sb,0)
    cur = perm[1]; sb[cur] = 2
    for v in perm[2:end]
        if adjm[v,cur]; cur = v; end
        sb[v] = 2
    end
    if cur == A;
        for i in 1:N
            if sb[i] == 0 && adjm[i,A]; return false; end
        end
        return true
    end
    if sb[A] == 2; return false; end
    dodfs(A,cur,N,adjm,sb)
    if 0 ∉ sb; return true; end
    for i in 1:N
        if sb[i] == 0 && adjm[i,cur]; return false; end
    end
    return true
end

function solve(N::I,A::I,board::Array{Char,2})::String
    A += 1
    adjm::Array{Bool,2} = fill(false,N,N)
    sb::VI = fill(0,N)
    for i in 1:N; for j in 1:N
        if board[i,j] == 'Y'; adjm[i,j] = true; end
    end; end
    dodfs(A,-1,N,adjm,sb)
    if 0 in sb; return "IMPOSSIBLE"; end
    perm::VI = []
    for i in 1:N
        for j in 1:N
            if j in perm; continue; end
            push!(perm,j)
            if tryit(perm,A,N,adjm,sb); break; end
            pop!(perm)
        end
    end
    ans = join([x-1 for x in perm]," ")
    return "$ans"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,A = gis()
        board::Array{Char,2} = fill('.',N,N)
        for i in 1:N; board[i,:] = [x for x in gs()]; end
        ans = solve(N,A,board)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

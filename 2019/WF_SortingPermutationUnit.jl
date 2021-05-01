
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

function rotate(p::VI,N::I,m::I,moves::VI)
    m2 = m
    while m2 >= 27; push!(moves,5); m2 -= 27; end
    while m2 >= 9; push!(moves,4);  m2 -= 9; end
    while m2 >= 3; push!(moves,3);  m2 -= 3; end
    while m2 >= 1; push!(moves,2);  m2 -= 1; end
    indices::VI = [i - m + (i <= m ? N-1 : 0) for i in 1:N-1]
    p[1:N-1] = [p[x] for x in indices]
end

function swap(p::VI,N::I,moves::VI); push!(moves,1); p[N-1],p[N] = p[N],p[N-1]; end

function findMisplaced(p::VI,stidx::I,N::I)
    for k in N-1:-1:1
        expected = k >= stidx ? 1 + k-stidx : N + k-stidx
        if expected != p[k]; return N-1-k; end
    end
    return -1
end

function solvePerm(p::VI,N::I,ans::VS)
    pp::VPI = [(p[i],i) for i in 1:N]
    sort!(pp)
    p2::VI = fill(0,N)
    for (i,(x,y)) in enumerate(pp); p2[y] = i; end  ## Now we have broken ties
    stidx = 1
    moves::VI = []
    while(true)
        if p2[N] != N
            targspot = stidx+p2[N]-1
            if targspot > N-1; targspot -= N-1; end
            if targspot != N-1
                m::I = N-1-targspot
                rotate(p2,N,m,moves)
                stidx += m; if stidx > N-1; stidx -= N-1; end
            end
            swap(p2,N,moves)
            continue
        end
        m = findMisplaced(p2,stidx,N)
        if m >= 0
            if m > 0
                rotate(p2,N,m,moves)
                stidx += m; if stidx > N-1; stidx -= N-1; end
            end
            swap(p2,N,moves)
            continue
        end
        ## All we need to do is rotate stidx to the top and we are done
        if stidx != 1; rotate(p2,N,N-stidx,moves); end
        break
    end
    pushfirst!(moves,length(moves))
    push!(ans,join(moves," "))
end

function solve(P::I,S::I,K::I,N::I,A::Array{I,2})::VS
    ans::VS = []
    if N == 2
        push!(ans,"1")
        push!(ans,"2 1")
        for i in 1:K; push!(ans,A[i,1] <= A[i,2] ? "0" : "1"); end
    else
        numperm = N <= 3 ? 2 : N <= 9 ? 3 : N <= 27 ? 4 : 5
        push!(ans,"$numperm")
        a = collect(1:N); (a[end],a[end-1]) = (a[end-1],a[end]);    push!(ans,join(a," "))
        a = vcat([1 + (1*(N-1)+x-1)   % (N-1) for x in 0:N-2],[N]); push!(ans,join(a," "))
        if N > 3; a = vcat([1 + (3*(N-1)+x-3)   % (N-1) for x in 0:N-2],[N]); push!(ans,join(a," ")); end
        if N > 9; a = vcat([1 + (9*(N-1)+x-9)   % (N-1) for x in 0:N-2],[N]); push!(ans,join(a," ")); end
        if N > 27; a = vcat([1 + (27*(N-1)+x-27) % (N-1) for x in 0:N-2],[N]); push!(ans,join(a," ")); end
        for i in 1:K; p::VI = A[i,:]; solvePerm(p,N,ans); end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        P,S,K,N = gis()
        A::Array{I,2} = fill(0,K,N)
        for i in 1:K; A[i,:] = gis(); end
        ans = solve(P,S,K,N,A)
        for l in ans; println(l); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


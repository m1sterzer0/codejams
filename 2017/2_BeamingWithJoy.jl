
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

################################################################
## BEGIN Twosat from geeks for geeks
## https://www.geeksforgeeks.org/2-satisfiability-2-sat-problem/
## https://cp-algorithms.com/graph/2SAT.html
## Assumes 1:n code the true values of the variables, and n+1:2n code the complements
################################################################
function twosat(n::Int64,m::Int64,a::Array{Int64},b::Array{Int64})
    adj = [[] for i in 1:2n]
    adjInv = [[] for i in 1:2n]
    visited = fill(false,2n)
    visitedInv = fill(false,2n)
    s = Int64[]
    scc = fill(0,2n)
    counter = 1

    function addEdges(x::Int64,y::Int64); push!(adj[x],y); end

    function addEdgesInverse(x::Int64,y::Int64); push!(adjInv[y],x); end

    function dfsFirst(u::Int64)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::Int64)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        scc[u] = counter
    end

    ### Start the main routine
    ### Build the impplication graph
    for i in 1:m
        na = a[i] > n ? a[i] - n : a[i] + n
        nb = b[i] > n ? b[i] - n : b[i] + n
        addEdges(na,b[i])
        addEdges(nb,a[i])
        addEdgesInverse(na,b[i])
        addEdgesInverse(nb,a[i])
    end

    ### Kosaraju 1
    for i in 1:2n
        if !visited[i]; dfsFirst(i); end
    end

    ### Kosaraju 2
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end

    assignment = fill(false,n)
    for i in 1:n
        if scc[i] == scc[n+i]; return (false,[]); end
        assignment[i] = scc[i] > scc[n+i]
    end

    return (true,assignment)
end

################################################################
## END Twosat from geeks for geeks
################################################################

######################################################################################################
### This feels like a simple 2-SAT problem.
### The only key observation is that a maximum of two lasers can hit the same square; otherwise they
### would run into one another.
######################################################################################################

function move(gr,i,j,R,C,d,arr)
    if i <= 0 || j <= 0 || i > R || j > C; return true; end
    if gr[i,j] in "|-"; return false; end
    if gr[i,j] == '#'; return true; end
    movedir = d
    if gr[i,j] == '.'; push!(arr,(i,j)); end
    if gr[i,j] == '/';  movedir = d == 'N' ? 'E' : d == 'S' ? 'W' : d == 'W' ? 'S' : 'N'; end
    if gr[i,j] == '\\'; movedir = d == 'N' ? 'W' : d == 'S' ? 'E' : d == 'W' ? 'N' : 'S'; end
    if movedir == 'N'; return move(gr,i-1,j,R,C,movedir,arr); end
    if movedir == 'S'; return move(gr,i+1,j,R,C,movedir,arr); end
    if movedir == 'W'; return move(gr,i,j-1,R,C,movedir,arr); end
    if movedir == 'E'; return move(gr,i,j+1,R,C,movedir,arr); end
end

function solvegrid(lasers::VPI,forcedLasers::Vector{Tuple{I,I,Char}},dots::VPI,
                   db2::Dict{PI,Vector{Tuple{I,I,Char}}})::Tuple{Bool,Vector{Tuple{I,I,Char}}}
    n::I = length(lasers)
    m::I = length(dots)
    lidx::Dict{PI,I} = Dict{PI,I}()
    for (i,l) in enumerate(lasers); lidx[l] = i; end

    ## Build the conjunctions
    a::VI = []; b::VI = []
    for (k,v) in db2
        (i1,j1,d1) = v[1]
        (i2,j2,d2) = length(v) == 1 ? (i1,j1,d1) : v[2]
        n1 = lidx[(i1,j1)] + (d1 == 'H' ? 0 : n)
        n2 = lidx[(i2,j2)] + (d2 == 'H' ? 0 : n)
        push!(a,n1); push!(b,n2)
    end

    ## Forced lasers
    for (i1,j1,d1) in forcedLasers
        n1 = lidx[(i1,j1)] + (d1 == 'H' ? 0 : n)
        push!(a,n1); push!(b,n1)
    end

    ## Now do the twosat
    (success::Bool,assignment::VB) = twosat(n,length(a),a,b)
    if !success; return false,[]; end
    ans::Vector{Tuple{I,I,Char}} = []
    for i in 1:n
        (j,k) = lasers[i]
        d = assignment[i] ? '-' : '|'
        push!(ans,(j,k,d))
    end
    return true,ans
end

function solve(R::I,C::I,gr::Array{Char,2})::VS
    dots::VPI   = [(i,j) for i in 1:R for j in 1:C if gr[i,j] == '.']
    lasers::VPI = [(i,j) for i in 1:R for j in 1:C if gr[i,j] in "|-"]

    db2::Dict{PI,Vector{Tuple{I,I,Char}}} = Dict{PI,Vector{Tuple{I,I,Char}}}()
    for (i,j) in dots; db2[(i,j)] = []; end

    forcedLasers::Vector{Tuple{I,I,Char}} = []
    for (i,j) in lasers
        arrns::VPI,arrew::VPI = [],[]
        ns::Bool = move(gr,i-1,j,R,C,'N',arrns) && move(gr,i+1,j,R,C,'S',arrns)
        ew::Bool = move(gr,i,j-1,R,C,'W',arrew) && move(gr,i,j+1,R,C,'E',arrew)
        if ns
            unique!(arrns)
            for (k,l) in arrns; push!(db2[(k,l)],(i,j,'V')); end
            if !ew; push!(forcedLasers,(i,j,'V')); end
        end
        if ew
            unique!(arrew)
            for (k,l) in arrew; push!(db2[(k,l)],(i,j,'H')); end
            if !ns; push!(forcedLasers,(i,j,'H')); end
        end
        if !ns && !ew; return ["IMPOSSIBLE"]; end
    end

    ## Now we check if any of the dots are empty
    for (i,j) in dots
        if length(db2[(i,j)]) == 0; return ["IMPOSSIBLE"]; end 
    end

    ## There is hope, now we just need to run 2sat
    success,vals = solvegrid(lasers,forcedLasers,dots,db2)
    if !success; return ["IMPOSSIBLE"]; end

    ## Wow, it worked, print crap out
    ans::VS = ["POSSIBLE"]
    gr2 = copy(gr)
    for (i,j,d) in vals; gr2[i,j] = d; end
    for i in 1:R; push!(ans,join(gr2[i,:],"")); end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        gr::Array{Char,2} = fill('.',R,C)
        for i in 1:R; gr[i,:] = [x for x in gs()]; end
        ans = solve(R,C,gr)
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


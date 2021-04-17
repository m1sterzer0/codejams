
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

function processSubset(s::String,subsets::Dict{String,VI},
                       compList::VPI,st::PI)
    if haskey(subsets,s); return; end
    subsets[s] = fill(1000,26)  ## Worst possible cost is 625, so 1000 is just as good as inf
    v::VI = subsets[s]
    v[1] = 0
    sqidx::I = st[1] == st[2] ? st[1]+1 : 0
    if sqidx > 0; v[sqidx] = (sqidx-1)^2; end 
    for (i::I,c::Char) in enumerate(s)
        if c == 'A'; continue; end
        st2::PI = (st[1]-compList[i][1], st[2]-compList[i][2])
        if 0 in st2; continue; end
        substr::String = prod([s[1:i-1],c-1,s[i+1:end]])
        if !haskey(subsets,substr); processSubset(substr,subsets,compList,st2); end
        v2::VI = subsets[substr]
        for i::I in 1:min(st2[1],st2[2])
            v[i+1] = min(v[i+1],v2[i+1])
            if sqidx > 1
                v[sqidx] = min(v[sqidx], v2[i+1] + (sqidx-(i+1))^2)
            end
        end
    end
end


function solve(N::I,initsb::Array{I,2})
    ### Build the graph from workers to/from jobs
    ### Workers have nodes 1:N
    ### Jobs have nodes N+1:2N
    adjL::VVI = [VI() for i in 1:2N]
    for (i,j) in Iterators.product(1:N,1:N)
        if initsb[i,j] == 0; continue; end
        push!(adjL[i],N+j); push!(adjL[N+j],i)
    end

    ## Get the components of the graph
    components::VVI = []
    visited::VB = fill(false,2N)
    for i in 1:2N
        if visited[i]; continue; end
        comp::VI = []; visited[i] = true; q::VI = [i]
        while !isempty(q)
            n = popfirst!(q)
            push!(comp,n)
            for c in adjL[n]
                if visited[c]; continue; end
                visited[c] = true;
                push!(q,c)
            end
        end
        push!(components,comp)
    end

    ### Create a dictionary of the components by the number of workers and the number of of machines
    sb::Dict{PI,I} = Dict{PI,I}()
    cost::I = -sum(initsb); remaining::I = N
    for c in components
        w = count(x -> x<=N, c)
        m = length(c)-w
        if w == m
            cost += m*m; remaining -= m;
        else
            sb[(w,m)] = haskey(sb,(w,m)) ? sb[(w,m)]+1 : 1
        end
    end
    if remaining == 0; return cost; end
    ### Since every subset can be represented at most 25 times in the lineup, it is convenient to use the
    ### 26 upper-case letters as a code for how many of that type of subset remain
    subsets::Dict{String,VI} = Dict{String,VI}()
    compList::VPI = [k for (k,v) in sb]
    startingSubset::String = prod(['A'+v for (k,v) in sb])
    processSubset(startingSubset,subsets,compList,(remaining,remaining))
    cost += subsets[startingSubset][remaining+1]
    return cost
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        sb::Array{I,2} = fill(0,N,N)
        for i in 1:N
            sb[i,:] = [parse(Int64,x) for x in gs()]
        end
        ans = solve(N,sb)
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


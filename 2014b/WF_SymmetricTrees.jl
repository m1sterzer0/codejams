
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

function getCenter(N::I,adj::Vector{SI})::VI 
    if N == 1; return [1]; end
    if N == 2; return [1,2]; end
    edgecnt::VI = [length(adj[i]) for i in 1:N]
    numleft = N
    q = [x for x in 1:N if edgecnt[x] == 1]
    while(true)
        if numleft <= 2; return q; end
        newq = []
        for qq in q
            numleft -= 1
            for e in adj[qq]
                if edgecnt[e] > 1
                    edgecnt[e] -= 1
                    if edgecnt[e] == 1; push!(newq,e); end
                end
            end
        end
        q = newq[:]
    end
end

function doTraverse(n::I,p::I,adj::Vector{SI},color::VC,sbCenterOk::VB,sbRootOk::VB)::String
    prefix = join(['d',color[n]])
    meat = ""
    suffix = "u"
    childNodes::VI = []
    for c in adj[n]
        if c == p; continue; end
        push!(childNodes,c)
    end
    if length(childNodes) == 0
        sbCenterOk[n]    = true
        sbRootOk[n]      = true
    elseif length(childNodes) == 1
        meat = doTraverse(childNodes[1],n,adj,color,sbCenterOk,sbRootOk)
        sbCenterOk[n]    = sbCenterOk[childNodes[1]]
        sbRootOk[n]      = sbCenterOk[n]
    else
        ## Don't stick the recursion in an iterator -- it chews up the stack
        #bufstrings::Vector{Tuple{String,Int64}} = [(doTraverse(x,n,adj,color,sbCenterOk,sbRootOk),x) for x in childNodes]
        bufstrings::Vector{Tuple{String,I}} = []

        for x in childNodes
            ss = doTraverse(x,n,adj,color,sbCenterOk,sbRootOk)
            push!(bufstrings,(ss,x))
        end

        sort!(bufstrings)
        meat = prod(x[1] for x in bufstrings)
        badNodes = []
        idx = 1
        while idx <= length(childNodes)
            if idx+1 <= length(childNodes) && bufstrings[idx][1] == bufstrings[idx+1][1]
                idx += 2
            else
                push!(badNodes,bufstrings[idx][2])
                idx += 1
            end
        end
        if length(badNodes) == 0
            sbCenterOk[n]    = true
            sbRootOk[n]      = true
        elseif length(badNodes) == 1 && sbCenterOk[badNodes[1]]
            sbCenterOk[n]    = true
            sbRootOk[n]      = true
        elseif length(badNodes) == 2 && sbCenterOk[badNodes[1]] && sbCenterOk[badNodes[2]]
            sbRootOk[n]      = true
        end
    end
    return prefix*meat*suffix
end

function solve(N::I,precolor::VC,X::VI,Y::VI)::String
    color::VC = copy(precolor); push!(color,'.')
    adj::Vector{SI} = [SI() for i in 1:N+1]
    for i in 1:N-1
        push!(adj[X[i]],Y[i])
        push!(adj[Y[i]],X[i])
    end
    sbCenterOk::VB = fill(false,N+1)
    sbRootOk::VB = fill(false,N+1)
    center = getCenter(N,adj)
    if length(center) == 1
        n1 = center[1]
        doTraverse(n1,-1,adj,color,sbCenterOk,sbRootOk)
        return sbRootOk[n1] ? "SYMMETRIC" : "NOT SYMMETRIC"
    else
        ## Splice in a dummy node between these two that acts as the virtual root
        ## of the tree on the center line.
        n1,n2 = center[1],center[2]
        delete!(adj[n1],n2)
        delete!(adj[n2],n1)
        push!(adj[n1],N+1)
        push!(adj[N+1],n1)
        push!(adj[n2],N+1)
        push!(adj[N+1],n2)
        doTraverse(N+1,-1,adj,color,sbCenterOk,sbRootOk)
        return sbRootOk[N+1] ? "SYMMETRIC" : "NOT SYMMETRIC"
    end
end

function gencase(Nmin::I,Nmax::I,Cmin::I,Cmax::I)
    N = rand(Nmin:Nmax)
    nc = rand(Cmin:Cmax)
    scolors = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[1:nc]
    acolors = [x for x in scolors]
    colors::VC = [rand(acolors) for i in 1:N]
    nodes = shuffle(collect(1:N))
    X::VI = fill(0,N-1)
    Y::VI = fill(0,N-1)
    for i in 2:N
        j = rand(1:i-1)
        X[i-1] = nodes[i]
        Y[i-1] = nodes[j]
    end
    return (N,colors,X,Y)
end

function test(ntc::I,Nmin::I,Nmax::I,Cmin::I,Cmax::I)
    for ttt in 1:ntc
        (N,colors,X,Y) = gencase(Nmin,Nmax,Cmin,Cmax)
        ans = solve(N,colors,X,Y)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        color::VC = []
        for i in 1:N; push!(color,gs()[1]); end
        X::VI = fill(0,N-1)
        Y::VI = fill(0,N-1)
        for i in 1:N-1; X[i],Y[i] = gis(); end
        ans = solve(N,color,X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,2,12,1,3)


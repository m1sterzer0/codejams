######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function getCenter(N::Int64,adj::Vector{Set{Int64}}) 
    if N == 1; return [1]; end
    if N == 2; return [1,2]; end
    edgecnt::Vector{Int64} = fill(0,N)

    for i in 1:N; edgecnt[i] = length(adj[i]); end
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

function doTraverse(n::Int64,p::Int64,adj::Vector{Set{Int64}},color::Vector{Char},sbCenterOk::Vector{Bool},sbRootOk::Vector{Bool})::String
    prefix = join(['d',color[n]])
    meat = ""
    suffix = "u"
    childNodes::Vector{Int64} = []
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
        bufstrings::Vector{Tuple{String,Int64}} = []

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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        adj::Vector{Set{Int64}} = [Set{Int64}() for x in 1:N+1]
        color::Vector{Char} = fill('.',N+1)
        sbCenterOk::Vector{Bool} = fill(false,N+1)
        sbRootOk::Vector{Bool} = fill(false,N+1)
        for i in 1:N
            color[i] = readline(infile)[1]
        end
        for i in 1:N-1
            ii,jj = [parse(Int64,x) for x in split(readline(infile))]
            push!(adj[ii],jj)
            push!(adj[jj],ii)
        end
        center = getCenter(N,adj)
        if length(center) == 1
            n1 = center[1]
            doTraverse(n1,-1,adj,color,sbCenterOk,sbRootOk)
            res = sbRootOk[n1] ? "SYMMETRIC" : "NOT SYMMETRIC"
            print("$res\n")
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
            res = sbRootOk[N+1] ? "SYMMETRIC" : "NOT SYMMETRIC"
            print("$res\n")
        end
    end
end

main()

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function feasible(cand::Int64,adj::Vector{Set{Int64}},state::Vector{Int64},stack::Vector{Int64})::Bool
    mystack = stack[:]
    mystate = state[:]
    while !isempty(mystack) && mystack[end] ∉ adj[cand]
        mystate[mystack[end]] = 2
        pop!(mystack)
    end
    if isempty(mystack); return false; end

    function dfs(n::Int64)
        for c in adj[n]
            if mystate[c] == 0
                mystate[c] = 1
                dfs(c)
            end
        end
    end
    for n in mystack; dfs(n); end
    if 0 in mystate; return false; end
    return true;
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(readline(infile))]

        zips = zeros(Int64,N)
        for i in 1:N; zips[i] = parse(Int64,readline(infile)); end

        adj::Vector{Set{Int64}} = Vector{Set{Int64}}()
        for i in 1:N; push!(adj,Set{Int64}()); end
        for i in 1:M
            n1,n2 = [parse(Int64,x) for x in split(readline(infile))]
            push!(adj[n1],n2)
            push!(adj[n2],n1)
        end

        prioritylist::Vector{Tuple{Int64,Int64}} = [(zips[i],i) for i in 1:N]
        sort!(prioritylist)

        ## Process first node
        bestnode = prioritylist[1][2]

        nodeorder = [bestnode]
        state = zeros(Int64,N); state[bestnode] = 1
        stack::Vector{Int64} = [bestnode]

        for i in 1:N-1
            for (_zip,j) in prioritylist
                if state[j] != 0; continue; end
                if !feasible(j,adj,state,stack); continue; end
                while stack[end] ∉ adj[j]; state[stack[end]] = 2; pop!(stack); end
                state[j] = 1
                push!(stack,j)
                push!(nodeorder,j)
                break
            end
        end
        anszips = [zips[x] for x in nodeorder]
        ans = join(anszips)
        print("$ans\n")
    end
end

main()
        


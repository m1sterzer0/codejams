using Printf

######################################################################################################
### We do observe that if there are fewer suits than stacks, we have an autowin.  If we have 
### more suits than stacks, we have an auto lose. 
### This is just brute force using backtracking
######################################################################################################

mutable struct Gs
    moves::Vector{Int64}
    bestPerSuit::Vector{Tuple{Int64,Int64}}  ## {best rank, stackIdx}
    idx::Vector{Int64}
    topc::Vector{Tuple{Int64,Int64}}
end

function Base.copy(g::Gs)::Gs
    return Gs(copy(g.moves), copy(g.bestPerSuit), copy(g.idx), copy(g.topc))
end

function autoPlay(B::Array{Tuple{Int64,Int64},2},N::Int64,C::Int64,g::Gs)

    ## Do my moves
    while !isempty(g.moves)
        i = pop!(g.moves)
        if g.idx[i] == -1
            g.topc[i] = (-1,-1)
        elseif g.idx[i] == C
            g.idx[i] = -1
            g.topc[i] = (-1,-1)
        else
            g.idx[i] += 1
            (a,b) = B[i,g.idx[i]]
            g.topc[i] = (a,b)
            (v,bi) = g.bestPerSuit[b]
            if v == -1
                g.bestPerSuit[b] = (a,i)
            elseif a < v
                push!(g.moves,i)
            else
                g.bestPerSuit[b] = (a,i)
                push!(g.moves,bi)
            end
        end
    end

    ## Check for win
    weWon = true
    for i in 1:N
        if g.idx[i] != -1 && g.idx[i] != C
            weWon = false
            break
        end
    end
    if weWon; return true; end

    ## Check for loss
    empty = 0
    for i in 1:N
        if g.topc[i][1] == -1
            empty = i; break
        end
    end
    if empty == 0; return false; end

    ## Iterate through choices to fill empty row
    for i in 1:N
        if g.idx[i] == -1; continue; end
        if g.idx[i] == C; continue; end
        g2 = copy(g)
        g2.topc[empty] = B[i,g2.idx[i]]
        g2.idx[i] += 1
        (a,b) = B[i,g2.idx[i]]
        g2.topc[i] = (a,b)
        (v,bi) = g2.bestPerSuit[b]
        if v != -1
            if a < v
                push!(g2.moves,i)
            else
                g2.bestPerSuit[b] = (a,i)
                push!(g2.moves,bi)
            end
        end
        if autoPlay(B,N,C,g2); return true; end
    end
    return false
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin

    P = parse(Int64,readline(infile))
    Parr = [[] for i in 1:P]
    for i in 1:P
        X = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        Parr[i] = collect(zip(X[2:2:end],X[3:2:end]))
    end
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        B = fill((-1,-1),N,C)
        PP = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        for i in 1:N
            B[i,:] = Parr[PP[i]+1]
        end

        ## DEBUG, print the board
        ## print("\nDEBUG BOARD:\n")
        ## print("--------------------------\n")
        ## for cc in 1:C
        ##     str = join([@sprintf("(%2d,%d)",B[x,cc][1],B[x,cc][2]) for x in 1:N]," ")
        ##     println(str)
        ## end
        ## print("\n")

        g = Gs(Vector{Int64}(), [(-1,-1) for i in 1:50000], [1 for i in 1:N], [B[i,1] for i in 1:N])

        ## Do some prework
        for (i,(a,b)) in enumerate(g.topc)
            g.bestPerSuit[b] = max(g.bestPerSuit[b],(a,i))
        end
        for (i,(a,b)) in enumerate(g.topc)
            if  a < g.bestPerSuit[b][1]; push!(g.moves,i); end
        end
        res = autoPlay(B,N,C,g)
        println(res ? "POSSIBLE" : "IMPOSSIBLE")
    end
end

main()

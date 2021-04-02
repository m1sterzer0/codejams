function solvelucky(mysegs::Set{Int64},seglen::Vector{Int64},boards::Array{Tuple{Int64,Int64},2},R::Int64,C::Int64)::Bool
    if length(mysegs) == 1; return true; end
    badmask::Dict{Int64,Int64} = Dict{Int64,Int64}()
    exitmask::Dict{Int64,Int64} = Dict{Int64,Int64}()

    for i in mysegs; badmask[i] = 0; exitmask[i] = 0; end
    for i in 1:R-1
        for j in 1:C
            if boards[i,j][1] != 0 && boards[i,j][1] in mysegs && boards[i+1,j][1] != 0
                (s1,pos) = boards[i,j]
                mask = boards[i+1,j][1] in mysegs ? exitmask : badmask
                mask[s1] |= 1 << (pos-1)
            end
        end
    end

    while length(mysegs) > 1
        prevlen = length(mysegs)
        badmasks = [0 for i in 1:58]
        for s in mysegs; l = seglen[s]; badmasks[l] |= badmask[s]; end
        for i in 2:58
            if badmasks[i-1] & 1 != 0; badmasks[i] |= 1; end
            if badmasks[i-1] & 1<<(i-2) != 0; badmasks[i] |= 1 <<(i-1); end
            badmasks[i] |= badmasks[i-1] & (badmasks[i-1]<<1)
        end
        for i in 57:-1:1; badmasks[i] |= badmasks[i+1] & badmasks[i+1] >> 1; end
        seglist = [x for x in mysegs]
        for s in seglist; l = seglen[s]; if exitmask[s] & ~badmasks[l] != 0; delete!(mysegs,s); end; end
        if prevlen == length(mysegs); return false; end
    end
    return true
end 

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = gis()
        board::Array{Char,2} = fill('.',R,C)
        for i in 1:R; board[i,:] = [x for x in gs()]; end
        boards::Array{Tuple{Int64,Int64},2} = fill((0,0),R,C)
        seglen::Vector{Int64} = []
        lastseg,inseg,segid = 0,false,1
        for i in 1:R
            for j in 1:C
                if board[i,j] == '#'
                    if inseg; push!(seglen,segid-1); inseg = false; segid = 1; end
                elseif inseg == true
                    boards[i,j] = (lastseg,segid); segid += 1
                else
                    inseg = true; lastseg += 1; boards[i,j] = (lastseg,segid); segid += 1
                end
            end
        end

        ## Get the list of edges
        downedges = Set{Tuple{Int64,Int64}}()
        for i in 2:R-2
            for j in 2:C-1
                if board[i,j] != '#' && board[i+1,j] != '#';
                    s1 = boards[i,j][1]; s2 = boards[i+1,j][1]
                    push!(downedges,(s1,s2))
                end
            end
        end
        adjrev::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:lastseg]
        for (s1,s2) in downedges; push!(adjrev[s2],s1); end

        for caveid in "0123456789"
            cr,cc = 0,0
            for i in 1:R; for j in 1:C; if board[i,j] == caveid; cr = i; cc = j; break; end; end; end
            if cr == 0; break; end
            segid = boards[cr,cc][1]
            mysegs::Set{Int64} = Set{Int64}()
            function dfs(n::Int64)
                if n in mysegs; return; end
                push!(mysegs,n)
                for nn in adjrev[n]; dfs(nn); end
            end
            dfs(segid)
            reachable = sum(seglen[x] for x in mysegs)
            islucky = solvelucky(mysegs,seglen,boards,R,C)
            ans = "$caveid: $reachable " * (islucky ? "Lucky" : "Unlucky")
            print("$ans\n")
        end
    end
end

main()
            


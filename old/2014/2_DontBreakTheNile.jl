######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

## Adapted/translated from cp-algorithms -- this version is O(n^2) and assumes distances in an adj matrix
function denseDijkstra(s::Int64,d::Vector{Int64},p::Vector{Int64},adjm::Array{Int64,2})
    n = length(d)
    inf::Int64 = 1000000006
    fill!(d,inf)
    fill!(p,-1)
    u::Vector{Bool} = fill(false,n)
    d[s] = 0
    for i in 1:n
        v::Int64 = -1
        for j in 1:n
            if (!u[j] && (v==-1 || d[j] < d[v])); v = j; end
        end
        if d[v] == inf; break; end
        u[v] = true
        for j in 1:n
            if j == v; continue; end
            if d[j] > d[v] + adjm[v,j]
                d[j] = d[v] + adjm[v,j]
                p[j] = v
            end
        end
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        W,H,B = [parse(Int64,x) for x in split(readline(infile))]
        buildings::Array{Int64,2} = fill(0,B,4)
        for i in 1:B
            buildings[i,:] = [parse(Int64,x) for x in split(readline(infile))]
        end
        adjm::Array{Int64,2} = fill(0,B+2,B+2)

        for i in 1:B
            adjm[i,B+1] = adjm[B+1,i] = buildings[i,1]      ## Left shore to each building
            adjm[i,B+2] = adjm[B+2,i] = W-1-buildings[i,3]  ## Right short to each building
            for j in i+1:B
                dx = buildings[i,3] < buildings[j,1] ? buildings[j,1]-buildings[i,3]-1 : buildings[j,3] < buildings[i,1] ? buildings[i,1]-buildings[j,3]-1 : 0
                dy = buildings[i,4] < buildings[j,2] ? buildings[j,2]-buildings[i,4]-1 : buildings[j,4] < buildings[i,2] ? buildings[i,2]-buildings[j,4]-1 : 0
                d = max(dx,dy)
                adjm[i,j]=adjm[j,i] = d
            end
        end
        adjm[B+1,B+2] = adjm[B+2,B+1] = W
        #print("\n$adjm\n")

        d = fill(0,B+2)
        p = fill(-1,B+2)
        denseDijkstra(B+1,d,p,adjm)
        ans = d[B+2]
        print("$ans\n")
    end
end

main()

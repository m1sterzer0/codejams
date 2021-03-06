################################################################
## BEGIN UnionFind (presized Int64 version)
################################################################

struct UnionFind 
    parent::Vector{Int64}
    size::Vector{Int64}
    UnionFind(N::Int64) = new(collect(1:N),[1 for i in 1:N])
end
function Base.empty!(h::UnionFind); empty!(parent); empty!(size); end
function init(h::UnionFind,N::Int64); empty!(h); for i in 1:N; push!(parent,i); push!(size,1); end; end
function findset(h::UnionFind,x); if h.parent[x] == x; return x; end; return h.parent[x] = findset(h,h.parent[x]); end

function joinset(h::UnionFind,x,y)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

################################################################
## End UnionFind (presized Int64 version)
################################################################
function move2int(S::Int64,x::Int64,y::Int64); return (2S-1)*(x-1)+y; end
function classify(S::Int64,x::Int64,y::Int64)::Int64
    ts = 2S-1
    ans = (x,y) == (1,1)   ? 1 : (x,y) == (S,1)  ? 2 : (x,y) == (ts,S) ? 3 :
          (x,y) == (ts,ts) ? 4 : (x,y) == (S,ts) ? 5 : (x,y) == (1,S)  ? 6 :
          y == 1 ? 7 : x-y == S-1 ? 8 : x == ts ? 9 :
          y == ts ? 10 : y-x == S-1 ? 11 : x == 1 ? 12 : 13
    return ans
end

function checkbridge(S::Int64,uf::UnionFind)
    tsm1sq = (2S-1)^2
    for x in 1:5
        for y in x+1:6
            if findset(uf,tsm1sq+x) == findset(uf,tsm1sq+y); return true; end
        end
    end
    return false
end

function checkfork(S::Int64,uf::UnionFind)
    tsm1sq = (2S-1)^2
    for x in 7:10
        for y in x+1:11
            if findset(uf,tsm1sq+x) != findset(uf,tsm1sq+y); continue; end
            for z in y+1:12
                if findset(uf,tsm1sq+x) == findset(uf,tsm1sq+z); return true; end
            end
        end
    end
    return false
end

function dobridgefork(S::Int64,M::Int64,MM::Vector{Tuple{Int64,Int64}})::Tuple{Int64,Int64}
    uf = UnionFind((2S-1)^2+12)
    sb = fill(false,(2S-1)^2+12)
    tsm1 = 2S-1
    k1 = k2 = M+1
    for (i,(x,y)) in enumerate(MM)
        id = move2int(S,x,y)
        tt = classify(S,x,y)
        sb[id] = true
        if tt < 13; sb[(2S-1)^2+tt] = true; joinset(uf,id,(2S-1)^2+tt); end
        for (dx,dy) in ((1,1),(-1,-1),(1,0),(-1,0),(0,1),(0,-1))
            x2,y2 = (x+dx),(y+dy)
            if x2 < 1 || x2 > tsm1 || y2 < 1 || y2 > tsm1 || y2-x2 > S-1 || x2-y2 > S-1; continue; end
            id2 = move2int(S,x2,y2)
            if sb[id2]; joinset(uf,id,id2); end
        end
        if checkbridge(S,uf); k1 = i; end
        if checkfork(S,uf); k2 = i; end
        if k1 < M+1 || k2 < M+1; break; end
    end
    return (k1,k2)
end
        
function doring(S::Int64,M::Int64,MM::Vector{Tuple{Int64,Int64}})::Int64
    uf = UnionFind((2S-1)^2+1)
    edge = (2S-1)^2+1
    sb = fill(false,(2S-1)^2+1)
    tsm1 = 2S-1
    for (x,y) in MM; id = move2int(S,x,y); sb[id] = true; end
    for x in 1:tsm1
        for y in 1:tsm1
            if y-x > S-1 || x-y > S-1; continue; end
            id = move2int(S,x,y)
            if sb[id]; continue; end
            if x == 1 || y == 1 || x == tsm1 || y == tsm1 || x-y == S-1 || y-x == S-1; joinset(uf,id,edge); end
            for (dx,dy) in ((1,1),(-1,-1),(1,0),(-1,0),(0,1),(0,-1))
                x2,y2 = (x+dx),(y+dy)
                if x2 < 1 || x2 > tsm1 || y2 < 1 || y2 > tsm1 || y2-x2 > S-1 || x2-y2 > S-1; continue; end
                id2 = move2int(S,x2,y2)
                if !sb[id2]; joinset(uf,id,id2); end
            end
        end
    end
    islands = Set{Int64}()
    push!(islands,findset(uf,edge))
    for x in 1:tsm1
        for y in 1:tsm1
            if y-x > S-1 || x-y > S-1; continue; end
            id = move2int(S,x,y)
            if sb[id]; continue; end
            par = findset(uf,id)
            push!(islands,par)
        end
    end
    ans = M+1
    nislands = length(islands)
    if nislands > 1; ans = M; end
    #print("DBG: nislands:$nislands\n")
    for i in M:-1:1
        (x,y) = MM[i]
        id = move2int(S,x,y)
        sb[id] = false
        nislands += 1
        if x == 1 || y == 1 || x == tsm1 || y == tsm1 || x-y == S-1 || y-x == S-1; nislands -= 1; joinset(uf,id,edge); end
        for (dx,dy) in ((1,1),(-1,-1),(1,0),(-1,0),(0,1),(0,-1))
            x2,y2 = (x+dx),(y+dy)
            if x2 < 1 || x2 > tsm1 || y2 < 1 || y2 > tsm1 || y2-x2 > S-1 || x2-y2 > S-1; continue; end
            id2 = move2int(S,x2,y2)
            if sb[id2]; continue; end
            p1 = findset(uf,id)
            p2 = findset(uf,id2)
            if p1 == p2; continue; end
            nislands -= 1
            joinset(uf,id,id2)
        end
        if nislands > 1; ans = i-1; end
        #print("DBG: x:$x y:$y i:$i nislands:$nislands ans:$ans\n")
    end
    return ans
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
        print("Case #$qq: ")
        S,M = gis()
        MM::Vector{Tuple{Int64,Int64}} = []
        for i in 1:M; x1,x2 = gis(); push!(MM,(x1,x2)); end
        (k1,k2) = dobridgefork(S,M,MM)
        k3 = doring(S,M,MM)
        ans = ""
        if min(k1,k2,k3) > M; ans = "none"
        elseif k1 < k2 && k1 < k3; ans = "bridge in move $k1"
        elseif k2 < k1 && k2 < k3; ans = "fork in move $k2"
        elseif k3 < k1 && k3 < k2; ans = "ring in move $k3"
        elseif k1 == k2 && k1 < k3; ans = "bridge-fork in move $k1"
        elseif k1 == k3 && k1 < k2; ans = "bridge-ring in move $k1"
        elseif k2 == k3 && k2 < k1; ans = "fork-ring in move $k2"
        else;                       ans = "bridge-fork-ring in move $k1"
        end

        print("$ans\n")
    end
end
main()
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


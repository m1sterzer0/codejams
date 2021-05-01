
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

###########################################################################
## BEGIN UnionFindFast -- Only works with integers, but avoids dictionaries
###########################################################################

mutable struct UnionFindFast
    parent::Vector{Int64}
    size::Vector{Int64}
    n::Int64
    UnionFindFast(n::Int64) = new(collect(1:n),[1 for i in 1:n],n)
end

function findset(h::UnionFindFast,x::Int64)::Int64
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function getsize(h::UnionFindFast,x::Int64)::Int64
    a = findset(h,x)
    return h.size[a]
end

function joinset(h::UnionFindFast,x::Int64,y::Int64)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

################################################################
## END UnionFindFast
################################################################


#################################################################################
## Observations:
## * Only the junctions with opposite letters in the corners need to be connected
## * For the small, we only have 28 state possibilities for each column
## * (8) AAAA, BBBB, AAAB, BBBA, ABBB, BAAA, AABB, BBAA -- all fully connected with prev columns
## * (6) AABA, ABAA, ABBA * (all As connected, 2 A islands)
## * (6) BBAB, BABB, BAAB * (all Bs connected, 2 B islands)
## * (8) ABAB, BABA * (all As connected, 2 A islands) * (all Bs connected, 2 B islands)
## * We can just solve this with a DFS, being careful not to strand islands as we process
##   from left to right
#################################################################################

function getInitialState(board::Array{Char,2},scol::I,R,C)::Tuple{Bool,Bool}
    startcol = join(board[:,scol],"")
    invcount::I = count(x->startcol[x]!=startcol[x+1],1:R-1)
    state::NTuple{2,Bool} = invcount == 1 ? (true,true) : invcount == 3 ? (false,false) : startcol[1] == 'A' ? (false,true) : (true,false)
    if scol > 1 && board[1,1] == 'A'; state = (true,state[2]); end
    if scol > 1 && board[1,1] == 'B'; state = (state[1],true); end
    return state
end

function getFinalStates(board::Array{Char,2},ecol::I,R,C)::Vector{Tuple{Bool,Bool}}
    ans::Vector{Tuple{Bool,Bool}} = [(true,true)]
    if ecol < C && board[1,C] == 'A'; push!(ans,(false,true)); end
    if ecol < C && board[1,C] == 'B'; push!(ans,(true,false)); end
    return ans
end

function tryit(R::I,board::Array{Char,2},col::I,state::Tuple{Bool,Bool},middle::String)::Tuple{Bool,Tuple{Bool,Bool}}
    uf::UnionFindFast = UnionFindFast(2R)
    for i in 1:R
        if board[i,col] == board[i,col+1]; joinset(uf,i,R+i); end
        if i < R
            if board[i,col] == board[i+1,col]; joinset(uf,i,i+1); end
            if board[i,col+1] == board[i+1,col+1]; joinset(uf,R+i,R+i+1); end
        end
    end
    if state[1]
        aa::VI = [x for x in 1:R if board[x,col] == 'A']
        for i in 2:length(aa); joinset(uf,aa[1],aa[i]); end
    end
    if state[2]
        aa = [x for x in 1:R if board[x,col] == 'B']
        for i in 2:length(aa); joinset(uf,aa[1],aa[i]); end
    end
    ## Now do the middle 
    for i in 1:R-1
        if middle[i] == '/'; joinset(uf,i+1,R+i); end
        if middle[i] == '\\'; joinset(uf,i,R+i+1); end
    end
    leftSets::VI = unique(findset(uf,i) for i in 1:R)
    rightSets::VI = unique(findset(uf,i) for i in R+1:2R)
    for x in leftSets; if x ∉ rightSets; return (false,(false,false)); end; end

    asets = unique(findset(uf,R+i) for i in 1:R if board[i,col+1] == 'A')
    bsets = unique(findset(uf,R+i) for i in 1:R if board[i,col+1] == 'B')

    return (true,(length(asets)==1,length(bsets)==1))
end

function dfs(col::I,ecol::I,state::Tuple{Bool,Bool},finalStates::Vector{Tuple{Bool,Bool}},
             board::Array{Char,2},visited::Set{Tuple{I,Bool,Bool}},aa::Array{Char,2},R::I)::Bool
    if (col,state[1],state[2]) in visited; return false; end
    push!(visited,(col,state[1],state[2]))
    if col == ecol; return state in finalStates; end
    choices::VS = [""]
    for i in 1:R-1
        moves::VS = board[i,col]   != board[i+1,col+1] ? ["."] :
                    board[i+1,col] != board[i,col+1]   ? ["."] :
                    board[i,col] ==  board[i+1,col]     ? ["."] : ["/","\\"]
        choices = [a*b for a in choices for b in moves]
    end
    for c in choices 
        (res,newstate) = tryit(R,board,col,state,c)
        if !res; continue; end
        aa[:,col] = [x for x in c]
        if dfs(col+1,ecol,newstate,finalStates,board,visited,aa,R); return true; end
    end
    return false
end

function solveSmall(R::I,C::I,board::Array{Char,2})::VS
    ## Do a prefix column search
    ans::VS = []
    scol::I = 1; ecol::I = C
    while all(board[i,scol] == board[1,scol] for i in 2:R) && (scol==1 || board[1,scol]==board[1,scol-1]); scol += 1; end
    while all(board[i,ecol] == board[1,ecol] for i in 2:R) && (ecol==C || board[1,ecol]==board[1,ecol+1]); ecol -= 1; end
    aa::Array{Char,2} = fill('.',R-1,C-1)
    initState::Tuple{Bool,Bool} = getInitialState(board,scol,R,C)
    finalStates::Vector{Tuple{Bool,Bool}} = getFinalStates(board,ecol,R,C)
    visited::Set{Tuple{I,Bool,Bool}} = Set{Tuple{I,Bool,Bool}}()
    lans = dfs(scol,ecol,initState,finalStates,board,visited,aa,R)
    if !lans; return ["IMPOSSIBLE"]; end
    push!(ans,"POSSIBLE")
    for i in 1:R-1; push!(ans,join(aa[i,:],"")); end
    return ans
end

#################################################################################
## Additional Observations (largely following the printed answers)
## * Regions can only be disconnected by (a) a cycle of the other color around
##   a point, or (b) a wall of the other color (border-2-border) separating 
##   two points of our color.
## * We never need to add a connection to two points already connected
## * We can first do a border check to see if it contains at most one region of
##   each color.  If instead it contains 2, then we are in an impossible state, since
##   connecting one color will strand the other.
## * Assuming the border is ok, we now have no incentive ot create walls touching
##   the border, eliminating condition (b) above.  Furthermore, since we won't add
##   connections to blocks that are already connected, we can never use diagonal
##   connections to create a new cycle.  This eliminates condition (a) above from
##   the diagonal connections.
## * UPSHOT algorithm
##   -- Check the border and make sure it is ok.  Otherwise, print "IMPOSSIBLE"
##      (actually, this isn't strictly necessary)
##   -- Use union find to identify regions
##   -- At each 
##       AB  OR  BA 
##       BA      AB
##      pattern.  Place a edge only if a pair of corners are disconnected.  If both are
##      disconnected, then pick one -- the choice won't affect whether the assignment ends
##      in success.
##   -- Check if we have only two regions at the end, and pring success/fail appropriately.
#################################################################################

function solveLarge(R::I,C::I,board::Array{Char,2})::VS
    ## Do a prefix column search
    ans::VS = []
    uf::UnionFindFast = UnionFindFast(R*C)
    for i in 1:R; for j in 1:C
        if i > 1 && board[i-1,j] == board[i,j]; i2,j2 = i-1,j; joinset(uf,C*(i-1)+j,C*(i2-1)+j2); end
        if i < R && board[i+1,j] == board[i,j]; i2,j2 = i+1,j; joinset(uf,C*(i-1)+j,C*(i2-1)+j2); end
        if j > 1 && board[i,j] == board[i,j-1]; i2,j2 = i,j-1; joinset(uf,C*(i-1)+j,C*(i2-1)+j2); end
        if j < C && board[i,j] == board[i,j+1]; i2,j2 = i,j+1; joinset(uf,C*(i-1)+j,C*(i2-1)+j2); end
    end; end
    aa::Array{Char,2} = fill('.',R-1,C-1)
    for i in 1:R-1
        for j in 1:C-1
            if board[i,j] == board[i+1,j]; continue; end
            if board[i,j] != board[i+1,j+1]; continue; end
            if board[i+1,j] != board[i,j+1]; continue; end
            for (i1,j1,i2,j2,c) in [(i,j,i+1,j+1,'\\'),(i+1,j,i,j+1,'/')]
                if findset(uf,C*(i1-1)+j1) != findset(uf,C*(i2-1)+j2)
                    joinset(uf,C*(i1-1)+j1,C*(i2-1)+j2)
                    aa[i,j] = c
                    break
                end
            end
        end
    end
    allsets = unique(findset(uf,i) for i in 1:R*C)
    if length(allsets) != 2; return ["IMPOSSIBLE"]; end
    push!(ans,"POSSIBLE")
    for i in 1:R-1; push!(ans,join(aa[i,:],"")); end
    return ans
end


function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        board::Array{Char,2} = fill('.',R,C)
        for i in 1:R; board[i,:] = [x for x in gs()]; end
        #ans = solveSmall(R,C,board)
        ans = solveLarge(R,C,board)
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


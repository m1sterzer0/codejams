
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

## Key observations
## * The main difficulty is not in the BFS/DFS to get to the reachable segments,
##   but rather it is in the "Lucky" calculation.
## * As long as you don't make a move which moves you into an unreachable segement,
##   you are no worse off than you started (since you may have started in these
##   new positions.)
## * We can move left/right freely within our segments without risk of reaching
##   an unreachable segment.
struct Segment; row::I; len::I; l::I; r::I; end

function solve(R::I,C::I,board::Array{Char,2})
    segments::Vector{Segment} = []
    insegment::Bool = false; l::I = 0; r::I = 0; len::I = 0

    ## Find all of the horizontal segments in the 
    for i::I in 1:R; for j::I in 1:C
        if board[i,j] == '#'
            if insegment; r = j-1; len = r-l+1; push!(segments,Segment(i,len,l,r)); end
            insegment = false
        else
            if !insegment; l = j; end
            insegment = true
        end
    end; end
    nseg = length(segments)

    ## Create a segment graphs for the first part of the problem
    adjrev::Vector{VI} = [VI() for i in 1:nseg]
    for i in 1:nseg-1
        row1::I,l1::I,r1::I = segments[i].row,segments[i].l,segments[i].r
        for j in i+1:nseg
            if segments[j].row != row1+1; continue; end
            l2::I,r2::I = segments[j].l,segments[j].r
            if r2 < l1 || r1 < l2; continue; end
            push!(adjrev[j],i)
        end
    end

    ## Create a board with the segids in each slot and -1 in the # splots
    b2::Array{Int64,2} = fill(-1,R,C)
    for (sid,s) in enumerate(segments); b2[s.row,s.l:s.r] .= sid; end

    ## Loop through the caveids
    sb::Vector{Bool} = fill(false,nseg)
    q::VI = []
    numReachable::VI = []
    luckystrs::Vector{String} = []
    for caveid in "0123456789"
        cr,cc = 0,0
        for i in 1:R; for j in 1:C; if board[i,j] == caveid; cr = i; cc = j; break; end; end; end
        if cr == 0; break; end

        ## BFS to find the segments from which we can reach the target segment
        segid = b2[cr,cc]
        fill!(sb,false); sb[segid] = true; push!(q,segid)
        while !isempty(q)
            nn = popfirst!(q)
            for c in adjrev[nn]; if !sb[c]; sb[c] = true; push!(q,c); end; end
        end

        ## Part 1 is just counting up the cells in the segements from which the target cell is reachable
        numsq = sum(sb[i] ? segments[i].len : 0 for i in 1:nseg)
        push!(numReachable,numsq)

        ## Now for the lucky calculation.  First, we calculate the badmask and exitmask for each.
        activesegs = count(x->x,sb); lucky = true
        if activesegs == 1; push!(luckystrs,"Lucky"); continue; end
        badmask::VI = fill(0,nseg)
        exitmask::VI = fill(0,nseg)
        for i in 1:nseg
            if !sb[i]; continue; end
            row,l = segments[i].row,segments[i].l
            for jj in 1:segments[i].len
                j = l+jj-1
                if b2[row+1,j] < 0; continue; end
                if sb[b2[row+1,j]]; exitmask[i] |= (1 << (jj-1)); else; badmask[i] |= (1 << (jj-1)); end
            end
        end

        ## Now for the lucky calculation, which is the hardest part of the problem.  
        ## First note that in our model, our relative position in all of the segements of the same length
        ## can be made identical (e.g. with a ton of 'left' moves) before we start, so we assume this.  This
        ## allows us to treat all of the segments of one particular length as one "virtual" segement, at least
        ## for the purposes of finding a valid move.
        ##
        ## Now, we have a set of up to 8/58 (Sm/Lar) segment lengths, and we are looking to make a move
        ## down which makes forward progress for at least one segment without simultaneously kicking
        ## another segement into a bad region.  The KEY QUESTION is WHAT STATES ARE POSSIBLE?  Here we have
        ## assumed that initially, we have pushed ourselves as far left as possible in each segment.  The
        ## approach here differs between the small and the large.  I don't code up the small here (it is
        ## actually more complicated -- and I played with it a bit on the side -- but I never implemented a
        ## full solutions based on it.), but I describe it below.
        ##
        ## SMALL: Build a graph of all possible positions (i.e. picking one element in each segment) with edges
        ##        pointing to the position you arrive at when going either left or right.  Here we have 8! nodes
        ##        and 2*8! edges.  We can then use BFS/DFS to find the set of states reachable from the initial
        ##        position.  We end up finding out that there are 2^7 possible states.  Note that you can actually
        ##        do this the beginning, and reuse the results here for each testcase.  We can then iterate
        ##        through each one, see if they make forward progress.
        ##
        ##
        ## LARGE: Obviously a search through 58! nodes isn't going to work.  The key observation of N! --> 2^(N-1) 
        ##        suggests a deeper pattern.  By playing with the base cases, we see how we can derive a 2:1 relationship
        ##        when calculating the states assocated with segement lengths 1,2,...,n+1 from the states associated
        ##        with segment lengths 1,2,...,n.
        ##            Copy 1 has segment n+1 at the same position (relative to the left edge) as segment 1.
        ##            Copy 2 has segment n+1 at the same position (relative to the right edge) as segment 1.
        ##        This algorithmic view makes the states easier to process in masse.
        ##
        ##        Alternatively, you can think of all of the segments arranged like a triangular "plinko" board,
        ##        (or similarily, like pascal's triangle).  At each row , you choose whether to go left or right.
        ##        Going left is the same as "Copy 1" above.  Going right is the same as "Copy 2" above.
        ##
        ##        With this algorithm, we can actually use bitmasks to look at all possible legal moves
        ##        en masse and check off the ones which make forward progress.
        ##
        ##        Finally, the last key observation is that if we find a valid move with the current set
        ##        of possible segments, it also works with a subset of those possible segements.  The upshot
        ##        here is that we don't have to trace a path from all segments down to the target segment
        ##        (i.e. "nseg * R" steps), but instead we can just focus on whether a recipe that exists that
        ##        makes one step of forward progress frem each segment (ie. "nseg" steps).  The parallel processing
        ##        of all legal moves also makes this much more efficient in practice. 
        
        mysegs = Set{Int64}([x for x in 1:nseg if sb[x]])
        while length(mysegs) > 1
            prevlen::I = length(mysegs)
            badmasks::VI = [0 for i in 1:(C-2)]
            for s in mysegs; badmasks[segments[s].len] |= badmask[s]; end
            ## Push bad masks down
            for i in 2:(C-2)
                if badmasks[i-1] & 1 != 0; badmasks[i] |= 1; end
                if badmasks[i-1] & 1<<(i-2) != 0; badmasks[i] |= 1 <<(i-1); end
                badmasks[i] |= badmasks[i-1] & (badmasks[i-1]<<1)
            end
            ## Push bad masks up
            for i in (C-3):-1:1; badmasks[i] |= badmasks[i+1] & badmasks[i+1] >> 1; end
            ## Reap our rewards
            seglist::VI = [x for x in mysegs]  ## Snapshot set contents, since we are going to modify set 
            for s in seglist; l = segments[s].len; if exitmask[s] & ~badmasks[l] != 0; delete!(mysegs,s); end; end
            if prevlen == length(mysegs); break; end
        end
        push!(luckystrs,length(mysegs) == 1 ? "Lucky" : "Unlucky")
    end
    return (numReachable,luckystrs)
end

function gencase(Rmin::I,Rmax::I)
    R = rand(max(3,Rmin):Rmax)
    C = rand(max(3,Rmin):Rmax)
    maxcaves = min(10,(R-2)*(C-2))
    numcaves = rand(1:maxcaves)
    board::Array{Char,2} = fill('.',R,C)
    board[1,:] .= '#'; board[R,:] .= '#'
    board[:,1] .= '#'; board[:,C] .= '#'
    for c in 0:numcaves-1
        (xx,yy) = (1,1)
        while board[xx,yy] != '.'; xx = rand(1:R); yy = rand(1:C); end
        board[xx,yy] = '0' + c
    end
    wallpercentage = 0.90 * rand()
    for x in 1:R; for y in 1:C
        if board[x,y] == '.' && rand() < wallpercentage; board[x,y] = '#'; end
    end; end
    return (R,C,board)
end

function test(ntc::I,Rmin::I,Rmax::I)
    for ttt in 1:ntc
        (R,C,board) = gencase(Rmin,Rmax)
        ans = solve(R,C,board)
        print("Case #$ttt:\n")
        for i in 1:length(ans[1]); print("$(i-1): $(ans[1][i]) $(ans[2][i])\n"); end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = gis()
        board::Array{Char,2} = fill('.',R,C)
        for i in 1:R; board[i,:] = [x for x in gs()]; end
        ans = solve(R,C,board)
        for i in 1:length(ans[1]); print("$(i-1): $(ans[1][i]) $(ans[2][i])\n"); end
    end
end

Random.seed!(8675309)
main()
#test(100,3,10)
#test(100,3,60)


#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


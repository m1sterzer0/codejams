
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

struct idxPt; x::I; y::I; idx::I; end

function quadrant(a::idxPt)::I
    return ((a.x >= 0 && a.y > 0) ? 1 :
            (a.x <  0 && a.y >= 0) ? 2 :
            (a.x <= 0 && a.y < 0) ? 3 :
            (a.x > 0 && a.y <= 0) ? 4 : 0)
end

function ccwcmp(a::idxPt,b::idxPt)::Bool
    qa = quadrant(a)
    qb = quadrant(b)
    if qa != qb; return qa < qb; end
    return a.x*b.y-a.y*b.x > 0
end

function solve(N::I,X::VI,Y::VI)::VI
    pts::Vector{idxPt} = [idxPt(X[i],Y[i],i) for i in 1:N]
    best::VI = fill(N-1,N)
    vecs::Vector{idxPt} = []
    for i in 1:N
        empty!(vecs)
        ## Make a list of points normalized to point i, skipping point i
        for j in 1:N
            if i == j; continue; end
            push!(vecs,idxPt(pts[j].x-pts[i].x,pts[j].y-pts[i].y,j))
        end
        sort!(vecs,lt=ccwcmp)
        nxthead,tail = 1,1
        while nxthead < N
            head = nxthead
            j = vecs[head].idx
            while(true) 
                nxtTail = tail + 1
                if nxtTail >= N; nxtTail = 1; end
                if nxtTail == head; break; end
                if vecs[head].x*vecs[nxtTail].y-vecs[head].y*vecs[nxtTail].x < 0; break; end
                tail = nxtTail
            end

            hx = vecs[head].x; hy = vecs[head].y
            goodPts = tail >= head ? tail-head+1 : N-head+tail
            badPts = N-1-goodPts
            #print(stderr,"DBG: i:$i j:$j hx:$hx hy:$hy head:$head tail:$tail goodPts:$goodPts badPts:$badPts\n")
            best[i] = min(best[i],badPts)
            best[j] = min(best[j],badPts)
            if tail == head; tail += 1; end
            nxthead += 1

            ## Now we have to corner case when the next head is on the same ray as the current head
            while (nxthead <= N-1 && quadrant(vecs[head]) == quadrant(vecs[nxthead]) && vecs[head].x*vecs[nxthead].y - vecs[head].y*vecs[nxthead].x == 0)
                jj = vecs[nxthead].idx
                best[jj] = min(best[jj],badPts)
                if tail == nxthead; tail += 1; end
                nxthead += 1
            end        
        end
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        N = gi()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        ans = solve(N,X,Y)
        for a in ans; print("$a\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


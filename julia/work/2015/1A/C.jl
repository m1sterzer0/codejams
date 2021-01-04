using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

mutable struct idxPt
    x::Int64
    y::Int64
    idx::Int64
end

function quadrant(a::idxPt)::Int64
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


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        N = parse(Int64,readline(infile))
        pts::Vector{idxPt} = fill(idxPt(0,0,0),N)
        for i in 1:N
            xxx = [parse(Int64,x) for x in split(readline(infile))]
            pts[i] = idxPt(xxx[1],xxx[2],i)
        end
        best::Vector{Int64} = fill(N-1,N)
        vecs::Vector{idxPt} = fill(idxPt(0,0,0),0)

        for i in 1:N
            empty!(vecs)
            ## Make a list of points normalized to point i, skipping point i
            for j in 1:N
                if i == j; continue; end
                push!(vecs,idxPt(pts[j].x-pts[i].x,pts[j].y-pts[i].y,j))
            end
            sort!(vecs,lt=ccwcmp)
            #print(vecs)
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

        for i in 1:N
            ans = best[i]
            print("$ans\n")
        end
    end
end

main()

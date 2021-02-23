
mutable struct Wall
    off::Int64
    wh::Vector{Int64}
end

function init(w::Wall,offset::Int64)
    w.off = offset+1
    w.wh = fill(0,1+2*offset)
end

function rmq(w::Wall,a::Int64,b::Int64)::Int64
    return minimum(w.wh[2*a+w.off:2*b+w.off])
end

function update(w::Wall,a::Int64,b::Int64,v::Int64)
    for i in 2*a:2*b
        w.wh[w.off+i] = max(w.wh[w.off+i],v)
    end
end
    
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ww = Wall(0,[]); init(ww,400);
        ans = 0
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        events::Vector{Tuple{Int64,Int64,Int64,Int64}} = []
        for i in 1:N
            d,n,w,e,s,dd,dp,ds = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            for j in 1:n
                push!(events,(d,s,w,e))
                d += dd; w += dp; e += dp; s += ds
            end
        end
        sort!(events)
        last,le = 0,length(events)
        while (last != le)
            last += 1
            start = last
            d = events[last][1]
            while last < le && events[last+1][1] == d; last += 1; end
            for i in start:last
                rr = rmq(ww,events[i][3],events[i][4])
                if rr < events[i][2]; ans += 1; end
            end
            for i in start:last
                update(ww,events[i][3],events[i][4],events[i][2])
            end
        end
        print("$ans\n")
    end
end

main()


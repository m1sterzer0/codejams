using Printf

######################################################################################################
### For the large, we need to do some interval merging math and create a set of intervals for the
### adders.  One might expect this to grow to be 2^N, but the minimum geometric separation between
### the min and max of each interval (i.e. max >= sqrt(2) * min) means that there is a quick upper bound
### on the number of intervals, making this merging practical.
### 
### Because of the "without going over" concept, I was paranoid and kept the intervals in the form
### [int,float].
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        W = fill(0,N)
        H = fill(0,N)
        for i in 1:N
            W[i],H[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        basePerim = sum(2*H[i]+2*W[i] for i in 1:N)
        intervals::Vector{Tuple{Int64,Float64}} = [(2*min(W[i],H[i]),2*sqrt(W[i]*W[i]+H[i]*H[i])) for i in 1:N]
        minAdder = minimum(x[1] for x in intervals)
        maxAdder = sum(x[2] for x in intervals)

        if basePerim + minAdder > P;  @printf("%.10f\n",basePerim); continue; end
        if basePerim + maxAdder <= P; @printf("%.10f\n",basePerim+maxAdder); continue; end
        adder = doIntervalSearch(intervals,P-basePerim)
        @printf("%.10f\n",basePerim+adder)
    end
end

function doIntervalSearch(intervals::Vector{Tuple{Int64,Float64}},targ::Int64)::Float64
    iarr = createIarr(intervals::Vector{Tuple{Int64,Float64}})
    best = 0.0
    for ii in iarr
        if targ <  ii[1]; return best; end
        if targ <= ii[2]; return Float64(targ); end
        best = ii[2]
    end
    return best;
end

function createIarr(intervals::Vector{Tuple{Int64,Float64}})::Vector{Tuple{Int64,Float64}}
    iarr = Vector{Tuple{Int64,Float64}}()
    iarr2 = Vector{Tuple{Int64,Float64}}()
    for ii in intervals
        n = length(iarr)
        push!(iarr,ii)
        for jj in iarr[1:n]
            push!(iarr,(ii[1]+jj[1],ii[2]+jj[2]))
        end
        ### Compress the arr
        sort!(iarr)
        resize!(iarr2,0)
        for jj in iarr
            if isempty(iarr2) || jj[1] > iarr2[end][2]
                push!(iarr2,jj)
            elseif jj[2] > iarr2[end][2]
                nn = (iarr2[end][1],jj[2])
                pop!(iarr2)
                push!(iarr2,nn)
            end
        end
        (iarr,iarr2) = (iarr2,iarr)
    end
    return iarr
end

main()
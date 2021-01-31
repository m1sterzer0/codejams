######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function getsig(s::AbstractString)::AbstractString
    ca::Vector{Char} = []
    last = '.'
    for c in s
        if c == last; continue; end
        last = c
        push!(ca,c)
    end
    ans = join(ca)
    return ans
end

function getCounts(s::AbstractString)::Vector{Int64}
    ca::Vector{Int64} = []
    last = '.'
    for c in s
        if c == last
            ca[end] += 1
        else
            last = c
            push!(ca,1)
        end
    end
    return ca
end

function solveColumn(a::Vector{Int64})::Int64
    n::Int64 = length(a)
    sort!(a)
    val::Int64 = a[(n+1) ÷ 2] 
    while(true)
        ltval = count(x->x<val,a)
        eqval = count(x->x==val,a)
        gtval = count(x->x>val,a)
        if ltval > eqval + gtval
            val -= 1
        elseif gtval > ltval + eqval
            val += 1
        else
            break
        end
    end
    ans = sum([abs(xx-val) for xx in a])
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        strings = [readline(infile) for i in 1:N]
        sigs = Set{AbstractString}()
        for s in strings; push!(sigs,getsig(s)); end
        if length(sigs) > 1; print("Fegla Won\n"); continue; end;
        sig = [x for x in sigs][1]
        counts = fill(0,N,length(sig))
        for i in 1:N; counts[i,:] = getCounts(strings[i]); end
        ans::Int64 = 0
        for j in 1:length(sig); ans += solveColumn(counts[:,j]); end
        print("$ans\n")
    end
end

main()

using Printf

######################################################################################################
### a) The trick here is to turn 15! orderings to 2^15 subsets and use dynamic programing.
### b) The observation is that if I have a set of prefix operations plus one "last" operation,
###    --- The maximum value is related to either the maximum or the minimum possible value of the
###        prefix operations.
### c) This leads to a rather naiive dyanmic programming solution
######################################################################################################

function tadd(a::Tuple{BigInt,BigInt},b::BigInt)
    return (a[1]+b*a[2],a[2])
end

function tsub(a::Tuple{BigInt,BigInt},b::BigInt)
    return (a[1]-b*a[2],a[2])
end

function tmul(a::Tuple{BigInt,BigInt},b::BigInt)
    return (a[1]*b,a[2])
end

function tdiv(a::Tuple{BigInt,BigInt},b::BigInt)
    return b < 0 ? (-a[1],a[2]*(-b)) : (a[1],a[2]*b)
end

function tgt(a::Tuple{BigInt,BigInt},b::Tuple{BigInt,BigInt})
    return b[2]*a[1] > a[2]*b[1]
end

function tlt(a::Tuple{BigInt,BigInt},b::Tuple{BigInt,BigInt})
    return b[2]*a[1] < a[2]*b[1]
end

function compressCards(O::Vector{Char},V::Vector{Int64})
    possum = BigInt(0)
    negsum = BigInt(0)
    posmul = BigInt(1)
    posdiv = BigInt(1)
    negmul = Vector{BigInt}()
    negdiv = Vector{BigInt}()
    zeromul = false
    for (o,v) in zip(O,V)
        if v == 0
            if o == '*'; zeromul = true; end
        elseif v < 0
            if     o == '+'; negsum += v
            elseif o == '-'; possum -= v
            elseif o == '*'; push!(negmul,BigInt(v))
            elseif o == '/'; push!(negdiv,BigInt(v))
            end
        else
            if     o == '+'; possum += v
            elseif o == '-'; negsum -= v
            elseif o == '*'; posmul *= v
            elseif o == '/'; posdiv *= v
            end
        end 
    end
    O2 = Vector{Char}()
    V2 = Vector{BigInt}()
    if possum > 0; push!(O2,'+'); push!(V2,possum); end
    if negsum < 0; push!(O2,'+'); push!(V2,negsum); end
    if posmul > 1; push!(O2,'*'); push!(V2,posmul); end
    if posdiv > 1; push!(O2,'/'); push!(V2,posdiv); end
    if zeromul;    push!(O2,'*'); push!(V2,zero(BigInt)); end
    sort!(negmul)
    sort!(negdiv)
    if !isempty(negmul); push!(O2,'*'); push!(V2,pop!(negmul)); end
    if !isempty(negmul); push!(O2,'*'); push!(V2,pop!(negmul)); end
    if !isempty(negmul); push!(O2,'*'); push!(V2,prod(negmul)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,pop!(negdiv)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,pop!(negdiv)); end
    if !isempty(negdiv); push!(O2,'/'); push!(V2,prod(negdiv)); end
    return O2,V2
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        O = fill('+',C)
        V = fill(0,C)
        for i in 1:C
            aa = split(rstrip(readline(infile)))
            O[i] = aa[1][1]
            V[i] = parse(Int64,aa[2])
        end
        O2,V2 = compressCards(O,V)
        C2 = length(O2)

        minvals = resize!(Vector{Tuple{BigInt,BigInt}}(),2^C2)
        maxvals = resize!(Vector{Tuple{BigInt,BigInt}}(),2^C2)
        minvals[1] = maxvals[1] = (BigInt(S),BigInt(1))
        #print("\n")
        for i in 2:2^C2
            first = true
            bitmask = i-1
            for j in 1:C2
                bm = 1 << (j-1)
                if bitmask & bm == 0; continue; end
                residual = bitmask & ~bm + 1
                v1,v2 = (BigInt(0),BigInt(1)),(BigInt(0),BigInt(1))
                if O2[j] == '+'
                    v1 = tadd(maxvals[residual],V2[j])
                    v2 = tadd(minvals[residual],V2[j])
                elseif O2[j] == '-'
                    v1 = tsub(maxvals[residual],V2[j])
                    v2 = tsub(minvals[residual],V2[j])
                elseif O2[j] == '*'
                    v1 = tmul(maxvals[residual],V2[j])
                    v2 = tmul(minvals[residual],V2[j])
                else O2[j] == '/'
                    v1 = tdiv(maxvals[residual],V2[j])
                    v2 = tdiv(minvals[residual],V2[j])
                end
                (maxv,minv) = tgt(v1,v2) ? (v1,v2) : (v2,v1)
                if first
                    maxvals[i] = maxv
                    minvals[i] = minv
                    first = false
                else
                    maxvals[i] = tgt(maxvals[i],maxv) ? maxvals[i] : maxv
                    minvals[i] = tlt(minvals[i],minv) ? minvals[i] : minv
                end
                #print("DEBUG: $i $bitmask $bm $(j-1) $(ops[j][1]) $(ops[j][2]) v1:($v1) v2:($v2) maxvals[i]:($(maxvals[i])) minvals[i]:($(minvals[i]))\n")

            end
        end
        ans = maxvals[2^C2][1]//maxvals[2^C2][2]
        print("$(numerator(ans)) $(denominator(ans))\n")
    end
end

main()

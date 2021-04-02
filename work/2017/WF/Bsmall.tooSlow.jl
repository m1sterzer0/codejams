using Printf

######################################################################################################
### a) The trick here is to turn 15! orderings to 2^15 subsets and use dynamic programing.
### b) The observation is that if I have a set of prefix operations plus one "last" operation,
###    --- The maximum value is related to either the maximum or the minimum possible value of the
###        prefix operations.
### c) This leads to a rather naiive dyanmic programming solution
######################################################################################################

function tadd(a::Tuple{BigInt,BigInt},b::Int64)
    return (a[1]+b*a[2],a[2])
end

function tsub(a::Tuple{BigInt,BigInt},b::Int64)
    return (a[1]-b*a[2],a[2])
end

function tmul(a::Tuple{BigInt,BigInt},b::Int64)
    return (a[1]*b,a[2])
end

function tdiv(a::Tuple{BigInt,BigInt},b::Int64)
    return b < 0 ? (-a[1],a[2]*(-b)) : (a[1],a[2]*b)
end

function tgt(a::Tuple{BigInt,BigInt},b::Tuple{BigInt,BigInt})
    return b[2]*a[1] > a[2]*b[1]
end

function tlt(a::Tuple{BigInt,BigInt},b::Tuple{BigInt,BigInt})
    return b[2]*a[1] < a[2]*b[1]
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ops = Vector{Tuple{Char,Int64}}()
        for i in 1:C
            aa = split(rstrip(readline(infile)))
            op = aa[1][1]
            val = parse(Int64,aa[2])
            push!(ops,(op,val))
        end

        minvals = resize!(Vector{Tuple{BigInt,BigInt}}(),2^C)
        maxvals = resize!(Vector{Tuple{BigInt,BigInt}}(),2^C)
        minvals[1] = maxvals[1] = (BigInt(S),BigInt(1))
        #print("\n")
        for i in 2:2^C
            first = true
            bitmask = i-1
            for j in 1:C
                bm = 1 << (j-1)
                if bitmask & bm == 0; continue; end
                residual = bitmask & ~bm + 1
                v1,v2 = (BigInt(0),BigInt(1)),(BigInt(0),BigInt(1))
                if ops[j][1] == '+'
                    v1 = tadd(maxvals[residual],ops[j][2])
                    v2 = tadd(minvals[residual],ops[j][2])
                elseif ops[j][1] == '-'
                    v1 = tsub(maxvals[residual],ops[j][2])
                    v2 = tsub(minvals[residual],ops[j][2])
                elseif ops[j][1] == '*'
                    v1 = tmul(maxvals[residual],ops[j][2])
                    v2 = tmul(minvals[residual],ops[j][2])
                else ops[j][1] == '/'
                    v1 = tdiv(maxvals[residual],ops[j][2])
                    v2 = tdiv(minvals[residual],ops[j][2])
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
        ans = maxvals[2^C][1]//maxvals[2^C][2]
        print("$(numerator(ans)) $(denominator(ans))\n")
    end
end

main()

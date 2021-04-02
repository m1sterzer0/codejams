
function makeDD(D::Vector{String})::Dict{String,Vector{Int64}}
    DD::Dict{String,Vector{Int64}} = Dict{String,Vector{Int64}}()
    keys = []
    for c in "abcdefghijklmnopqrstuvwxyz."; push!(keys,"$c"); end
    for i in 1:3
        nkeys = keys[:]
        for k in nkeys
            for c in "abcdefghijklmnopqrstuvwxyz."; push!(keys,"$k$c"); end
        end
    end
    for k in keys; DD[k] = []; end
    for (i,w) in enumerate(D)
        if length(w) == 1
            push!(DD[w[1:1]],i)
            push!(DD["."],i)
        elseif length(w) == 2
            push!(DD[w[1:2]],i)
            push!(DD["."*w[2:2]],i)
            push!(DD[w[1:1]*"."],i)
        elseif length(w) == 3
            push!(DD[w[1:3]],i)
            push!(DD["."*w[2:3]],i)
            push!(DD[w[1:1]*"."*w[3:3]],i)
            push!(DD[w[1:2]*"."],i)
        else
            push!(DD[w[1:4]],i)
            push!(DD["."*w[2:4]],i)
            push!(DD[w[1:1]*"."*w[3:4]],i)
            push!(DD[w[1:2]*"."*w[4:4]],i)
            push!(DD[w[1:3]*"."],i)
        end
    end
    return DD
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    W = parse(Int64,readline(infile))
    D::Vector{String} = []
    for i in 1:W; push!(D,readline(infile)); end
    DD::Dict{String,Vector{Int64}} = makeDD(D)
    DP::Array{Int64,2} = fill(10000,4000,5)
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        s = rstrip(readline(infile))
        ls::Int64 = length(s)
        fill!(DP,10000)
        for i in length(s):-1:1

            ## Get the prefixes
            prefixes = [".",s[i:i]]
            if i+1 <= ls
                push!(prefixes,s[i:i+1])
                push!(prefixes,s[i:i]*".")
                push!(prefixes,"."*s[i+1:i+1])
                if i+2 <= ls
                    push!(prefixes,s[i:i+2])
                    push!(prefixes,s[i:i+1]*".")
                    push!(prefixes,s[i:i]*"."*s[i+2:i+2])
                    push!(prefixes,"."*s[i+1:i+2])
                    if i+3 <= ls
                        push!(prefixes,s[i:i+3])
                        push!(prefixes,s[i:i+2]*".")
                        push!(prefixes,s[i:i+1]*"."*s[i+3:i+3])
                        push!(prefixes,s[i:i]*"."*s[i+2:i+3])
                        push!(prefixes,"."*s[i+1:i+3])
                    end
                end
            end

            wordindices::Set{Int64} = Set{Int64}()
            for p in prefixes
                for widx in DD[p]
                    push!(wordindices,widx)
                end
            end
            for wi in wordindices
                w = D[wi]
                lw::Int64 = length(w)
                if lw + i - 1 > ls; continue; end
                mismatches = [i+j-1 for j in 1:lw if w[j] != s[i+j-1]]
                good = true
                for i in 1:length(mismatches)-1
                    if mismatches[i+1]-mismatches[i] < 5; good = false; break; end
                end
                if !good; continue; end
                nexti = i + lw
                if length(mismatches) == 0
                    if nexti > ls
                        for j in 1:5; DP[i,j] = 0; end
                    else
                        for j in 1:5; DP[i,j] = min(DP[i,j],DP[nexti,max(1,j-lw)]); end
                    end
                else
                    prefix = min(5,1+mismatches[1]-i)
                    suffix = min(4,nexti-mismatches[end]-1)
                    ans = length(mismatches) + (nexti > ls ? 0 : DP[nexti,5-suffix])
                    for j in 1:prefix; DP[i,j] = min(DP[i,j],ans); end
                end
            end
        end
        ans = DP[1,1]
        print("Case #$qq: $ans\n")
    end
end

main()


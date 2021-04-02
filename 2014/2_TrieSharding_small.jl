######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        M::Int64,N::Int64 = [parse(Int64,x) for x in split(readline(infile))]
        S::Vector{AbstractString} = [readline(infile) for i in 1:M]

        ## Brute force with N^M possible assingments
        cases::Array{Int64,2} = fill(0,N^M,M)
        for j::Int64 in 1:M
            i::Int64 = 1
            for r::Int64 in 1:(N^(M-j))
                for s::Int64 in 1:N
                    for p::Int64 in 1:N^(j-1)
                        cases[i,j] = s; i += 1
                    end
                end
            end
        end

        prefixset::Vector{Set{AbstractString}} = [Set{AbstractString}() for i in 1:M]
        for i in 1:M
            push!(prefixset[i],"")
            for j in 1:length(S[i])
                push!(prefixset[i],S[i][1:j])
            end
        end
        mysets::Vector{Set{AbstractString}} = [Set{AbstractString}() for i in 1:N]

        best,bestcnt = 0,0
        for i in 1:N^M
            assignments = cases[i,:]
            valid = true
            for j in 1:N
                if j ∉ assignments; valid = false; break; end
            end
            if !valid; continue; end
            for j in 1:N; empty!(mysets[j]); end
            for j in 1:M
                si = assignments[j]
                union!(mysets[si],prefixset[j])
            end
            trial = sum([length(x) for x in mysets])
            if trial > best; best = trial; bestcnt = 1
            elseif trial == best; bestcnt += 1
            end
        end

        print("$best $bestcnt\n")
    end
end

main()

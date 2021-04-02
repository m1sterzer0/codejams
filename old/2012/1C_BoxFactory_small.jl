
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    oldstate::Vector{Tuple{Int64,Tuple{Int64,Int64}}} = []
    newstate::Vector{Tuple{Int64,Tuple{Int64,Int64}}} = []
    toys::Array{Int64,2} = fill(0,100,2)
    boxes::Array{Int64,2} = fill(0,100,2)

    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        MM = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        for i in 1:N; toys[i,:] = NN[2*i-1:2*i]; end
        for i in 1:M; boxes[i,:] = MM[2*i-1:2*i]; end
        empty!(oldstate)
        push!(oldstate,(0,(1,0)))
        for i in 1:N
            tn = toys[i,1]
            tt = toys[i,2]
            empty!(newstate)
            for (a,(bidx,bcnt)) in oldstate
                push!(newstate,(a,(bidx,bcnt)))
                toysleft = tn
                for m in bidx:M
                    if m != bidx; bcnt = 0; end
                    if boxes[m,2] == tt
                        avail = boxes[m,1]-bcnt
                        if toysleft < avail
                            bcnt += toysleft
                            a += toysleft
                            push!(newstate,(a,(m,bcnt)))
                            break
                        elseif toysleft == avail
                            a += toysleft
                            push!(newstate,(a,(m+1,0)))
                            break
                        else
                            a += avail
                            toysleft -= avail
                            push!(newstate,(a,(m+1,0)))
                        end
                    end
                end
            end
            ## Collapse the states
            empty!(oldstate)
            sort!(newstate,rev=true)
            for (a,t) in newstate
                if !isempty(oldstate) && a >= oldstate[end][1] && t < oldstate[end][2]; pop!(oldstate); end
                push!(oldstate,(a,t))
            end
        end
        ans = oldstate[1][1]
        print("$ans\n")
    end
end

main()


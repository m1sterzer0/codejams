## consider the points as (1,obs1), 2(obs2), 3(obs3),...
## For the small, all we need to observe is that the optimal tempo is achieved with a line between two
## of the observed points.

function trytempo(num::Int64,denom::Int64,NN::Vector{Int64})::Float64
    mine::Float64 = 1e99
    maxe::Float64 = -1e99
    N::Int64 = length(NN)
    inc::Float64 = num/denom
    cur::Float64 = 0
    for i in 1:N
        cur += inc
        err = cur - NN[i]
        if err < mine; mine = err; end
        if err > maxe; maxe = err; end
    end
    return 0.5*(maxe-mine)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N  = parse(Int64,rstrip(readline(infile)))
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        best = 1e99
        for i::Int64 in 1:N-1
            for j::Int64 in i+1:N
                b = trytempo(NN[j]-NN[i],j-i,NN)
                best = min(best,b)
            end
        end
        print("$best\n")
    end
end
main()


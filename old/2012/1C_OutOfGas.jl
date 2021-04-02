
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        Ds,Ns,As = split(rstrip(readline(infile)))
        D = parse(Float64,Ds)
        N = parse(Int64,Ns)
        A = parse(Int64,As)
        NN = fill(0.00,N,2)
        for i in 1:N; NN[i,:] = [parse(Float64,x) for x in split(rstrip(readline(infile)))]; end
        AA::Vector{Float64} = [parse(Float64,x) for x in split(rstrip(readline(infile)))]
        ## Two observations
        ## a) Optimal strategy is to sit at the top for tt seconds and then let go of the brakes
        ## b) It is sufficient to check intersection at each of the endpoints 
        ## Doing algebra, we have x = 0.5*a*(t-tt)^2.  Given the coord of the other car as (t,x), we have
        ## tt >= t - sqrt(2*x1/a)

        ## Solve for the time when the other car crosses D
        tD = 0.00
        for i in 2:N
            if NN[i,2] >= D && NN[i-1,2] < D
                tD = NN[i-1,1] + (NN[i,1]-NN[i-1,1]) * (D - NN[i-1,2]) / (NN[i,2] - NN[i-1,2])
                break
            end
        end
        for a in AA
            mytt = max(0.00,tD-sqrt(2*D/a))
            for i in 1:N
                t = NN[i,1]
                x = NN[i,2]
                if x > D; continue; end
                cand = t - sqrt(2*x/a)
                mytt = max(cand,mytt)
            end
            ans = mytt + sqrt(2*D/a)
            print("$ans\n")
        end
    end
end

main()


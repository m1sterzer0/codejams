
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,X,Y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        targshell = Y+abs(X)
        numspent,curshell,inc = 0,0,1
        while numspent + inc <= N
            numspent += inc; inc += 4; curshell += 2
        end
        if targshell < curshell; print("1.000\n")
        elseif targshell > curshell; print("0.000\n")
        elseif X == 0; print("0.000\n")
        else
            numneeded = 1 + Y
            numavailable = N - numspent
            if numneeded > numavailable; print("0.000\n")
            else
                ## Do a simulation of the last shell (doing it with binomial coefficients) is
                ## a bit rough because of the magnitudes involved (need bigint code)
                sidemax = (inc-1)÷2
                state::Dict{Tuple{Int64,Int64},Float64} = Dict{Tuple{Int64,Int64},Float64}()
                state[(0,0)] = 1.000
                for i in 1:numavailable
                    newstate::Dict{Tuple{Int64,Int64},Float64} = Dict{Tuple{Int64,Int64},Float64}()
                    for ((a,b),v) in state
                        if a == sidemax
                            if !haskey(newstate,(a,b+1)); newstate[(a,b+1)] = 0.0; end
                            newstate[(a,b+1)] += v 
                        elseif a == b
                            if !haskey(newstate,(a+1,b)); newstate[(a+1,b)] = 0.0; end
                            newstate[(a+1,b)] += v
                        else
                            if !haskey(newstate,(a+1,b)); newstate[(a+1,b)] = 0.0; end
                            newstate[(a+1,b)] += 0.5*v
                            if !haskey(newstate,(a,b+1)); newstate[(a,b+1)] = 0.0; end
                            newstate[(a,b+1)] += 0.5*v
                        end
                    end
                    state = newstate
                    #for ((a,b),v) in state
                    #    print("DBG: i:$i a:$a b:$b v:$v\n")
                    #end
                end
                ans = 0.0
                for ((a,b),v) in state
                    if numneeded <= b; ans += v
                    elseif numneeded <= a; ans += 0.5*v
                    end
                end
                print("$ans\n")
            end
        end
    end
end

main()


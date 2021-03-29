
using Random

function solve(N::Int64,Q::Int64)
    print("1 2 3\n"); flush(stdout); a = gi(); if a == -1; exit(); end
    arr = a == 1 ? [2,1,3] : a == 2 ? [1,2,3] : [1,3,2]
    for i in 4:N
        x = solveit(arr,i)
        arr = vcat(arr[1:x-1],[i],arr[x:end])
    end
    ansstr = join(arr," ")
    print("$ansstr\n"); flush(stdout); a = gi(); if a == -1; exit(); end
end

function solveit(arr,i)
    l,r = 1,i
    while (l != r)
        if r-l == 1
            if l == 1
                print("$i $(arr[1]) $(arr[2])\n"); flush(stdout); a = gi(); if a == -1; exit(); end
                if a == i ; l = r; else; r = l; end
            else
                print("$i $(arr[1]) $(arr[l])\n"); flush(stdout); a = gi(); if a == -1; exit(); end
                if a == i ; r = l; else; l = r; end
            end
        else 
            numelem = r-l
            leftchunk = (numelem+2)÷3
            centerchunk = (numelem-leftchunk+1)÷2
            rightchunk = numelem-leftchunk-centerchunk
            idx1 = l+leftchunk-1
            idx2 = idx1 + centerchunk
            print("$i $(arr[idx1]) $(arr[idx2])\n"); flush(stdout); a = gi(); if a == -1; exit(); end
            if a == arr[idx1]; r = idx1; elseif a == i;  l = idx1+1; r = idx2; else; l=idx2+1; end 
        end
    end
    return l
end
            
gs()::String = rstrip(readline(stdin))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function main(infn="")
    tt,N,Q = gis()
    for qq in 1:tt
        solve(N,Q)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


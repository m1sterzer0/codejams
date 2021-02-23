
function findallkeys(mykeys::Vector{Int64},c2u::Vector{Int64},c2ks::Vector{Vector{Int64}},
                     k2c::Vector{Vector{Int64}},unlocked::Vector{Bool},
                     keysneeded::Vector{Int64},N::Int64)::Bool
    visited::Vector{Bool} = unlocked[:]
    q::Vector{Int64} = []
    for i in 1:N
        k = c2u[i]
        if unlocked[i] || mykeys[k] == 0; continue; end
        visited[i] = true
        push!(q,i)
    end

    keysfound::Vector{Int64} = fill(0,200)
    while !isempty(q)
        c = popfirst!(q)
        for k in c2ks[c]
            keysfound[k] += 1
            for j in k2c[k]
                if visited[j]; continue; end
                visited[j] = true
                push!(q,j)
            end
        end
    end
    for k in 1:200
        if keysneeded[k] > 0 && keysfound[k] == 0; return false; end
    end
    return true
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        K,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        KK = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        mykeys::Vector{Int64} = fill(0,200)
        for k in KK; mykeys[k] += 1; end
        c2u::Vector{Int64} = fill(0,N)
        c2ks::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:N]
        k2c::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:200]
        for i in 1:N
            A = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            c2u[i] = A[1]
            push!(k2c[A[1]],i)
            if A[2] > 0
                for j in A[3:end]; 
                    push!(c2ks[i],j)
                end
            end
        end

        ##Initial check to see if we have enough keys to unlock all of the chests
        keysneeded = [length(k2c[x])-mykeys[x] for x in 1:200]
        keysavailable = fill(0,200)
        for i in 1:N
            for j in c2ks[i]
                keysavailable[j] += 1
            end
        end
        good = true
        for i in 1:200
            if keysavailable[i] < keysneeded[i]; good = false; end
        end
        ##Initial check to see if we have a path to all the needed keys from the starting position
        unlocked::Vector{Bool} = fill(false,N)
        if !findallkeys(mykeys,c2u,c2ks,k2c,unlocked,keysneeded,N); 
            good = false
        end
        if !good; print("IMPOSSIBLE\n"); continue; end

        ans = []
        for i in 1:N
            for j in 1:N
                if unlocked[j]; continue; end
                k = c2u[j]
                if mykeys[k] == 0; continue; end
                ## change state assuming we unlock chest j
                unlocked[j] = true; mykeys[k] -= 1
                for kk in c2ks[j]; mykeys[kk] += 1; keysneeded[kk] -= 1; end
                if findallkeys(mykeys,c2u,c2ks,k2c,unlocked,keysneeded,N)
                    push!(ans,j)
                    break
                end
                ## undo the change, since unlocking chest j did not lead to a solution
                unlocked[j] = false; mykeys[k] += 1
                for kk in c2ks[j]; mykeys[kk] -= 1; keysneeded[kk] += 1; end
            end
        end
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

main()

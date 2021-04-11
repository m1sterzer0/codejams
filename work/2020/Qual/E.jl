function genCyclicLatinSquare(N)
    arr = fill(0,N,N)
    arr[1,:] = collect(1:N)
    for i in 2:N
        arr[i,2:N] = arr[i-1,1:N-1]
        arr[i,1] = arr[i-1,N]
    end
    return arr
end

function remaparr(arr,remap)
    N = size(arr)[1]
    arr2 = fill(0,N,N)
    for i in 1:N
        for j in 1:N
            arr2[i,j] = remap[arr[i,j]]
        end
    end
    return arr2
end

function solvearr(N, A, B, C)
    arr = genCyclicLatinSquare(N)
    remap = fill(0,N)
    left = Set(collect(1:N))
    if B!=0 && C!= 0
        arr[1,:],arr[2,:] = arr[2,:],arr[1,:]
    elseif B!=0 && C == 0
        if N % 2 == 0
            arr[N÷2,:],arr[N,:] = arr[N,:],arr[N÷2,:]
        else
            arr[N-2,:] = vcat([2],collect(4:N-1),[1,N,3])
            arr[N-1,:] = vcat([3], [i%2==0 ? i+1 : i-1 for i in 4:N], [2,1] )
            sb = fill(true,N)
            for j in 1:N
                fill!(sb,true)
                for i in 1:N-1; sb[arr[i,j]] = false; end
                for k in 1:N; if sb[k]; arr[N,j] = k; end; end
            end
        end
    end

    if B!=0 && C == 0 && N%2 == 0
        remap[1] = A; delete!(left,A)
        remap[N÷2+1] = B; delete!(left,B)
        idx = 2
        for x in left
            remap[idx] = x; idx += 1
            if idx == N÷2+1; idx += 1; end
        end
    else
        indices = Set(collect(1:N))
        remap[1] = A; delete!(left,A); delete!(indices,1)
        if B > 0; remap[2] = B; delete!(left,B); delete!(indices,2); end
        if C > 0; remap[N] = C; delete!(left,C); delete!(indices,N); end
        for (a,b) in zip([x for x in indices],[x for x in left]); remap[a] = b; end
    end
    return remaparr(arr,remap)
end

function solveLarge(N::Int64,K::Int64)
    ans::Array{Int64,2} = fill(0,N,N)
    if K == N^2-1 || K == N+1 || (N==3 && K==5) || (N==3 && K==7); return ans; end
    if K % N == 0; return solvearr(N,K÷N,0,0); end
    for A in 1:N
        minval = (A == 1 ? 4 : 2) + (N-2)*A
        maxval = (A == N ? 2N-2 : 2N) + (N-2)*A
        if K < minval || K > maxval; continue; end
        residual = K - (N-2)*A
        B = residual ÷ 2
        C = residual - B
        if B == A && C == N; continue; end  ## 4 13 case is first to require this
        if      B == A; B -= 1; C += 1
        elseif  C == A; C += 1; B -= 1
        end
        if (B == A || C == A || B < 1 || C < 1 || B > N || C > N); print("ERROR! A:$A B:$B C:$C\n"); end
        if B == C; return solvearr(N,A,B,0)
        else; return solvearr(N,A,B,C)
        end
    end
end

function regress()
    for N in 2:50
        for K in N:N^2
            print("Testcase: $N $K\n")
            ans = solveLarge(N,K)
            if ans[1,1] == 0
                print("IMPOSSIBLE\n")
            else
                print("POSSIBLE\n")
                for i in 1:N; astr = join(ans[i,:]," "); print("$astr\n"); end
            end
        end
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        ans = solveLarge(N,K)
        if ans[1,1] == 0
            print("IMPOSSIBLE\n")
        else
            print("POSSIBLE\n")
            for i in 1:N; astr = join(ans[i,:]," "); print("$astr\n"); end
        end
    end
end

#regress()
main()

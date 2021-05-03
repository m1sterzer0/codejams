
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function genCyclicLatinSquare(N::I)
    arr::Array{I,2} = fill(0,N,N)
    arr[1,:] = collect(1:N)
    for i::I in 2:N
        arr[i,2:N] = arr[i-1,1:N-1]
        arr[i,1] = arr[i-1,N]
    end
    return arr
end

function remaparr(arr::Array{I,2},remap::VI)
    N::I = size(arr)[1]
    arr2::Array{I,2} = fill(0,N,N)
    for i::I in 1:N
        for j::I in 1:N
            arr2[i,j] = remap[arr[i,j]]
        end
    end
    return arr2
end

function solvearr(N::I, A::I, B::I, C::I)
    arr::Array{I,2} = genCyclicLatinSquare(N)
    remap::VI = fill(0,N)
    left::SI = Set(collect(1:N))
    if B!=0 && C!= 0
        arr[1,:],arr[2,:] = arr[2,:],arr[1,:]
    elseif B!=0 && C == 0
        if N % 2 == 0
            arr[N÷2,:],arr[N,:] = arr[N,:],arr[N÷2,:]
        else
            arr[N-2,:] = vcat([2],collect(4:N-1),[1,N,3])
            arr[N-1,:] = vcat([3], [i%2==0 ? i+1 : i-1 for i in 4:N], [2,1] )
            sb::VB = fill(true,N)
            for j::I in 1:N
                fill!(sb,true)
                for i::I in 1:N-1; sb[arr[i,j]] = false; end
                for k::I in 1:N; if sb[k]; arr[N,j] = k; end; end
            end
        end
    end

    if B!=0 && C == 0 && N%2 == 0
        remap[1] = A; delete!(left,A)
        remap[N÷2+1] = B; delete!(left,B)
        idx::I = 2
        for x::I in left
            remap[idx] = x; idx += 1
            if idx == N÷2+1; idx += 1; end
        end
    else
        indices::SI = Set(collect(1:N))
        remap[1] = A; delete!(left,A); delete!(indices,1)
        if B > 0; remap[2] = B; delete!(left,B); delete!(indices,2); end
        if C > 0; remap[N] = C; delete!(left,C); delete!(indices,N); end
        for (a,b) in zip([x for x in indices],[x for x in left]); remap[a] = b; end
    end
    return remaparr(arr,remap)
end

function solve(N::I,K::I)
    ans::Array{I,2} = fill(0,N,N)
    if K == N^2-1 || K == N+1 || (N==3 && K==5) || (N==3 && K==7); return ans; end
    if K % N == 0; return solvearr(N,K÷N,0,0); end
    for A in 1:N
        minval::I = (A == 1 ? 4 : 2) + (N-2)*A
        maxval::I = (A == N ? 2N-2 : 2N) + (N-2)*A
        if K < minval || K > maxval; continue; end
        residual::I = K - (N-2)*A
        B::I = residual ÷ 2
        C::I = residual - B
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

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        ans = solve(N,K)
        if ans[1,1] == 0
            print("IMPOSSIBLE\n")
        else
            print("POSSIBLE\n")
            for i in 1:N; astr = join(ans[i,:]," "); print("$astr\n"); end
        end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")


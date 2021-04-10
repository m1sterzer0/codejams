
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

function solveSmall(N::Int64)
    ## For the small, we are going to implement insertion sort with binary search
    ## Here we coerce the median function to act like less than
    print("1 2 3\n"); flush(stdout); res = gi(); if res == -1; exit(1); end
    arr::VI = res == 1 ? [2,1,3] : res == 2 ? [1,2,3] : [1,3,2]
    for i in 4:N; 
        p = myInsertSort1(arr,i)
        arr = vcat(arr[1:p-1],[i],arr[p:end])
    end
    astr = join(arr," ")
    print("$astr\n"); flush(stdout); res = gi(); if res == -1; exit(1); end
end

function myInsertSort1(arr::VI,idx::I)
    (l,r,elem) = (1,idx,idx)
    while (l != r)
        m = (l+r)>>1
        if m == 1
            print("$(arr[1]) $(arr[2]) $elem\n"); flush(stdout)
            res = gi(); if res == -1; exit(1); end
            ## possible orders are (elem,arr[1],arr[2]), (arr[1],elem,arr[2]) && (arr[1],arr[2],elem)
            if res == arr[1]; r=m; else l=m+1; end
        else
            print("$(arr[1]) $(arr[m]) $elem\n"); flush(stdout)
            res = gi(); if res == -1; exit(1); end
            ## possible orders are (elem,arr[1],arr[m]), (arr[1],elem,arr[m]) && (arr[1],arr[m],elem)
            if res == arr[1] || res == elem; r=m; else l=m+1; end
        end
    end
    return l
end

function solveLarge(N::Int64)
    ## For the small, we are going to implement insertion sort with binary search
    ## Here we coerce the median function to act like less than
    print("1 2 3\n"); flush(stdout); res = gi(); if res == -1; exit(1); end
    arr::VI = res == 1 ? [2,1,3] : res == 2 ? [1,2,3] : [1,3,2]
    for i in 4:N; 
        p = myInsertSort2(arr,i)
        arr = vcat(arr[1:p-1],[i],arr[p:end])
    end
    astr = join(arr," ")
    print("$astr\n"); flush(stdout); res = gi(); if res == -1; exit(1); end
end

function myInsertSort2(arr::VI,idx::I)
    (l,r,elem) = 1,idx,idx
    while (l != r)
        if r-l == 1
            ## Revert back to insert sort code (above)
            m = (l+r)>>1
            if m == 1
                print("$(arr[1]) $(arr[2]) $elem\n"); flush(stdout)
                res = gi(); if res == -1; exit(1); end
                ## possible orders are (elem,arr[1],arr[2]), (arr[1],elem,arr[2]) && (arr[1],arr[2],elem)
                if res == arr[1]; r=m; else l=m+1; end
            else
                print("$(arr[1]) $(arr[m]) $elem\n"); flush(stdout)
                res = gi(); if res == -1; exit(1); end
                ## possible orders are (elem,arr[1],arr[m]), (arr[1],elem,arr[m]) && (arr[1],arr[m],elem)
                if res == arr[1] || res == elem; r=m; else l=m+1; end
            end
        else
            ## Split region into 3 chunks           
            numelem = r-l
            leftchunk = (numelem+2)÷3
            centerchunk = (numelem-leftchunk+1)÷2
            rightchunk = numelem-leftchunk-centerchunk
            idx1 = l+leftchunk-1
            idx2 = idx1 + centerchunk
            print("$elem $(arr[idx1]) $(arr[idx2])\n"); flush(stdout)
            res = gi(); if res == -1; exit(1); end
            ## possible orders are (elem,arr[idx1],arr[idx2]), (arr[idx1],elem,arr[idx2]) && (arr[idx1],arr[idx2],elem)
            if res == arr[idx1]; r = idx1; elseif res == elem;  l = idx1+1; r = idx2; else; l=idx2+1; end 
        end
    end
    return l
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,N::I,Q::I = gis()
    for qq in 1:tt
        #solveSmall(N)
        solveLarge(N)
    end
end


Random.seed!(8675309)
main()
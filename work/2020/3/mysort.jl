using Random

function daveSort!(v::AbstractVector)
    return daveQuickSort!(v,1,length(v))
end

function daveInsertionSort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds for i in lo+1:hi
        j=i; x=v[i]
        while j > lo
            if x < v[j-1]; v[j] = v[j-1]; j-=1; continue; end
            break
        end
        v[j] = x
    end
    return v
end

@inline function daveSelectPivot!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds begin
        mi = lo + ((hi-lo) >>> 0x01)
        if v[lo] < v[mi]; v[mi],v[lo]=v[lo],v[mi]; end
        if v[hi] < v[lo] 
            if v[hi] < v[mi]
                v[hi], v[lo], v[mi] = v[lo], v[mi], v[hi]
            else
                v[hi], v[lo] = v[lo], v[hi]
            end
        end
        return v[lo]
    end
end

function davePartition!(v::AbstractVector, lo::Integer, hi::Integer)
    pivot = daveSelectPivot!(v, lo, hi)
    i, j = lo, hi
    @inbounds while true
        i += 1; j -= 1
        while v[i] < pivot; i += 1; end;
        while pivot < v[j]; j -= 1; end;
        i >= j && break
        v[i], v[j] = v[j], v[i]
    end
    v[j], v[lo] = pivot, v[j]
    return j
end

function daveQuickSort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds while lo < hi
        hi-lo <= 20 && return daveInsertionSort!(v, lo, hi)
        j = davePartition!(v, lo, hi)
        if j-lo < hi-j
            lo < (j-1) && daveQuickSort!(v, lo, j-1)
            lo = j+1
        else
            j+1 < hi && daveQuickSort!(v, j+1, hi)
            hi = j-1
        end
    end
    return v
end

function test(nn::Int64,arrlen::Int64)
    Random.seed!(8675309)
    for i in 1:nn
        print("Iteration $i\n")
        a = rand(1:arrlen,arrlen)
        b = copy(a)
        daveSort!(a)
        sort!(b)
        if a != b
            print("ERROR\n")
            print("    a:$a\n")
            print("    b:$b\n")
        end
    end
end

#test(10,10)
#test(10,30)
#test(10,100)
#test(100,1000000)

using Profile, StatProfilerHTML
Profile.clear()
@profile test(10,10)
Profile.clear()
@profilehtml test(100,1000000)
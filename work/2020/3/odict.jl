using Random

mutable struct myAVLDict
    numNodes::Int32
    maxNodes::Int32
    keys::Vector{Int64}
    vals::Vector{Int32}
    left::Vector{Int32}
    right::Vector{Int32}
    ht::Vector{Int8}
    scratch::Vector{Int32}
    myAVLDict() = new(0,0,[],[],[],[],[],[])
end

function init(dd::myAVLDict,maxNodes::Int64)
    dd.numNodes = 0
    dd.maxNodes = Int32(maxNodes)
    dd.keys  = fill(0,maxNodes)
    dd.vals  = fill(Int32(0),maxNodes)
    dd.left  = fill(Int32(0),maxNodes)
    dd.right = fill(Int32(0),maxNodes)
    dd.ht    = fill(Int8(0),maxNodes)
end

function reset(dd::myAVLDict)
    for i in 1:dd.numNodes
        dd.keys[i] = 0
        dd.vals[i] = Int32(0)
        dd.left[i] = Int32(0)
        dd.right[i] = Int32(0)
        dd.ht[i] = Int8(0)
    end
    dd.numNodes = 0
end

getHt(dd::myAVLDict,n::Int32) = n == 0 ? 0 : dd.ht[n]

function updateHeight(dd::myAVLDict,n::Int32)
    if n == 0; return; end
    dd.ht[n] = 1 + max(getHt(dd,dd.left[n]),getHt(dd,dd.right[n]))
end 

function rotLeft(dd::myAVLDict,z::Int32)
    y = dd.right[z]
    (t1,t2,t3) = (dd.left[z],dd.left[y],dd.right[y])
    (dd.keys[y],dd.keys[z]) = (dd.keys[z],dd.keys[y])
    (dd.vals[y],dd.vals[z]) = (dd.vals[z],dd.vals[y])
    dd.left[y] = t1; dd.right[y] = t2
    dd.left[z] = y; dd.right[z] = t3
    updateHeight(dd,y); updateHeight(dd,z)
end

function rotRight(dd::myAVLDict,z::Int32)
    y = dd.left[z]
    (t1,t2,t3) = (dd.right[z],dd.right[y],dd.left[y])
    (dd.keys[y],dd.keys[z]) = (dd.keys[z],dd.keys[y])
    (dd.vals[y],dd.vals[z]) = (dd.vals[z],dd.vals[y])
    dd.right[y] = t1; dd.left[y] = t2
    dd.right[z] = y; dd.left[z] = t3
    updateHeight(dd,y); updateHeight(dd,z)
end

function insertKV(dd::myAVLDict,k::Int64,v::Int32)
    dd.numNodes += 1
    dd.keys[dd.numNodes] = k
    dd.vals[dd.numNodes] = v
    dd.ht[dd.numNodes] = 1
    if dd.numNodes == 1; return; end
    scratch::Vector{Int32} = dd.scratch; n::Int32 = Int32(1)
    leftFlag::Bool = true
    while true
        if k < dd.keys[n]
            if dd.left[n] > 0; push!(scratch,n); n = dd.left[n]; else; leftFlag = true; break; end
        else 
            if dd.right[n] > 0; push!(scratch,n); n = dd.right[n]; else; leftFlag = false; break; end
        end
    end
    if leftFlag; dd.left[n] = dd.numNodes; else; dd.right[n] = dd.numNodes; end
    ht::Int8 = Int8(2)
    htinc::Int8 = Int8(1)
    if dd.ht[n] >= ht; empty!(scratch); return; end
    dd.ht[n] = ht
    while !isempty(scratch)
        n = pop!(scratch)
        ht += htinc
        if dd.ht[n] >= ht; break; end
        l = dd.left[n]
        r = dd.right[n]
        lht = l == Int32(0) ? Int8(0) : dd.ht[l]
        rht = r == Int32(0) ? Int8(0) : dd.ht[r]
        if lht > rht+htinc
            l2 = dd.left[l]
            if l2 > 0 && dd.ht[l2]+htinc == lht; rotRight(dd,n); else; rotLeft(dd,l); rotRight(dd,n); end
            break
        elseif rht > lht+htinc
            r2 = dd.right[r]
            if r2 > 0 && dd.ht[r2]+htinc == rht; rotLeft(dd,n); else; rotRight(dd,r); rotLeft(dd,n); end
            break
        end
        dd.ht[n] = ht
    end
    empty!(scratch)
end

function searchKey(dd::myAVLDict,k::Int64)
    if dd.numNodes == 0; return 0; end
    n::Int32 = Int32(1)
    nz::Int32 = Int32(0)
    keys::Vector{Int64} = dd.keys
    left::Vector{Int32} = dd.left
    right::Vector{Int32} = dd.right
    while (n != nz)
        kk::Int64 = keys[n]
        if k == kk; break; end
        n = k < kk ? left[n] : right[n]
    end
    return n
end

Base.haskey(dd::myAVLDict,k::Int64) = searchKey(dd,k) != 0

function getValue(dd::myAVLDict,k::Int64)::Int32
    n = searchKey(dd,k); return n == 0 ? Int32(-1) : dd.vals[n]
end

function setValue(dd::myAVLDict,k::Int64,v::Int32)
    n = searchKey(dd,k)
    if n == 0; insertKV(dd,k,v); else; dd.vals[n] = v; end
end

function testit(dsize::Int64,numwrites::Int64,numiter::Int64)
    Random.seed!(8675309)
    print("STARTING\n")
    d = myAVLDict()
    init(d,dsize)
    check = Dict{Int64,Int32}()

    print("GENERATING RANDOM NUMBERS\n")

    x = rand(1:numwrites,numwrites)
    x2 = rand(1:numwrites,numwrites)
    y = rand(Int32(1):Int32(1000000),numwrites)

    for i in 1:numiter
        print("ITERATION $i\n")
        reset(d)
        empty!(check)

        #print("SETTING VALUE\n")
        for (xx,yy) in zip(x,y)
            setValue(d,xx,yy)
            check[xx] = yy
        end
        #print("CHECKING KEYS\n")
        for xx in x2
            zz1 = haskey(d,xx)
            zz2 = haskey(check,xx)
            if zz1 != zz2
                print("ERROR -- missing key\n")
                haskey(d,xx)
            end
        end
        #print("CHECKING VALUES\n")
        for xx in x
            yy1 = getValue(d,xx)
            yy2 = check[xx]
            if yy1 != yy2
                print("ERROR -- value mismatch\n")
                getValue(d,xx)
            end
        end
    end
    print("DONE\n")
end

using Profile, StatProfilerHTML
Profile.clear()
@profile testit(2000,10,1)
Profile.clear()
@profilehtml testit(5000000,1000000,10)
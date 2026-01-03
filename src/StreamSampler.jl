module StreamSampler

using DataStructures
using Random

export WRS, result!

struct Entry{T}
    item::T
    key::Float64
    function Entry{T}(item, key) where {T}
        new(item, key)
    end
end
Base.isless(e1::Entry, e2::Entry) = e1.key < e2.key

"""
    WRS{T}

A weighted random sampler that selects `k` items from a stream using reservoir sampling.

# Fields
- `k::Int`: The number of items to select
- `rng::AbstractRNG`: The random number generator to use
- `heap::BinaryMaxHeap{Entry{T}}`: Internal heap storing the current reservoir

# Examples
```julia
rng = Random.Xoshiro(12345)
sampler = WRS{Int}(10, rng)
push!(sampler, 42, 5.0)
```
"""
struct WRS{T}
    k::Int
    rng::AbstractRNG
    heap::BinaryMaxHeap{Entry{T}}
    function WRS{T}(k::Int, rng::AbstractRNG) where {T}
        heap = BinaryMaxHeap{Entry{T}}()
        if k < 1
            error("Weighted random sampler requires k (number of samples to collect) to be >= 1. It is $k")
        end
        sizehint!(heap, k)
        new(k, rng, heap)
    end
end

"""
    push!(sampler, item)

Adds the item to the sampler with weight 1.0.
"""
Base.push!(sampler::WRS{T}, item::T) where {T} = push!(sampler, item, 1.0)

"""
    push!(sampler, item, weight)

Adds the item to the sampler with the given weight.

# Arguments
- `sampler::WRS{T}`: The weighted random sampler
- `item::T`: The item to add to the stream
- `weight::Float64`: The weight of the item (must be positive)

# Throws
- `ArgumentError`: If weight is not positive

# Examples
```julia
push!(sampler, 42, 5.0)
```
"""
function Base.push!(sampler::WRS{T}, item::T, weight::Float64) where {T}
    weight > 0 || throw(ArgumentError("weight must be positive, got $weight"))
    
    # Sample until we get a non-zero value to avoid log(0) = Inf
    x = 0.0
    while x == 0.0
        x = rand(sampler.rng, Float64)
    end
    key = -log(x) / weight
    
    if length(sampler.heap) < sampler.k || first(sampler.heap).key > key
        if length(sampler.heap) >= sampler.k
            pop!(sampler.heap)
        end
        push!(sampler.heap, Entry{T}(item, key))
    end
end

"""
    result!(sampler)

Returns the weighted random sample of the stream of values previously
pushed to the sampler, and clears the sampler's reservoir.
"""
function result!(sampler::WRS{T}) where {T}
    map(x -> x.item, extract_all_rev!(sampler.heap))
end

end # module StreamSampler

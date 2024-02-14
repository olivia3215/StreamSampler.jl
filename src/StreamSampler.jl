module StreamSampler

using DataStructures
using Random

export WRS, result!

greet() = print("Hello World!")

struct Entry{T}
    item::T
    # weight::Float64
    key::Float64
    function Entry{T}(item, weight, key) where {T}
        new(item, key)
    end
end
Base.isless(e1::Entry, e2::Entry) = e1.key < e2.key

# A weghted random sampler
struct WRS{T}
    k::Int
    rng::AbstractRNG
    function WRS{T}(k::Int, rng::AbstractRNG) where {T}
        heap=BinaryMaxHeap{Entry{T}}()
        if k < 1
            error("Wighted random sampler requires k (number of samples to collect) to be >= 1. It is $k")
        end
        sizehint!(heap, k)
        new(k, rng, heap)
    end
    heap::BinaryMaxHeap{Entry{T}}
end

"""
    push!(sampler, item)

Adds the item to the sampler with weight 1.0.
"""
Base.push!(sampler::WRS{T}, item::T) where {T} = push!(sampler, item, 1.0)

"""
    push!(sampler, item, weight)

Adds the item to the sampler with the given weight.
"""
function Base.push!(sampler::WRS{T}, item::T, weight::Float64) where {T}
    x = rand(sampler.rng, Float64)
    key = -log(x) / weight
    if length(sampler.heap) < sampler.k
        entry = Entry{T}(item, weight, key)
        push!(sampler.heap, entry)
    elseif first(sampler.heap).key > key
        pop!(sampler.heap)
        entry = Entry{T}(item, weight, key)
        push!(sampler.heap, entry)
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

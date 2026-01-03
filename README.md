# StreamSampler.jl

This is a Julia package for the online Weighted Random Sampling problem.

We provide a utility that can select a given fixed number of values from a stream of weighted items. The probability that an item will be included in the result is proportional to the the weight of the item. Selection is without replacement, i.e. no item will appear twice in the output. The input is fed to the API one item at a time, and then you can ask for the contents of the reservoir at any time, which contains the result.

## How It Works

We use a one-pass reservoir algorithm based on [*Weighted Random Sampling* [2005; Efraimidia, Spirakis]](https://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf). The algorithm maintains a "reservoir" of at most `k` items, where `k` is the desired sample size.

### Key Concepts

**Reservoir Sampling:** The algorithm processes items one at a time from a stream. For each item, it computes a random "key" value that determines whether the item should be included in the reservoir. Items with higher keys replace items with lower keys in the reservoir, ensuring that items with higher weights are more likely to be selected.

**Keys:** Each item is assigned a key value computed as `-log(r) / weight`, where `r` is a random value between 0 and 1, and `weight` is the item's weight. Higher weights result in smaller keys (since we divide by weight), and smaller keys are more likely to remain in the reservoir (since we keep the items with the smallest keys).

**Max Heap:** We use a max heap data structure to efficiently maintain the reservoir. The heap stores items sorted by their keys, with the largest key at the top. When the reservoir is full and a new item arrives with a smaller key than the maximum, we remove the item with the largest key and add the new item.

To avoid the need for high-precision computations, keys are computed and stored as the logarithm of the key described in that paper. We do not yet implement the exponential jumps described in that paper, though that would likely result in a significant improvement in performance. See also [*Wikipedia*, Reservoir sampling, Algorithm A-Res](https://en.wikipedia.org/wiki/Reservoir_sampling#Algorithm_A-Res).

## Usage

You use the package as follows:

```julia
using StreamSampler

k = 12    # The number of elements to select
T = ...   # The type of the elements in the stream
rng = ... # The random generator to use
sampler = StreamSampler.WRS{T}(k, rng)

# repeatedly add items to the sampler
push!(sampler, item, itemweight)
...

res = result!(sampler) # return a sample of k items of type T and empty the reservoir
```

If fewer than `k` items have been pushed, the result is all items pushed.

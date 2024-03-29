# StreamSampler.jl

This is a Julia package for the online Weighted Random Sampling problem.

We provide a utility that can select a given fixed number of values from a stream of weighted items. The probability that an item will be included in the result is proportional to the the weight of the item. Selection is without replacement, i.e. no item will appear twice in the output. The input is fed to the API one item at a time, and then you can ask for the contents of the reservoir at any time, which contains the result.

We use a one-pass reservior algorithm based on [*Weighted Random Sampling* [2005; Efraimidia, Spirakis]](https://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf). To avoid the need for high-precision computations, keys are computed and stored as the logarithm of the key described in that paper. We do not yet implement the exponential jumps described in that paper, though that would likely result in a significant improvement in performance. See also [*Wikipedia*, Reservoir sampling, Algorithm A-Res](https://en.wikipedia.org/wiki/Reservoir_sampling#Algorithm_A-Res).

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
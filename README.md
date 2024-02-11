# StreamSampler.jl

This is a Julia package for the online Weighted Random Sampling problem.

We provide a utility that can select a given fixed number of values from a stream of weighted items, where the weights of the items are proportional to the probability that the item will be included in the result. Selection is without replacement.

We use a one-pass reservior algorithm based on (https://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf)[*Weighted Random Sampling* [2005; Efraimidia, Spirakis]]. To avoid the need for high-precision computations, keys are computed and stored as the logarithm of the key described in that paper. We do not implement the exponential jumps described in that paper, though that would likely result in a significant improvement in performance.

## Usage

You use the package as follows:

```julia
using StreamSampler

k = 12    # The number of elements to select
T = ...   # The type of the elements in the stream
rng = ... # optionally, you can specify the random generator to use
sampler = StreamSampler.WRS{T}(k, rng)

# repeatedly add items to the sampler
add(sampler, item, itemweight)
...

res = result(sampler) # returns a sample of k items of type T
```

module StreamSamplerTests

using StreamSampler
using Test
using Random
using DataStructures

@testset "check that weights are obeyed" begin
    # We use a fixed seed so that we don't get occasional "lucky" faulures,
    # since it is possible, however unlikely, to get a one-in-a-million
    # selection of one of the low-weighted values.
    rng = Xoshiro(12345)
    sampler = StreamSampler.WRS{Int}(6, rng)
    push!(sampler, 0, 1.0)
    push!(sampler, 1, 100000000.0)
    push!(sampler, 2, 1.0)
    push!(sampler, 3, 100000000.0)
    push!(sampler, 4, 1.0)
    push!(sampler, 5, 100000000.0)
    push!(sampler, 6, 1.0)
    push!(sampler, 7, 100000000.0)
    push!(sampler, 8, 1.0)
    push!(sampler, 9, 100000000.0)
    res = result!(sampler)

    # Given the weights, we expect only one even number in the result.
    cnt = count(x -> iseven(x), res)
    @test cnt == 1

    # We expect every odd number in the result.
    should_contain = SortedSet{Int}([1, 3, 5, 7, 9])
    actually_contains = SortedSet{Int}(res)
    @test issubset(should_contain, actually_contains)
end

@testset "Boundary conditions 1" begin
    rng = Xoshiro(12345)
    @test_throws ErrorException StreamSampler.WRS{Int}(0, rng)
    @test_throws ErrorException StreamSampler.WRS{Int}(-1, rng)
    StreamSampler.WRS{Int}(1, rng)
end

@testset "Boundary conditions 2" begin
    rng = Xoshiro(12345)
    k = 2
    for i in 0:4
        sampler = StreamSampler.WRS{Int}(k, rng)
        for j in 1:i
            push!(sampler, j, 1.0)
        end
        expected_size = if i < k; i; else k; end
        r = result!(sampler)
        @test length(r) == expected_size
    end
end

end

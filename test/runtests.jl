using StreamSampler
using Test
using Random
using DataStructures

@testset "check that weights are obeyed" begin
    # We use a fixed seed so that we don't get occasional "lucky" failures,
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

@testset "Weight validation" begin
    rng = Xoshiro(12345)
    sampler = StreamSampler.WRS{Int}(5, rng)
    @test_throws ArgumentError push!(sampler, 1, 0.0)
    @test_throws ArgumentError push!(sampler, 2, -1.0)
    @test_throws ArgumentError push!(sampler, 3, -0.5)
    # Positive weights should work
    push!(sampler, 4, 1.0)
    push!(sampler, 5, 0.1)
    push!(sampler, 6, 100.0)
    res = result!(sampler)
    @test length(res) == 3
end

@testset "Two-argument push!" begin
    rng = Xoshiro(12345)
    sampler = StreamSampler.WRS{Int}(3, rng)
    push!(sampler, 1)  # Should use default weight of 1.0
    push!(sampler, 2)
    push!(sampler, 3)
    res = result!(sampler)
    @test length(res) == 3
    @test 1 in res
    @test 2 in res
    @test 3 in res
end

@testset "Empty sampler behavior" begin
    rng = Xoshiro(12345)
    sampler = StreamSampler.WRS{Int}(5, rng)
    res = result!(sampler)
    @test length(res) == 0
    @test isempty(res)
end

@testset "result! clears reservoir" begin
    rng = Xoshiro(12345)
    sampler = StreamSampler.WRS{Int}(3, rng)
    push!(sampler, 1, 1.0)
    push!(sampler, 2, 1.0)
    push!(sampler, 3, 1.0)
    res1 = result!(sampler)
    @test length(res1) == 3
    res2 = result!(sampler)
    @test length(res2) == 0
    @test isempty(res2)
end

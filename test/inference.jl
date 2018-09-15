# NOTE: these currently just test that the inference methods do not crash
# put longer-running statistical tests of inference methods elsewhere

@testset "importance sampling" begin

    @gen function model()
        x = @addr(normal(0, 1), :x)
        @addr(normal(x, 1), :y)
    end

    @gen function proposal()
        @addr(normal(0, 2), :x)
    end

    y = 2.
    observations = DynamicChoiceTrie()
    set_leaf_node!(observations, :y, y)
    
    n = 4

    (traces, log_weights, lml_est) = importance_sampling(model, (), observations, n)
    @test length(traces) == n
    @test length(log_weights) == n
    @test isapprox(logsumexp(log_weights), 0., atol=1e-14)
    @test !isnan(lml_est)
    for trace in traces
        @test get_choices(trace)[:y] == y
    end

    (traces, log_weights, lml_est) = importance_sampling(model, (), observations, proposal, (), n)
    @test length(traces) == n
    @test length(log_weights) == n
    @test isapprox(logsumexp(log_weights), 0., atol=1e-14)
    @test !isnan(lml_est)
    for trace in traces
        @test get_choices(trace)[:y] == y
    end

    (trace, lml_est) = importance_resampling(model, (), observations, n)
    @test isapprox(logsumexp(log_weights), 0., atol=1e-14)
    @test !isnan(lml_est)
    @test get_choices(trace)[:y] == y

    (trace, lml_est) = importance_resampling(model, (), observations, proposal, (), n)
    @test isapprox(logsumexp(log_weights), 0., atol=1e-14)
    @test !isnan(lml_est)
    @test get_choices(trace)[:y] == y
end
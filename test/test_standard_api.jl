using Test
using Mimi

@testset "Standard API" begin 

# Test that the function does not error and returns a valid value
    scc1 = MimiPAGE2009.compute_scc(year=2020)
    @test scc1 isa Float64

# Test that a higher discount rate makes a lower scc value
    scc2 = MimiPAGE2009.compute_scc(year=2020, eta=0., prtp=0.03)
    @test scc2 < scc1   

# Test with a modified model
    m = MimiPAGE2009.get_model()
    set_param!(m, :tcr_transientresponse, 3)
    scc3 = MimiPAGE2009.compute_scc(m, year=2020)
    @test scc3 > scc1

# Test get_marginal_model
    mm = MimiPAGE2009.get_marginal_model(year=2040)
    mm[:ClimateTemperature, :rt_realizedtemperature]

# Test compute_scc_mm
    result = MimiPAGE2009.compute_scc_mm(year=2050)
    @test result.scc < scc1
    @test result.mm isa Mimi.MarginalModel

# Test Monte Carlo SCC support
    sccs1 = MimiPAGE2009.compute_scc(year=2020, n=10, seed=350)
    sccs2 = MimiPAGE2009.compute_scc(year=2020, n=10, seed=350)
    @test sccs1 == sccs2

    sccs3 = MimiPAGE2009.compute_scc(year=2020, n=10, seed=351)
    @test sccs3 != sccs1

end
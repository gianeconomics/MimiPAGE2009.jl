using Mimi
using MimiPAGE2009
using Dates

function monte_carlo_compute_scc(m::Model = MimiPAGE2009.get_model(); year::Union{Int, Nothing} = nothing, trials = 10000, pulse_size=100000., output_dir = nothing, save_trials = false) 
    
    page_years = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]
    page_year_0 = 2008
    year === nothing ? error("Must specify an emission year. Try `monte_carlo_compute_scc(m, year=2020)`.") : nothing
    !(year in page_years) ? error("Cannot compute the scc for year $year, year must be within the model's time index $page_years.") : nothing    

    output_dir = output_dir === nothing ? joinpath(@__DIR__, "output_PAGE2009/", "SCC $(Dates.format(now(), "yyyy-mm-dd HH-MM-SS")) MC$trials") : output_dir
    mkpath("$output_dir/results")
    save_trials ? trials_output_filename = joinpath(@__DIR__, "$output_dir/trials.csv") : trials_output_filename = nothing 

    
    
    scc_file = joinpath(output_dir, "scc.csv")
    open(scc_file, "w") do f 
        write(f, "trial, SCC: $year\n")
    end
    
    mcs = MimiPAGE2009.getsim()
    
    scenario_args = Any[
        :years           => year
        :pulse_sizes   => pulse_size
    ] 
    
    function _scenario_func(mcs::SimulationInstance, tup::Tuple)
        
        (year, pulse_size) = tup
    
    end
        
    
    function scc_calculation(mcs::SimulationInstance, trialnum::Int, ntimesteps::Int, tup::Tuple)
        
        (year, pulse_size) = tup
        
        base = mcs.models[1]
        eta = base[:EquityWeighting, :emuc_utilityconvexity]
        prtp = base[:EquityWeighting, :ptp_timepreference]/100
    
        scc_results = MimiPAGE2009.compute_scc(base, year=year, eta=eta, prtp=prtp, pulse_size=pulse_size)
    
        open(scc_file, "a") do f 
            write(f, "$trialnum, $scc_results\n")
        end
    
        return nothing
    end
    
    scc_data = run(mcs, m, trials;
             trials_output_filename = trials_output_filename,             
             results_output_dir = "$output_dir/results",
             scenario_args = scenario_args,
             scenario_func = _scenario_func,  
             post_trial_func = scc_calculation)
    
    return scc_data
end

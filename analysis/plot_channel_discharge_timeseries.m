% Plot suite of ISSM-GlaDS simulations
addpath('../00_synth_forcing/')
set_paths;

cases = [1, 2, 3];

case_names = {'Turbulent 5/4', 'Turbulent 3/2', 'Laminar',...
    'Transition 5/4', 'Transition 3/2'};

figure;
hold on
for casenum=cases
    issm_out = load(sprintf('../00_synth_forcing/RUN/output_%03d.mat', casenum));
    md = issm_out.md;
    Q = abs([md.results.TransientSolution.ChannelDischarge]);
    tt = [md.results.TransientSolution.time];
    plot(tt, sum(Q, 1), 'DisplayName', case_names{casenum})

end

grid on
xlabel('Years')
ylabel('Sum of channel discharge')
legend('Location', 'northoutside', 'NumColumns', 3)
print('figures/timeseries_total_channel_discharge', '-dpng', '-r600')
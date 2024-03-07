% Plot suite of ISSM-GlaDS simulations
addpath('../00_synth_forcing/')
set_paths;

cases = [1, 2, 3];
% 
% case_names = {'Turbulent 5/4', 'Turbulent 3/2', 'Laminar',...
%     'Transition 5/4', 'Transition 3/2'};

case_names = {'Turbulent 5/4',  'Turbulent 3/2', 'Laminar'};

figure;
hold on
for casenum=cases
    issm_out = load(sprintf('../00_synth_forcing/RUN/output_%03d.mat', casenum));
    md = issm_out.md;
    md.hydrology.sheet_conductivity(1)
    md.hydrology.channel_conductivity
    md.hydrology.sheet_alpha
    md.hydrology.sheet_beta
    phi = [md.results.TransientSolution.HydraulicPotential];
    N = [md.results.TransientSolution.EffectivePressure];
    phi_bed = md.constants.g*md.materials.rho_freshwater*350;
    pw = phi - phi_bed;
    ff = pw./(N + pw);
    tt = [md.results.TransientSolution.time];
    xband = 30e3;
    node_mask = abs(md.mesh.x-xband)<5e3;
    plot(tt, mean(ff, 1), 'DisplayName', case_names{casenum})
%     plot(tt, mean(ff(node_mask, :), 1), 'DisplayName', case_names{casenum})
%     plot(tt, ff(3000, :), 'DisplayName', case_names{casenum})

end

grid on
xlabel('Years')
ylabel('Mean flotation fraction')
legend('Location', 'northoutside', 'NumColumns', 3)
print('figures/timeseries_mean_flotation_fraction', '-dpng', '-r600')
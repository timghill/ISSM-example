% Plot suite of ISSM-GlaDS simulations
addpath('../synthetic/')
set_paths;

cases = [1, 2, 3, 4, 5];

case_names = {'Turbulent 5/4', 'Turbulent 3/2', 'Laminar',...
    'Transition 5/4', 'Transition 3/2'};

figure;
hold on
for casenum=cases
    issm_out = load(sprintf('../synthetic/RUN/output_%03d.mat', casenum));
    md = issm_out.md;
    tt = [md.results.TransientSolution.time];
    vx = [md.results.TransientSolution.HydrologyWaterVx];
    vy = [md.results.TransientSolution.HydrologyWaterVy];
    h = [md.results.TransientSolution.HydrologySheetThickness];
    q = h.*sqrt(vx.^2 + vy.^2)/md.constants.yts;
    nu = md.materials.mu_water./md.materials.rho_freshwater;
    Re = q/nu;
%     plot(tt, max(Re, [], 1), 'DisplayName', case_names{casenum})
    plot(tt, quantile(Re, 0.95), 'DisplayName', case_names{casenum})

end

grid on
xlabel('Years')
ylabel('95^{th}-percentile Re')
legend('Location', 'northoutside', 'NumColumns', 3)
print('figures/timeseries_Re', '-dpng', '-r600')
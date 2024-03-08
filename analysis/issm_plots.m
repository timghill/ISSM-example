% Plot suite of ISSM-GlaDS simulations
addpath('../synthetic/')
set_paths;

cases = [1, 2, 3, 4, 5];

case_names = {'Turbulent 5/4', 'Turbulent 3/2', 'Laminar',...
    'Transition 5/4', 'Transition 3/2'};

for casenum=cases
    issm_out = load(sprintf('../synthetic/RUN/output_%03d.mat', casenum));
    md = issm_out.md;
    S = md.results.TransientSolution(38).ChannelArea;
    max(S)
    figure;
    cmap = cmocean('matter');
    plotchannels(md, S, 'min', 0.1, 'max', 50, 'colormap', cmap)
    title(case_names{casenum});
    axis image
    xlim([0, 100e3])
    ylim([0, 25e3])
    print(sprintf('figures/channels_map_%d', casenum), '-dpng', '-r600')

end

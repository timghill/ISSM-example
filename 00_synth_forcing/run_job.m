function run_job(k_c, k_s, alpha_s, beta_s, omega, id)
% run_job(k_c, k_s, alpha_s, beta_s, omega, id)
% Execute steady and seasonal ISSM-GlaDS simulations

% Start model instance
addpath('../');
set_paths;
md = model;

% Load a GlaDS matlab mesh and convert to ISSM mesh
dmeshfile = '../data/mesh/mesh.mat';
dmeshes = load(dmeshfile);
dmesh = dmeshes.meshes{4};
md.mesh = mesh2d();
md.mesh.x = dmesh.tri.nodes(:, 1);
md.mesh.y = dmesh.tri.nodes(:, 2);
md.mesh.elements = dmesh.tri.connect;
md = meshconvert(md, md.mesh.elements, md.mesh.x, md.mesh.y);

disp('Parameterize')
md = setmask(md, '', '');
md = parameterize(md, '../defaults.par');

disp('Hydrology')

% Turbulent model conductivity scaling
if alpha_s<3 && omega==0
    % Compute potential gradient for turbulent conductivity scaling
    p_w_min = 40*910*9.81;
    p_w_max = 1520*910*9.81;
    gradphi = (p_w_max - p_w_min)/100e3;
    omega = 1/2000;
    nu = 1.793e-6;
    h3 = nu/(omega)/k_s/gradphi;
    k_s = k_s * h3^(1 - alpha_s/3) * gradphi^(2 - 3/2);
end

% HYDROLOGY
% Constant parameters
l_bed = 10;
h_bed = l_bed/20;
e_v = 1e-4;
A = 2.4e-24;
md.hydrology = hydrologyglads();
md.hydrology.sheet_conductivity = k_s*ones(md.mesh.numberofvertices, 1);
md.hydrology.sheet_alpha = alpha_s;
md.hydrology.sheet_beta = beta_s;
md.hydrology.cavity_spacing = l_bed;
md.hydrology.bump_height = h_bed*ones(md.mesh.numberofvertices, 1);
md.hydrology.channel_sheet_width = l_bed;
md.hydrology.omega = omega;
md.hydrology.englacial_void_ratio = e_v;
% md.hydrology.rheology_B_base = A^(-1/3)*ones(md.mesh.numberofvertices,1);
% if md.hydrology.omega>0
%     md.hydrology.istransition=1;
% else
%     md.hydrology.istransition=0;
% end

md.hydrology.ischannels = 1;
% md.hydrology.channel_conductivity = k_c*ones(md.mesh.numberofvertices, 1);
md.hydrology.channel_conductivity = k_c;
md.hydrology.channel_alpha = 5./4.;
md.hydrology.channel_beta = 3./2.;

md.hydrology.requested_outputs = {'default', 'HydrologyWaterVx', 'HydrologyWaterVy'};

% Initial conditions
md.initialization.watercolumn = 0.2*md.hydrology.bump_height.*ones(md.mesh.numberofvertices, 1);
md.initialization.channelarea = 0*ones(md.mesh.numberofedges, 1);
md.initialization.vel = 30*ones(md.mesh.numberofvertices, 1);
md.initialization.vx = -30*ones(md.mesh.numberofvertices, 1);
md.initialization.vy = 0*ones(md.mesh.numberofvertices, 1);

% Set initial water pressure equal to ice overburden
phi_bed = md.constants.g*md.materials.rho_freshwater*md.geometry.base;
p_ice = md.constants.g*md.materials.rho_ice*md.geometry.thickness;
md.initialization.hydraulic_potential = phi_bed + p_ice;

% Boundary conditions: Dirichlet (atmosphere) at terminus, Neumann (zero-flux) elsewhere
md.hydrology.spcphi = NaN(md.mesh.numberofvertices, 1);
pos = find(md.mesh.vertexonboundary & md.mesh.x==min(md.mesh.x));
md.hydrology.spcphi(pos) = phi_bed(pos);

md.hydrology.neumannflux = zeros(md.mesh.numberofelements, 1);

% Forcing
md.hydrology.melt_flag = 1;
md.basalforcings.groundedice_melting_rate = 0.05*ones(md.mesh.numberofvertices, 1);
md.basalforcings.geothermalflux = 0;

% Moulin inputs
% Set 50 random moulin positions
rng(20240220)
moulin_indices = randi(md.mesh.numberofvertices, 1, 50);

% Each moulin has seasonal inputs, max 10 m3/s
tt_melt = 0:(5/365):1;
md.hydrology.moulin_input = zeros(md.mesh.numberofvertices+1, length(tt_melt));
moulin_input = 5*max(0, -cos(2*pi*tt_melt));
md.hydrology.moulin_input(moulin_indices, :) = repmat(moulin_input, 50, 1);
md.hydrology.moulin_input(end, :) = tt_melt;

md.hydrology.moulin_input = zeros(md.mesh.numberofvertices, 1);

% Solver options
md.transient = deactivateall(md.transient);
md.transient.ishydrology = 1;

md.cluster = generic('np', 1);

% Timestepping
hour = 3600;
day = 86400;
dt_hours = 24;
out_freq = (24*5/dt_hours); % Output every 5 days
md.timestepping.time_step = dt_hours*hour/md.constants.yts;
md.settings.output_frequency = out_freq;
md.timestepping.cycle_forcing = 1;
md.timestepping.final_time = 1;

% Tolerances
md.stressbalance.restol = 1e-3;
md.stressbalance.reltol = nan;
md.stressbalance.abstol = nan;
md.stressbalance.maxiter = 100;

% Final options
md.verbose.solution = true;
md.miscellaneous.name = sprintf('Case_%d', id);

disp('solving')
md=solve(md,'Transient');

if ~isfolder('RUN/')
    mkdir('RUN/')
end
fname = sprintf('RUN/output_%03d.mat', id);
save(fname, 'md');


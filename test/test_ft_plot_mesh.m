function test_ft_plot_mesh

% MEM 1500mb
% WALLTIME 00:10:00

% TEST test_ft_plot_mesh 
% TEST ft_plot_mesh ft_datatype_segmentation ft_prepare_mesh

% initial version by Lilla Magyari 2013

%% test ft_plot_mesh with 'surfaceonly' option
%% create an example segmentation 
example.dim = [91 104 111];   % slightly different numbers
example.transform = eye(4);   
example.coordsys = 'ctf';
example.unit = 'mm';
example.seg = zeros(example.dim);

% adjusting transformation matrix: center of the head-coordinates [0 0 0] should
% be the center of volume
% center of volume in voxel coordinates     
x = round(example.dim(1)/2);
y = round(example.dim(2)/2);
z = round(example.dim(3)/2);
x = round(x);
y = round(y);
z = round(z);                 
origin = [x y z];
example.transform(1:4,4)   = [-origin(:); 1];  % head-coordinate [0 0 0] is in the center of 
                                                % the volume (x y z in voxel-coordinates)
% compute position for each voxel in voxelspace and in headspace
[X, Y, Z] = ndgrid(1:example.dim(1), 1:example.dim(2), 1:example.dim(3));
voxelpos = [X(:) Y(:) Z(:)];
headpos = ft_warp_apply(example.transform, voxelpos);

% create 3 spheres
radius1 = 40;
radius2 = 30;
radius3 = 20;

for i=1:size(headpos,1)
    % from small to large
    if norm(headpos(i,:))<radius3
        example.seg(i) = 3;
    elseif norm(headpos(i,:))<radius2
        example.seg(i) = 2;
    elseif norm(headpos(i,:))<radius1
        example.seg(i) = 1;
    end
end
% convert it to probabilistic
seg=ft_datatype_segmentation(example,'segmentationstyle','probabilistic');

%% create mesh
cfg=[];
cfg.method = 'hexahedral';
mesh=ft_prepare_mesh(cfg,seg);

%% plot mesh
ft_plot_mesh(mesh,'surfaceonly','yes');

%% ft_plot_mesh with empty points should return without error (e.g. in ft_prepare_localspheres)
mesh.pnt=[];
ft_plot_mesh(mesh,'surfaceonly','yes');

%% ft_plot_mesh without a pnt field should return an error
mesh = rmfield(mesh, 'pnt')
try
  ft_plot_mesh(mesh, 'surfaceonly','yes')
  success = true;
catch
  success=false;
end
if success, error('01');end


%% while working on bug 2376 I noticed that there was again an error in ft_plot_mesh with color handling
[pnt, tri] = icosahedron162;
bnd.pnt = pnt;
bnd.tri = tri;

% these should all be self explanatory
figure; ft_plot_mesh(bnd, 'vertexcolor',  'r')
figure; ft_plot_mesh(bnd, 'facecolor',    'r')
figure; ft_plot_mesh(bnd, 'vertexcolor',  rand(162,3))
figure; ft_plot_mesh(bnd, 'facecolor',    rand(320,3))
figure; ft_plot_mesh(bnd, 'vertexcolor',  rand(162,1))
figure; ft_plot_mesh(bnd, 'facecolor',    rand(320,1))
figure; ft_plot_mesh(bnd, 'vertexcolor',  rand(1,3))
figure; ft_plot_mesh(bnd, 'facecolor',    rand(1,3))
figure; ft_plot_mesh(bnd, 'facecolor', 'r', 'vertexcolor', rand(162,1))                         % vertexcolor should prevail as potential distribution
figure; ft_plot_mesh(bnd, 'facecolor', 'r', 'vertexcolor', rand(162,3))                         % vertexcolor should prevail as potential distribution
figure; ft_plot_mesh(bnd, 'facecolor', 'r', 'vertexcolor', 'g')                                 % vertexcolor should NOT prevail, i.e. green dots on a red sphere
figure; ft_plot_mesh(bnd, 'facecolor', 'r'); ft_plot_mesh(bnd.pnt, 'vertexcolor', rand(162,3)); % polkadots on a red sphere




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created: 08-Apr-2014 19:50:46
% Computer:  GLNX86
% Matlab:  7.9
% Author:  NK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S06_init_output_maps
	%% init
	DD=initialise('');
	%%
	[MAP]=MakeMaps(DD);
	%%
	DD.threads.num=init_threads(DD.threads.num);
	%% find respective index for all grid points of input map
	MAP.idx=main(DD,MAP);
	%% save MAP
	save([DD.path.root,'protoMaps.mat'],'-struct','MAP'	)
	%% update infofile
	save_info(DD)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx=main(DD,MAP)
	if DD.debugmode
		idx=spmd_body(DD,MAP);
	else
		idx=mainSpmd(DD,MAP);
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx=mainSpmd(DD,MAP)
	spmd(DD.threads.num)
		idx=spmd_body(DD,MAP);
		%% merge composite
		idxx=gop(@vertcat,idx,1);
	end
	numel(idx);
	idx=sum(idxx{1});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx=spmd_body(DD,out)
	%% get input example lon/lat
	in.lon=(extractdeepfield(read_fields(DD,1,'cuts'),'grids.lon'));
	in.lat=(extractdeepfield(read_fields(DD,1,'cuts'),'grids.lat'));
	%% correct if fullglobe
	if strcmp(DD.map.window.type,'globe')
		xreal=DD.map.window.fullsize(2);
		in.lon=reshape(in.lon,DD.map.window.size.Y,[]);
		in.lat=reshape(in.lat,DD.map.window.size.Y,[]);
		in.lon=in.lon(:,1:xreal);
		in.lat=in.lat(:,1:xreal);
		in.lon=in.lon(:);
		in.lat=in.lat(:);
	end
	%% get codisp'ed indeces
	lims=thread_distro(DD.threads.num,numel(in.lon));
	JJ=lims(labindex,1):lims(labindex,2);
	%%
	idx=zeros(1,DD.map.window.size.X*DD.map.window.size.Y);
	%% get Indices For Out Maps
	idx=getIndicesForOutMaps(in,out,JJ,idx);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MAP]=MakeMaps(DD)
	%% init output map dim
	xvec=linspace(DD.map.out.west,DD.map.out.east,DD.map.out.X);
	yvec=linspace(DD.map.out.south,DD.map.out.north,DD.map.out.Y);
	[MAP.lon,MAP.lat]=meshgrid(xvec,yvec);
	MAP.proto.nan=nan(size(MAP.lon));
	MAP.proto.zeros=zeros(size(MAP.lon));
	MAP.dim.y=numel(yvec);
	MAP.dim.x=numel(xvec);
	MAP.dim.numel= MAP.dim.y * MAP.dim.x;
	MAP.inc.x=(DD.map.out.east-DD.map.out.west)/(DD.map.out.X-1);
	MAP.inc.y=(DD.map.out.north-DD.map.out.south)/(DD.map.out.Y-1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
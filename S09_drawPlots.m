%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created: 19-Apr-2014 17:39:11
% Computer:  GLNX86
% Matlab:  7.9
% Author:  NK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S09_drawPlots
    DD=initialise;
    %%	set ticks here!
    %     ticks.rez=200;
    ticks.rez=get(0,'ScreenPixelsPerInch');
    %           ticks.rez=42;
    ticks.width=297/25.4*ticks.rez*5;
    ticks.height=ticks.width * DD.map.out.Y/DD.map.out.X;
    %         ticks.height=ticks.width/sqrt(2); % Din a4
    ticks.y= 0;
    ticks.x= 0;
    ticks.age=[1,3*365,10];
    %     ticks.isoper=[DD.thresh.shape.iq,1,10];
    ticks.isoper=[.6,1,10];
    ticks.radius=[20,150,9];
    ticks.radiusToRo=[0.2,5,11];
    ticks.amp=[1,20,7];
    %ticks.visits=[0,max([maps.AntiCycs.visitsSingleEddy(:); maps.Cycs.visitsSingleEddy(:)]),5];
    ticks.visits=[1,20,11];
    ticks.visitsunique=[1,3,3];
    ticks.dist=[-1500;1000;21];
    %ticks.dist=[-100;50;16];
    ticks.disttot=[1;2000;10];
    ticks.vel=[-30;20;6];
    ticks.axis=[DD.map.out.west DD.map.out.east DD.map.out.south DD.map.out.north];
    ticks.lat=[ticks.axis(3:4),5];
    ticks.minMax=cell2mat(extractfield( load([DD.path.analyzed.name, 'vecs.mat']), 'minMax'));
    
    %% main
    overmain(ticks,DD)
    %%
	 conclude(DD);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function animas(DD)
	file1=[DD.path.eddies.name DD.path.eddies.files(1).name];
	grid=load(cell2mat(extractdeepfield(load(file1),'filename.cut')));
	d.LON=grid.grids.lon;
	d.LAT=grid.grids.lat;
	d.lon=downsize(d.LON,DD.map.out.X,DD.map.out.Y);
	d.lat=downsize(d.LAT,DD.map.out.X,DD.map.out.Y);
	d.climssh.min=nanmin(grid.grids.ssh(:));
	d.climssh.max=nanmax(grid.grids.ssh(:));
	d.p=[DD.path.plots 'mpngs/'];
	mkdirp(d.p);
	for ee=1:numel(DD.path.eddies.files)
	d.file=[DD.path.eddies.name DD.path.eddies.files(ee).name];
		savepng4mov(d,ee,DD.map.out)
	end
end

function savepng4mov(d,ee,map)	
	ed=load(d.file);
	coor=[ed.anticyclones.coordinates ed.cyclones.coordinates];
	grid=load(cell2mat(extractdeepfield(load(d.file),'filename.cut')));
	ssh=downsize(grid.grids.ssh,map.X,map.Y);
	pcolor(d.lon,d.lat,ssh);
	caxis([d.climssh.min d.climssh.max]);
	hold on
	for cc=1:numel(coor)
		linx=drop_2d_to_1d(coor(cc).int.y,coor(cc).int.x,size(d.LAT,1))
	lo=d.LON(linx)
	la=d.LAT(linx)
	plot(lo,la)
	end
	
	saveas(gcf,[p sprintf('%06d.png',ee)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mainDB(DD,IN,ticks)
	disp('entering debug mode')
	ticks.rez=42;
	
	animas(DD);
	
	%      for sense=DD.FieldKeys.senses'; sen=sense{1};
%         TPa(DD,ticks,IN.tracks,sen);
% %         TPb(DD,ticks,IN.tracks,sen);
% %         TPc(DD,ticks,IN.tracks,sen);
% %         TPd(DD,ticks,IN.tracks,sen);
% %         TPe(DD,ticks,IN.tracks,sen);
% %         TPf(DD,ticks,IN.tracks,sen);
%      end
% %     velZonmeans(DD,IN,ticks)
%     scaleZonmeans(DD,IN,ticks)
    % %
%     histstuff(IN.vecs,DD,ticks)
%     mapstuff(IN.maps,IN.vecs,DD,ticks,IN.lo,IN.la)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function job=main(DD,IN,ticks)
    job.zonmeans=taskfForZonMeans(DD,IN,ticks);
    %%
    job.maphist= taskfForMapAndHist(DD,IN,ticks);
    %%
    job.tracks=trackPlots(DD,ticks,IN.tracks);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function job=taskfForZonMeans(DD,IN,ticks)
    job(1)= batch(@velZonmeans, 0, {DD,IN,ticks});
    job(2)=  batch(@scaleZonmeans, 0, {DD,IN,ticks});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function velZonmeans(DD,IN,ticks)
    plot(IN.la(:,1),IN.maps.zonMean.Rossby.small.phaseSpeed	); 	hold on
    acv=squeeze(nanmean(IN.maps.AntiCycs.vel.zonal.mean,2));
    cv=squeeze(nanmean(IN.maps.Cycs.vel.zonal.mean,2));
    plot(IN.la(:,1),acv	,'r')
    plot(IN.la(:,1),cv,'black')
%     set(gca,'xtick',ticks.x	)
%     set(gca,'ytick',ticks.x	)
    axis([DD.map.out.south DD.map.out.north min([min(acv) min(cv)]) max([max(acv) max(cv)]) ])
    legend('Rossby-wave phase-speed','anti-cyclones net zonal velocity','cyclones net zonal velocity')
    ylabel('[cm/s]')
    xlabel('[latitude]')
    title(['velocity - zonal means [cm/s]'])
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['S-velZonmean'],DD.debugmode);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scaleZonmeans(DD,IN,ticks)
    plot(IN.la(:,1),2*IN.maps.zonMean.Rossby.small.radius); 	hold on
    plot(IN.la(:,1),IN.maps.zonMean.AntiCycs.radius.mean.mean,'r')
    plot(IN.la(:,1),IN.maps.zonMean.Cycs.radius.mean.mean,'black')
    set(gca,'xtick',ticks.x	)
    set(gca,'ytick',ticks.y	)
    legend('2 x Rossby Radius','anti-cyclones radius','cyclones radius')
    ylabel('[m]')
    xlabel('[latitude]')
    title(['scale - zonal means'])
    maxr=nanmax(nanmax([IN.maps.zonMean.AntiCycs.radius.mean.mean(:) IN.maps.zonMean.Cycs.radius.mean.mean(:)]));
    axis([min(IN.la(:,1)) max(IN.la(:,1)) 0 maxr])
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['S-scaleZonmean'],DD.debugmode);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  job=taskfForMapAndHist(DD,IN,ticks)
    job(1)=batch(@histstuff, 0, {IN.vecs,DD,ticks});
    job(2)= batch(@mapstuff, 0, {IN.maps,IN.vecs,DD,ticks,IN.lo,IN.la});
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUT]=inits(DD)
    disp(['loading maps'])
    OUT.maps=load([DD.path.analyzed.name, 'maps.mat']);
    OUT.la=OUT.maps.Cycs.lat;
    OUT.lo=OUT.maps.Cycs.lon;
    %% collect tracks
    OUT.tracksfile=[DD.path.analyzed.name , 'tracks.mat' ];
    root=DD.path.analyzedTracks.AC.name;
    OUT.ACs={DD.path.analyzedTracks.AC.files.name};
    Tac=disp_progress('init','collecting all ACs');
    for ff=1:numel(OUT.ACs)
        Tac=disp_progress('calc',Tac,numel(OUT.ACs),100);
        OUT.tracks.AntiCycs(ff)={[root OUT.ACs{ff}]};
    end
    %%
    root=DD.path.analyzedTracks.C.name;
    OUT.Cs={DD.path.analyzedTracks.C.files.name};
    Tc=disp_progress('init','collecting all Cs');
    for ff=1:numel(OUT.Cs)
        Tc=disp_progress('calc',Tc,numel(OUT.Cs),100);
        OUT.tracks.Cycs(ff)={[root OUT.Cs{ff}]};
    end
    %% get vectors
    disp(['loading vectors'])
    OUT.vecs=load([DD.path.analyzed.name, 'vecs.mat']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function histstuff(vecs,DD,ticks)
    senses={'Cycs','AntiCycs'};
    for sense=senses;sen=sense{1};
        %%
        if isempty(vecs.(sen).lat), warning(['warning, no ' sen ' found!']);return;end
        lamin=round(nanmin(vecs.(sen).lat));
        lamax=round(nanmax(vecs.(sen).lat));
        lainc=5;
        range.(sen).lat= round(linspace(lamin,lamax,(lamax-lamin+1)/lainc));
        %%
        agemin=round(nanmin(vecs.(sen).age));
        agemax=round(nanmax(vecs.(sen).age));
        ageinc=10;
        range.(sen).age= round(linspace(agemin,agemax,(agemax-agemin+1)/ageinc));
        %%
        range.(sen).cum=range.(sen).age;
        %%
        [hc.(sen).lat]=numPerLat(vecs.(sen).lat,DD,ticks,range.(sen).lat,sen);
        %%
        [hc.(sen).age,hc.(sen).cum]=ageCum(vecs.(sen).age,DD,ticks,range.(sen).age,sen);
    end
    
    %%
    ratioBar(hc,'lat', range.Cycs.lat);
    tit='ratio of cyclones to anticyclones as function of latitude';
    title(tit)
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['S-latratio-' sen],DD.debugmode);
    %%
    ratioBar(hc,'age', range.Cycs.age);
    tit='ratio of cyclones to anticyclones as function of age (at death)';
    xlab='age [d] - gray scale indicates total number of eddies available';
    title(tit);
    xlabel(xlab)   ;
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['S-ageratio-' sen],DD.debugmode);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [totnum]=ratioBar(hc,field,xlab)
    %% ratio cyc/acyc per lat
    figure
    %% find max length for ratio vecotr
    len=nanmin([length(hc.Cycs.(field)),length(hc.AntiCycs.(field))]);
    hc.rat.(field)=hc.Cycs.(field)(1:len)./hc.AntiCycs.(field)(1:len);
    hc.rat.(field)(isinf(hc.rat.(field)))=nan;
    hc.rat.(field)((hc.rat.(field)==0))=nan;
    %% total length
    totnum=hc.Cycs.(field)(1:len) + hc.AntiCycs.(field)(1:len);
    %%%%
    logyBar(totnum,hc.rat.(field))
    %%%%
    xt= (1:numel(xlab));
    set(gca,'XTick',xt)
    set(gca,'YTickMode','auto')
    yt= get(gca,'YTick');
    set(gca,'yticklabel',sprintf('%0.1f|',exp(yt)));
    set(gca,'xticklabel',num2str(xlab));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mapstuff(maps,vecs,DD,ticks,lo,la)
    aut=autumn;
    win=winter;
    ho=hot;
    je=jet;
    senses={'Cycs','AntiCycs'};
    for sense=senses;sen=sense{1};
        if isempty(vecs.(sen).lat), warning(['warning, no ' sen ' found!']);continue;end %#ok<*WNTAG>
        %%
        % %         figure
        % %         b.la=vecs.(sen).birth.lat;
        % %         b.lo=vecs.(sen).birth.lon;
        % %         d.la=vecs.(sen).death.lat;
        % %         d.lo=vecs.(sen).death.lon;
        % %         plot(b.lo,b.la,'.r',d.lo,d.la,'.g','markersize',5)
        % %         hold on
        % %         drawcoast
        % %         axis(ticks.axis);
        % %         set(gca,'ytick',ticks.y);
        % %         set(gca,'xtick',ticks.x) ;
        % %         legend('births','deaths')
        % %         title(sen)
        % %         savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['deathsBirths-' sen],DD.debugmode);
        %
        %%
        figure
        maps.(sen).age.logmean=log(maps.(sen).age.mean);
        VV=maps.(sen).age.logmean;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.age(1) ticks.age(2)])
        decorate('age',ticks,DD,sen,'age','d',1,1);
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapAge-' sen],DD.debugmode)
        %%
        % %         figure
        % %         VV=maps.(sen).visits.single;
        % %         VV(VV==0)=nan;
        % %         pcolor(lo,la,log(VV));shading flat
        % % %         caxis([ticks.visits(1) ticks.visits(2)])
        % %         decorate('visitsunique',ticks,DD,sen,'Visits of unique eddy',' ',0,1);
        % %         savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapVisits-' sen],DD.debugmode);
        %         %%
        %
        figure
        VV=maps.(sen).dist.zonal.fromBirth.mean/1000;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.dist(1) ticks.dist(2)])
        cb=decorate('dist',ticks,DD,sen,'Zonal Distance from Birth','km',0,1);
        doublemap(cb,ho(10:end,:),win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapDFB' sen],DD.debugmode);
        %%
        figure
        VV=maps.(sen).dist.zonal.tillDeath.mean/1000;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.dist(1) ticks.dist(2)])
        cb=decorate('dist',ticks,DD,sen,'Zonal Distance till Death','km',0,1);
        doublemap(cb,ho(10:end,:),win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapDTD' sen],DD.debugmode);
        %
        figure
        VV=log(maps.(sen).dist.traj.fromBirth.mean/1000);
        pcolor(lo,la,VV);shading flat
        %         caxis([ticks.disttot(1) ticks.disttot(2)])
        decorate('disttot',ticks,DD,sen,'Total distance travelled since birth','km',1,1);
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapDTFB' sen],DD.debugmode);
        %%
        figure
        VV=log(maps.(sen).dist.traj.tillDeath.mean/1000);
        pcolor(lo,la,VV);shading flat
        %         caxis([ticks.disttot(1) ticks.disttot(2)])
        decorate('disttot',ticks,DD,sen,'Total distance to be travelled till death','km',1,1);
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapDTTD' sen],DD.debugmode);
        %         %%
        
        
        %
        figure
        VV=maps.(sen).vel.zonal.mean*100;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.vel(1) ticks.vel(2)])
        cb=decorate('vel',ticks,DD,sen,'Zonal velocity','cm/s',0,1);
        doublemap(cb,aut,win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapVel' sen],DD.debugmode);
        %%
        figure
        VV=maps.(sen).vel.net.mean*100;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.vel(1) ticks.vel(2)])
        cb=decorate('vel',ticks,DD,sen,...
            ['(Zonal velocity -Mean Current @('...
            ,num2str(DD.parameters.meanU)	,...
            'm))'],'cm/s',0,1);
        doublemap(cb,aut,win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapVelNet' sen],DD.debugmode);
        %%
        figure
        VV=maps.(sen).radius.mean.mean/1000;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.radius(1) ticks.radius(2)])
        decorate('radius',ticks,DD,sen,'Radius','km',0,1);
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapRad' sen],DD.debugmode);
        %%
        figure
        VV=log(maps.(sen).radius.toRo);
        pcolor(lo,la,VV);shading flat
        caxis([ticks.radiusToRo(1) ticks.radiusToRo(2)])
        cb=decorate('radiusToRo',ticks,DD,sen,'Radius/(L_R)',' ',1,10,1,1);
        doublemap(cb,aut,win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapRadToRo' sen],DD.debugmode);
        %
        %%
        figure
        VV=(maps.(sen).vel.zonal.mean-maps.Rossby.small.phaseSpeed)*100;
        pcolor(lo,la,VV);shading flat
        caxis([ticks.vel(1) ticks.vel(2)])
        cb=decorate('vel',ticks,DD,sen,['[Zonal U - c_1)]'],'cm/s',0,1);
        doublemap(cb,aut,win,[.9 1 .9])
        savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['MapUcDiff' sen],DD.debugmode);
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function job=trackPlots(DD,ticks,tracks)
    senses=fieldnames(tracks);
    for sense=senses'; sen=sense{1};
        job(1)= batch(@TPa, 0, {DD,ticks,tracks,sen});
        job(2)= batch(@TPb, 0, {DD,ticks,tracks,sen});
        job(3)= batch(@TPc, 0, {DD,ticks,tracks,sen});
        job(4)= batch(@TPd, 0, {DD,ticks,tracks,sen});
        job(5)= batch(@TPe, 0, {DD,ticks,tracks,sen});
        job(6)=  batch(@TPf, 0, {DD,ticks,tracks,sen});
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPa(DD,ticks,tracks,sen)
    drawColorLinem(ticks,tracks.(sen),'lat','isoper') ;
    title([sen '- deflections'])
    axis([-2500 1500 -500 500])
    set(gca,'ytick',[-500 0 500])
    set(gca,'xtick',[-2500 0 1500])
    colorbar
    xlabel('IQ repr. by thickness; latitude repr. by color')
    axis equal
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['defletcs' sen],DD.debugmode,'dpng',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPb(DD,ticks,tracks,sen)
    field='age';
    drawColorLine(ticks,tracks.(sen),field,ticks.age(2),ticks.age(1),1,0) ;
    decorate(field,ticks,DD,sen,field,'d',1,1);
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['age' sen],DD.debugmode,'dpng',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPc(DD,ticks,tracks,sen)
    drawColorLine(ticks,tracks.(sen),'isoper',ticks.isoper(2),ticks.isoper(1),0,0) ;
    decorate('isoper',ticks,DD,sen,'IQ',' ',0,100)
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['IQ' sen],DD.debugmode,'dpng',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPd(DD,ticks,tracks,sen)
    drawColorLine(ticks,tracks.(sen),'radiusmean',ticks.radius(2)*1000,ticks.radius(1)*1000,0,0) ;
    decorate('radius',ticks,DD,sen,'Radius','km',0,1)
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['radius' sen],DD.debugmode,'dpng',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPe(DD,ticks,tracks,sen)
    drawColorLine(ticks,tracks.(sen),'peakampto_ellipse',ticks.amp(2)/100,ticks.amp(1)/100,0,0) ;
    decorate('amp',ticks,DD,sen,'Amp to ellipse','cm',1,1)
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['TrackPeakampto_ellipse' sen],DD.debugmode,'dpng',1);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TPf(DD,ticks,tracks,sen)
    drawColorLine(ticks,tracks.(sen),'peakampto_contour',ticks.amp(2)/100,ticks.amp(1)/100,0,0) ;
    decorate('amp',ticks,DD,sen,'Amp to contour','cm',1,1)
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['TrackPeakampto_contour' sen],DD.debugmode)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logyBar(totnum,y)
    len=numel(y);
    y=log(y);
    x=1:len;
    y(totnum==0)=[];
    x(totnum==0)=[];
    totnum(totnum==0)=[];
    
    colors = flipud(bone(max(totnum)));
    cols=colors(totnum,:);
    for ii = 1:numel(x)
        a=bar(x(ii), y(ii));
        hold on
        set(a,'facecolor', cols(ii,:));
    end
    cm=flipud(bone);
    colormap(cm)
    cb=colorbar;
    zticks=linspace(2,max(totnum),5)';
    zticklabel=num2str(round((zticks)));
    caxis([zticks(1) zticks(end)])
    set(cb,'ytick',zticks);
    set(cb,'yticklabel',zticklabel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lat]=numPerLat(latin,DD,ticks,range,sen)
    figure
    lat=histc(latin,range);
    semilogy(range,lat);
    tit=['number of ',sen,' per 1deg lat'];
    title([tit]);
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['latNum-' sen],DD.debugmode,'dpng',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [age,cum]=ageCum(agein,DD,ticks,range,sen)
    figure
    agein(agein<DD.thresh.life)=[];
    age=histc(agein,range);
    semilogy(range,age)
    tit=['number of ',sen,' per age'];
    unit='d';
    title([tit,' [',unit,']'])
    cum=fliplr(cumsum(fliplr(age)));
    semilogy(range,cum)
    tit=['upper tail cumulative of ',sen,' per age'];
    title([tit,' [',unit,']'])
    savefig(DD.path.plots,ticks.rez,ticks.width,ticks.height,['ageUpCum-' sen ],DD.debugmode);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doublemap(cb,cm1,cm2,centercol)
    %% get colorbardata
    zlim=(get(cb,'ylim'));
    ztick=(get(cb,'ytick'));
    zticklabel=(get(cb,'yticklabel'));
    %% resample to fit ticks
    
    if numel(cm1)~=numel(cm2)
        if numel(cm2)>numel(cm1)
            cm1=resample(cm1,size(cm2,1),size(cm1,1));
        else
            cm2=resample(cm2,size(cm1,1),size(cm2,1));
        end
    end
    
    
    
    cm1r=resample(cm1,round(1000*abs(zlim(1))),round(1000*abs(zlim(1)) * abs(zlim(2)/zlim(1))));
    cm2r=resample(cm2,round(1000*zlim(2)),round(1000*zlim(2)));
    CM=[cm1r;flipud(cm2r)];
    %% blend in the middle
    midfilt=linspace(-1,zlim(2)/abs(zlim(1)),length(CM));
    %     gp=repmat(gauspuls(midfilt,1,1,-1/5)',1,3);
    gp=repmat(gauspuls(midfilt,1.5,1.5,-1/5)',1,3);
    centercolvec=repmat(centercol,size(CM,1),1);
    CM=(1-gp).*CM + gp.*centercolvec;
    %% correct for round errors
    CM(CM<0)=0;
    CM(CM>1)=1;
    %% reset to old params
    colormap(CM);
    caxis(zlim);
    set(cb,'ytick',ztick);
    set(cb,'yticklabel',zticklabel);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawcoast
    load coast;
    hold on; plot(long,lat,'LineWidth',0.5);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb=decorate(field,ticks,DD,tit,tit2,unit,logornot,decim,coast,rats)
    if nargin<10
        rats=false;
    end
    if nargin<9
        coast=true;
    end
    
    axis(ticks.axis);
    set(gca,'ytick',ticks.y);
    set(gca,'xtick',ticks.x);
    cb=colorbar;
    if logornot
        zticks=linspace(log(ticks.(field)(1)),log(ticks.(field)(2)),ticks.(field)(3))';
        zticklabel=round(exp(zticks)*decim)/decim;
        if rats
            
            [n,d]=rat(zticklabel);
            nc=(num2cell(n));
            dc=(num2cell(d));
            zticklabel=cellfun(@(a,b) [num2str(a) '/' num2str(b)],nc,dc,'uniformoutput',false);
            
        else
            zticklabel=num2str(zticklabel);
        end
    else
        zticks=linspace(ticks.(field)(1),ticks.(field)(2),ticks.(field)(3))';
        zticklabel=num2str(round(zticks*decim)/decim);
    end
    caxis([zticks(1) zticks(end)])
    set(cb,'ytick',zticks);
    set(cb,'yticklabel',zticklabel);
    title([tit,' - ',tit2,' [',unit,']'])
    xlabel(['Eddies that died younger ',num2str(DD.thresh.life),' days are excluded'])
    if coast
        drawcoast;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxV,cmap]=drawColorLinem(ticks,files,fieldName,fieldName2)
    cmap=jet;% Generate range of color indices that map to cmap
    %% get extremata
    maxIQ=ticks.isoper(2);
    minIQ=ticks.isoper(1);
    minV=ticks.lat(1);
    maxV=ticks.lat(2);
    iqiq=linspace(minIQ,maxIQ,10);
    kk=linspace(minV,maxV,size(cmap,1));
    %      kk=linspace(minIQ,maxIQ,10);
    %     iqiq=linspace(minV,maxV,size(cmap,1));
    
    meaniq=nan(size(files));
    for ee=1:numel(files)
        V=load(files{ee},fieldName2);
        VViq=V.(fieldName2);
        meaniq(ee)=nanmean(VViq);
	 end
	  meaniq(meaniq>1)=1;
    [~,iqorder]=sort(meaniq,'descend');
    
	 maxthick=ticks.rez/300*5;
    minthick=ticks.rez/300*0.1;
    for ee=iqorder(1:50)
        V=load(files{ee},fieldName,fieldName2,'lat','lon');
%         V=load(files{ee});
		  VV=V.(fieldName);
        VViq=V.(fieldName2);
		  VViq(VViq>1)=1;
        if isempty(VV)
            continue
        end
        cm = spline(kk,cmap',VV);       % Find interpolated colorvalue
        cm(cm>1)=1;                     % Sometimes iterpolation gives values that are out of [0,1] range...
        cm(cm<0)=0;
        %% Find interpolated thickness
        iq = spline(iqiq,linspace(minthick,maxthick,10),VViq);
        iq(iq<0)=minthick;
        %% deg2km
        yy=[0 cumsum(deg2km(diff(V.lat)))];
        xx=[0 cumsum(deg2km(diff(V.lon)).*cosd((V.lat(1:end-1)+V.lat(2:end))/2))];
        for ii=1:length(xx)-1
            if  abs(xx(ii+1)-xx(ii))<1000 % avoid 0->360 jumps
                line([xx(ii) xx(ii+1)],[yy(ii) yy(ii+1)],'color',cm(:,ii),'LineWidth',iq(ii));
            end
        end
    end
    caxis([minV maxV])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxV,cmap]=drawColorLine(ticks,files,fieldName,maxV,minV,logornot,zeroshift)
    cmap=jet;% Generate range of color indices that map to cmap
    if logornot
        maxV=log(maxV);
        minV(minV==0)=1;
        minV=log(minV);
    end
    kk=linspace(minV,maxV,size(cmap,1));
    %%
    maxIQ=ticks.isoper(2);
    minIQ=ticks.isoper(1);
    iqiq=linspace(minIQ,maxIQ,10);
    %%
    meaniq=nan(size(files));
    for ee=1:numel(files)
        V=load(files{ee},'isoper');
        VViq=V.isoper;
        meaniq(ee)=nanmean(VViq);
	 end
	 meaniq(meaniq>1)=1;
    [~,iqorder]=sort(meaniq,'descend');
    %%
	  maxthick=ticks.rez/300*5;
    minthick=ticks.rez/300*0.1;
    for ee=iqorder
        V=load(files{ee},fieldName,'isoper','lat','lon');
        VV=V.(fieldName);
        VViq=V.isoper;
		   VViq(VViq>1)=1;
        if isempty(VV)
            continue
        end
        if logornot
            VV(VV==0)=1;
            cm = spline(kk,cmap',log(VV));  % Find interpolated colorvalue
            %             cm = spline(iqiq,cmap',log(VViq));  % Find interpolated colorvalue
        else
            cm = spline(kk,cmap',VV);       % Find interpolated colorvalue
            %             cm = spline(iqiq,cmap',VViq);       % Find interpolated colorvalue
        end
        cm(cm>1)=1;                        % Sometimes iterpolation gives values that are out of [0,1] range...
        cm(cm<0)=0;
        lo=V.lon;
        la=V.lat;
        if zeroshift
            lo=lo-lo(1);
            la=la-la(1);
        end
        %% Find interpolated thickness
        iq = spline(iqiq,linspace(minthick,maxthick,10),VViq);
        %         iq = spline(kk,linspace(0.01,2,10),VV);
        iq(iq<0)=minthick;
        %%
        for ii=1:length(la)-1
            if  abs(lo(ii+1)-lo(ii))<10 % avoid 0->360 jumps
                line([lo(ii) lo(ii+1)],[la(ii) la(ii+1)],'color',cm(:,ii),'LineWidth',iq(ii));
            end
        end
    end
    caxis([minV maxV])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function overmain(ticks,DD)
    [threadData]=inits(DD);
    %%
    if DD.debugmode
        mainDB(DD,threadData,ticks);
    else
        disp('commencing plotting')
        %#ok<*WNOFF>
        %#ok<*WNON>
        warning('off')
        job=main(DD,threadData,ticks);
        warning('on')
        disp('plotting done!')
        %% close pool for printing
        matlabpool close
        for field=fieldnames(job)';ff=field{1};
            while ~all(strcmp({job.(ff)(:).State},'finished'))
                disp('waiting for plots to finish')
                sleep(5)
                disp(job.(ff)(:))
            end
        end
        disp('done!')
        dirname=[DD.path.plots 'jammed/'];
        dirname_cropped=[DD.path.plots 'cropped/'];
        mkdirp(dirname);
        mkdirp(dirname_cropped);
        fnamebase= [datestr(now,'yyyymmdd-HHMM')];
        fnamecompact=[fnamebase '_compact.pdf'];
        fname=[fnamebase '_compact.pdf'];
        disp(['pdfjamming all to ' dirname fname])
        system(['pdfjam --nup 2x2 --a4paper -o ' dirname fnamecompact ' ' DD.path.plots '*pdf']);
        system(['pdfjam --a4paper -o ' dirname fname ' ' DD.path.plots '*pdf']);
        disp(['cropping'])
        system(['pdfcrop  ' dirname fnamecompact]);
        system(['pdfcrop  ' dirname fname]);
        system(['mv ' dirname '*crop*.pdf ' dirname_cropped]);
    end
end
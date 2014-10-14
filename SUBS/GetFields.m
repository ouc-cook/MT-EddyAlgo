function [F,unreadable]=GetFields(file,keys)
    F=struct;
    unreadable.is=false;
    for field=fieldnames(keys)';ff=field{1};
        if isempty(ff),continue;end
        try
            if strcmpi(ff,'lon')
                F.(ff) = CorrectLongitude(squeeze(nc_varget(file,keys.(ff))));                
            else
                F.(ff) = squeeze(nc_varget(file,keys.(ff)));
            end
        catch uc
            unreadable.is=true;
            unreadable.catch=uc;
            disp('skipping');
            disp(uc);
            disp(uc.message);
            disp(uc.getReport);
            return
        end
    end
    if isfield(F,'lon')
        if min(size(F.lon))==1
            F.lon=repmat(standVectorUp(F.lon)',length(F.lat),1);
            F.lat=repmat(standVectorUp(F.lat) ,1,length(F.lon));
        end
    end
end


function [lon]=CorrectLongitude(lon)
    % longitude(-180:180) concept is to be used!  
        lon(lon>180)=lon(lon>180)-360;    
end
function [ ] = plotPointCloud( instance )
    
    ind = find(instance>0);
    % ind = x+(y-1)*size(instance,1)+(z-1)*size(instance,1)*size(instance,2)
    x = mod(mod(ind,size(instance,1)*size(instance,2)),size(instance,1));
    y = floor(mod(ind,size(instance,1)*size(instance,2))/size(instance,1));
    z = floor(ind/size(instance,1)/size(instance,2));
    scatter3(x,y,z,'r');
    ind = find(instance<0);
    x = mod(mod(ind,size(instance,1)*size(instance,2)),size(instance,1));
    y = floor(mod(ind,size(instance,1)*size(instance,2))/size(instance,1));
    z = floor(ind/size(instance,1)/size(instance,2));
    hold on;
    scatter3(x,y,z,'b');
end


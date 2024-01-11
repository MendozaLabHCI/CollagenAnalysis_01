function multiColorLine(AxisHandle,x,y,z,c,cmap)

numPoints = numel(x);

cn = (c-min(c))/(max(c) - min(c));
cn = ceil(cn*size(cmap,1));
cn = max(cn,1);

for k = 1:numPoints-1
    line(AxisHandle,...
         x(k:k+1), y(k:k+1), z(k:k+1),...
         'Color', cmap(cn(k),:),...
         'LineWidth',2.0)
end
    

function [BWfinal] = BuildTubeStructuresFromMidLayer(BW,dp,dz,refZ)
    
    [nR,nC,nZ] = size(BW);
    
    xvec = (0:nC-1)*dp;
    yvec = (0:nR-1)*dp;
    zvec = (0:nZ-1)*dz;
    
    [X,Y,Z] = meshgrid(xvec, yvec, zvec);
    
    x = X(:,:,1);
    y = Y(:,:,1);
    
    % refZ = round(nZ/2); % reference Z plane for  building objects
%--------------------------------------------------------------------------------------------    
    BWfinal = false(size(BW));
% -------------------------------------------------------------------------------------------
    [L, nObj] = bwlabel(BW(:,:,refZ));
    WB = waitbar(0);
    for obj = 1:nObj
            RefObjInd = find(L == obj);
            BWtemp = false(nR,nC);
            % Add reference object to BWfinal ------------------------------------------------------------
            BWtemp(RefObjInd) = true;
            BWfinal(:,:,refZ) = logical(BWfinal(:,:,refZ) + BWtemp);
            % Starting object centroids ----------------------------------------------------------
                xCentroid = mean( x(RefObjInd) );
                yCentroid = mean( y(RefObjInd) );
            
            % first do midpoint to end -------------------------------------------------------------------
                for z = (refZ+1):nZ 
                %for z = (refZ+1):refZ+4
                    BWtemp = false(nR,nC);
                    [ ~, ~, ~, idx, ~, ~] = bwselect( xvec, yvec, BW(:,:,z), xCentroid, yCentroid, 8 );
                    if isempty(idx)
                        break
                    else
                        BWtemp(idx) = true;
                        BWfinal(:,:,z) = logical(BWfinal(:,:,z) + BWtemp);
                        xCentroid = mean( x(idx) );
                        yCentroid = mean( y(idx) );
                    end
                end
            
            % Starting object centroids ----------------------------------------------------------
                xCentroid = mean( x(RefObjInd) );
                yCentroid = mean( y(RefObjInd) );
            
            % Now do start to midpoint -------------------------------------------------------------------
                for z = (refZ-1):-1:1 
                % for z = (refZ-1):-1:refZ-4 
                    BWtemp = false(nR,nC);
                    [ ~, ~, ~, idx, ~, ~] = bwselect( xvec, yvec, BW(:,:,z), xCentroid, yCentroid, 8 );
                    if isempty(idx)
                        break
                    else
                        BWtemp(idx) = true;
                        BWfinal(:,:,z) = logical(BWfinal(:,:,z) + BWtemp);
                        xCentroid = mean( x(idx) );
                        yCentroid = mean( y(idx) );
                    end
                end

               waitbar( obj/nObj, WB, [num2str(obj) ' of ' num2str(nObj)] )
    end
    
    try
        close(WB)
    end
    
    
    
    
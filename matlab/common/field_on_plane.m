function [X, Y, Bz, Bmag] = field_on_plane(paths, currents, xvec, yvec, z0)
%FIELD_ON_PLANE  Sample the B field on a z = const plane.
%
%   [X,Y,Bz,Bmag] = FIELD_ON_PLANE(paths, currents, xvec, yvec, z0)
%   xvec, yvec : 1D coordinate vectors [m]
%   z0         : plane height [m]
%   X, Y       : meshgrid coordinate matrices [m]
%   Bz, Bmag   : normal component and magnitude [T]
%
%   通用库：平面磁场分布采样。

[X, Y] = meshgrid(xvec, yvec);
Pe = [X(:), Y(:), z0*ones(numel(X),1)];
B  = bs_field(Pe, paths, currents);
Bz   = reshape(B(:,3), size(X));
Bmag = reshape(sqrt(sum(B.^2, 2)), size(X));
end

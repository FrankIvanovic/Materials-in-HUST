function [z, B, Bmag] = field_on_axis(paths, currents, zvec, x0, y0)
%FIELD_ON_AXIS  Sample the B field along the vertical line x = x0, y = y0.
%
%   [z,B,Bmag] = FIELD_ON_AXIS(paths, currents, zvec, x0, y0)
%   zvec : 1D height vector [m]
%   B    : N x 3 field components [T];  Bmag : magnitude [T]
%
%   通用库：轴线（穿透深度方向）磁场采样。

N  = numel(zvec);
Pe = [repmat(x0, N, 1), repmat(y0, N, 1), zvec(:)];
B  = bs_field(Pe, paths, currents);
Bmag = sqrt(sum(B.^2, 2));
z = zvec(:);
end

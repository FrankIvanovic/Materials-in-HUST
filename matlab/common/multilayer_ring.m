function [paths, signs] = multilayer_ring(outer, inner, nTurns, z0, dz, nLayer, nResample)
%MULTILAYER_RING  Stacked polygon / closed-curve spiral (see RING_SPIRAL).
%
%   [PATHS,SIGNS] = MULTILAYER_RING(outer,inner,nTurns,z0,dz,nLayer,nResample)
%   Same layer / sign convention as MULTILAYER_SPIRAL. nResample is forwarded
%   to RING_SPIRAL (resample points per turn; omit or 0 for polygons).
%
%   通用库：异形（H/T/跑道等）线圈的多层绕组。

if nargin < 7, nResample = 0; end
paths = cell(1,nLayer);
signs = ones(1,nLayer);
for k = 1:nLayer
    Pk = ring_spiral(outer, inner, nTurns, z0 + (k-1)*dz, nResample);
    if mod(k,2) == 0
        paths{k} = flipud(Pk);
        signs(k) = -1;
    else
        paths{k} = Pk;
    end
end
end

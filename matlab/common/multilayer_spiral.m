function [paths, signs] = multilayer_spiral(c, rIn, rOut, nTurns, nPerTurn, z0, dz, nLayer)
%MULTILAYER_SPIRAL  Stacked spiral pancake wound as one continuous wire.
%
%   [PATHS,SIGNS] = MULTILAYER_SPIRAL(c,rIn,rOut,nTurns,nPerTurn,z0,dz,nLayer)
%   Layer k sits at z = z0 + (k-1)*dz. A continuous serpentine winding keeps
%   the same physical current circulation in every layer: odd layers are
%   stored inner->outer, even layers are stored reversed with current sign
%   -1. Pass CURRENTS = I*SIGNS to BS_FIELD.
%
%   Inter-layer vertical jumpers (length dz) are omitted: a vertical
%   straight segment carries no Bz on the axis below it and contributes
%   negligibly elsewhere.
%
%   通用库：多层平面螺旋绕组（如双层 9 圈圆形线圈、4 层儿童线圈）。

paths = cell(1,nLayer);
signs = ones(1,nLayer);
for k = 1:nLayer
    Pk = spiral_pts(c, rIn, rOut, nTurns, nPerTurn, z0 + (k-1)*dz);
    if mod(k,2) == 0
        paths{k} = flipud(Pk);     % 偶数层反向存储
        signs(k) = -1;             % 同时电流取负 -> 物理环流不变
    else
        paths{k} = Pk;
    end
end
end

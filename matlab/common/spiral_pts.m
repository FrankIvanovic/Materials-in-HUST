function P = spiral_pts(c, rIn, rOut, nTurns, nPerTurn, z)
%SPIRAL_PTS  Archimedean planar spiral (counter-clockwise, r grows with angle).
%
%   P = SPIRAL_PTS(c, rIn, rOut, nTurns, nPerTurn, z)
%   c        : [x y] centre [m]
%   rIn,rOut : start / end radius [m]
%   nTurns   : number of turns, may be fractional (e.g. 7.5)
%   nPerTurn : sample points per turn
%   z        : constant height [m]
%   Returns (round(nTurns*nPerTurn)+1) x 3 polyline [m].
%
%   通用库：阿基米德平面螺旋（俯视逆时针，半径随角度线性增大）。

th = linspace(0, 2*pi*nTurns, round(nTurns*nPerTurn)+1).';
r  = rIn + (rOut - rIn)*th/(2*pi*nTurns);
P  = [c(1) + r.*cos(th), c(2) + r.*sin(th), z*ones(size(th))];
end

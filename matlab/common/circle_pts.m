function P = circle_pts(c, r, n, z)
%CIRCLE_PTS  Closed circular polyline with n segments (n+1 points).
%
%   P = CIRCLE_PTS(c, r, n, z)
%   c : [x y] centre [m];  r : radius [m];  z : height [m]
%
%   通用库：闭合圆周折线。

th = linspace(0, 2*pi, n+1).';
P  = [c(1) + r*cos(th), c(2) + r*sin(th), z*ones(n+1,1)];
end

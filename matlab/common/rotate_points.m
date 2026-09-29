function Q = rotate_points(P, p0, u, angDeg)
%ROTATE_POINTS  Rotate points about the axis {p0 + t*u} (Rodrigues formula).
%
%   Q = ROTATE_POINTS(P, p0, u, angDeg)
%   P      : N x 3 point array
%   p0     : 1 x 3 point on the axis
%   u      : 1 x 3 axis direction (normalised internally)
%   angDeg : rotation angle in degrees (right-hand rule about u)
%
%   通用库：绕任意轴旋转（用于双锥线圈张角、折叠线圈等三维变换）。

u  = u(:).'/norm(u);
Q  = P - p0;
kxu = cross(repmat(u, size(Q,1), 1), Q, 2);
kdu = Q*u.';                       % N x 1
ca  = cosd(angDeg);
sa  = sind(angDeg);
Q   = p0 + Q*ca + kxu*sa + (kdu*u)*(1 - ca);
end

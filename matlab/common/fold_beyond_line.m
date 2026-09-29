function Q = fold_beyond_line(P, p0, u, v, angDeg)
%FOLD_BEYOND_LINE  Rotate the part of a planar winding beyond a fold line.
%
%   Q = FOLD_BEYOND_LINE(P, p0, u, v, angDeg)
%   The fold line lies in the winding plane, passes through p0 with
%   in-plane direction u. Points on the positive side of the in-plane
%   direction v (perpendicular to u) are rotated about the fold line by
%   angDeg (positive angle lifts the folded part towards +z).
%
%   通用库：折叠线圈 / 弯折贴头线圈（折叠 8 字、折叠圆形、137° 弯折阵列）。

u  = u(:).'/norm(u);
v  = v(:).'/norm(v);
rel = P - p0;
a = rel*u.';
b = rel*v.';
c = rel(:,3);
idx = b > 0;
ca = cosd(angDeg);
sa = sind(angDeg);
b2 = b;  c2 = c;
b2(idx) = b(idx)*ca - c(idx)*sa;
c2(idx) = b(idx)*sa + c(idx)*ca;
Q = p0 + a*u + b2*v + c2*[0 0 1];
end

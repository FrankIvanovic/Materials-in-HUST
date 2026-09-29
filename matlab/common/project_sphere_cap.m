function Q = project_sphere_cap(P, R, rhoMax)
%PROJECT_SPHERE_CAP  Radially project planar windings onto a spherical cap.
%
%   Q = PROJECT_SPHERE_CAP(P, R, rhoMax)
%   The sphere of radius R [m] is shifted so that windings at rho = rhoMax
%   lie at z = 0 (coil rim on the scalp) and the cap centre is lifted by
%   h0 = R - sqrt(R^2 - rhoMax^2). Only z is modified (radial projection).
%
%   通用库：把平面线圈沿径向投影到头球冠（H1 系列头戴线圈建模）。

rho = hypot(P(:,1), P(:,2));
h0  = R - sqrt(R^2 - rhoMax^2);
z   = sqrt(max(R^2 - min(rho, 0.999*R).^2, 0)) - (R - h0);
Q   = P;
Q(:,3) = z;
end

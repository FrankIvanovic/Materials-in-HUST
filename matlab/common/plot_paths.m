function plot_paths(paths)
%PLOT_PATHS  3-D view of conductor paths (drawn in mm).
%
%   PLOT_PATHS(paths)  -- paths is a cell array of N x 3 polylines [m].
%
%   通用库：线圈三维走线图。

figure('Name','Coil geometry');
hold on;
for k = 1:numel(paths)
    P = paths{k}*1e3;
    plot3(P(:,1), P(:,2), P(:,3), 'LineWidth', 1.2, 'Color', [0.15 0.35 0.8]);
end
axis equal; grid on; box on;
xlabel('x / mm'); ylabel('y / mm'); zlabel('z / mm');
view(135, 25);
end

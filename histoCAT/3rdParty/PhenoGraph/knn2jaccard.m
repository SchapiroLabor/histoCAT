function G = knn2jaccard( IDX )
% IN:
%   IDX is a n x k matrix
%   row i contains the indices of i's k nearest neighbors (in descending order of similarity)
%   e.g. IDX = knnsearch(data,data,'k',k+1); IDX(:,1)=[];
% OUT:
%   G is the lower triangle (excluding diagonal) of the resulting adjacency matrix
[n,k] = size(IDX);
I = nan(1, k*n );
J = I;
S = I;
row = 1;
pctdone = 10;
ticker = round(n/10);
t = tic;
for ii = 1:n
    
    pt_neighbs = IDX(ii,:);
    n_of_n = IDX(pt_neighbs,:);
    shared_neighbors = sum(ismember(n_of_n, pt_neighbs),2);
    % intersection and union sum to k
    weights = shared_neighbors ./ (2*k-shared_neighbors); % Jaccard coefficient
    idx = row:row+k-1;
    I(idx) = repmat(ii,1,k);
    J(idx) = pt_neighbs;
    S(idx) = weights;
    row = row+k;
    if ~mod(ii,ticker) && ii>1
        fprintf(1,'%i percent complete: %.2f s\n',...
            pctdone, toc(t) );
        pctdone = pctdone + 10;
    end
    
end
fprintf(1,'Finished Jaccard graph in %.2f s\n', toc(t));
% Produce sparse lower triangle of symmetrized graph
G = sparse(I,J,S,n,n);
init_edge_num = nnz(G);
clear I J S IDX
u = triu(G,1);
v = tril(G,-1);
% G = v .* u'; % product zeros-out non-reciprocal edges
G = v + u';
fprintf(1,'Edge number pruned from %g to %g\n', init_edge_num, nnz(G));
fprintf(1, 'Sparsity: %g\n',nnz(G)/numel(G));

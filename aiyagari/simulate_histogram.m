function dist = simulate_histogram(kpPolicy,w,r,params)
MAXITER_VFI=params.MAXITER_VFI; NUM_THREADS=params.NUM_THREADS; PRINT_FREQ=params.PRINT_FREQ; T=params.T; TOL_EQ=params.TOL_EQ; TOL_OPT=params.TOL_OPT; TOL_VFI=params.TOL_VFI; alpha=params.alpha; beta=params.beta; delta=params.delta; eGrid=params.eGrid; ePts=params.ePts; eRange=params.eRange; eRho=params.eRho; eSigma=params.eSigma; eTrans=params.eTrans; gamma=params.gamma; kGrid=params.kGrid; kMax=params.kMax; kMin=params.kMin; kPts=params.kPts; kShift=params.kShift; numAgents=params.numAgents;TOL_DIST=params.TOL_DIST;

% Initialize histogram as uniform distribution
dist = zeros(ePts,kPts);
dist(:) = 1/numel(dist);

% Do not allow extrapolation
kpPolicy = min(max(kpPolicy,kMin),kMax);
% Lookup kpPolicy into grid
[~,kpPolicyLeftGrid] = histc(kpPolicy,kGrid);
kpPolicyLeftGrid(kpPolicy<=kMin) = 1;
kpPolicyLeftGrid(kpPolicy>=kMax) = kPts-1;

kpPolicyCellRightShare = (kpPolicy - kGrid(kpPolicyLeftGrid)) ./ (kGrid(kpPolicyLeftGrid+1) - kGrid(kpPolicyLeftGrid));


metric = 1;
iter = 0;
while metric > TOL_DIST
    % Iterate distribution one step further
    dist_new = zeros(ePts,kPts);
    for i_e = 1:ePts
        for i_k=1:kPts
            dist_new(i_e,kpPolicyLeftGrid(i_e,i_k)) = dist_new(i_e,kpPolicyLeftGrid(i_e,i_k)) + ...
                dist(i_e,i_k) * (1-kpPolicyCellRightShare(i_e,i_k));
            dist_new(i_e,kpPolicyLeftGrid(i_e,i_k)+1) = dist_new(i_e,kpPolicyLeftGrid(i_e,i_k)+1) + ...
                dist(i_e,i_k) * kpPolicyCellRightShare(i_e,i_k);
        end
    end
    % Account for process for e
    dist_new = eTrans' * dist_new;
    
    metric = sum(abs(dist(:)-dist_new(:)));
    iter = iter+1;
    dist = dist_new;
    
    if mod(iter,PRINT_FREQ) == 0
        fprintf('iter: %d, metric: %g\n',iter, metric);
    end
end
end
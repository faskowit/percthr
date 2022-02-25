function [thr_mask,perc_thr] = percthr_trimlow_und(W) 
%PERCTHR_TRIMLOW    Percolation threshold by trimming low edge weights in
%                   order of their magnitude. Threshold is at the point
%                   where trimming any more edges will break the network
%                   into multiple components. Inspired by Nicolini et al.
%                   (2020) NeuroImage and Bordier et al. (2017) Front. in
%                   Neuroscience. 
%
%   [thr_mask perc_thr] = percthr_trimlow_und(W);
%
%   This function thresholds out low edge weights in order of magnitude
%   until the network becomes disconnected.
%
%   Input:      W,      undirected (binary/weighted) connection matrix, 
%                       must have one and only one connected component
%
%   Output:     thr_mask,       binary percolation threshold mask
%               perc_thr,       the value such that W>=perc_thr is last 
%                               connected network
%
%   2021 Josh Faskowitz, IU

if ~isconnected(abs(W)) % need to abs this first check, so it does get stuck
   error('input network is not connected') 
end

od_edges = W(~eye(size(W,1))) ; % edge vals off diagonal
e_list = unique(od_edges) ; % returns sorted ascending list of unique vals
n_e = length(e_list) ;

L = 1 ;
R = n_e ;
att = 0 ; % lets track attempts just for safety
while L <= R
    if att > ceil(log(n_e)) + 1 ; break ; end % safety break after 
                                              % time that search alg should 
                                              % theoretically take
    
    m = floor((L+R)/2) ;
        
    a = isconnected(W>e_list(m)) ; % thr including curr edge value
    b = isconnected(W>e_list(m+1)) ; % thr above curr edge value

    if a==1 && b==0
        thr_mask = (W>e_list(m)) ;
        perc_thr = e_list(m+1) ;
        return 
    elseif a==1 && b==1
        L = m-1;
    else % a==0 && b==0
        R = m+1;
    end
    att = att + 1 ;
end
error('made it to end, error...sorry')

function S = isconnected(adj)
% http://strategic.mit.edu/docs/matlab_networks/isconnected.m
% Determine if a graph is connected
% INPUTS: adjacency matrix
% OUTPUTS: Boolean variable {0,1}
% Note: this only works for undirected graphs
% Idea by Ed Scheinerman, circa 2006, source: http://www.ams.jhu.edu/~ers/matgraph/
%                                     routine: matgraph/@graph/isconnected.m

% josh edit for speed? I think it's faster?
% if not(isempty(find(sum(adj)==0))); S = false; return; end
if any(sum(adj)==0) ; S = false ; return ; end

n = length(adj);
x = [1; zeros(n-1,1)]; % [1,0,...0] nx1 vector 

while 1
     y = x;
     x = adj*x + x;
     x = x>0;
     
     if x==y; break; end

end

S = true;
if sum(x)<n; S = false; end
end

% Copyright (c) 2011, Massachusetts Institute of Technology. All rights
% reserved. Redistribution and use in source and binary forms, with or
% without modification, are permitted provided that the following
% conditions are met: Redistributions of source code must retain the above
% copyright notice, this list of conditions and the following disclaimer.
% Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution. Neither the name
% of the Massachusetts Institute of Technology nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission. THIS SOFTWARE IS
% PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
% EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

end % main function

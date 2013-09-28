% this is a program for gap filling 
% Tao Huan, July 16, 2013
% use the very raw data, rather than the pair list
% 1: for each column(represent a sample), read the gaps into gap matrix
% 2: go back to the very raw data and retrieve back the matched 13C peaks.
% Go through intensity to get a candadicy list, then filter to get the best
% score with mz and rt tolerance
% 3: Based on the matched 13C peak, find its correspondant 12C peak or
% return a zero value.
% 4: Write the gap matrix back into the origianl list
% Very streight forward
% logbook:
% Aug 10, 2013: remove display after line 49
%% tested Aug 09, 2013 with Yiman. Make a copy to W303
tic;
FileList = dir('I:\QTOF\20130911\input\M3\*.csv');
N = size(FileList,1);
files = {FileList.name};
Files = strcat('I:\QTOF\20130911\input\M3\', files);
a = data;
[features, items] = size(a);

for Num = 1 : N % read files in a batch mode
    fid = importdata(Files{Num});% rate determine
    Y = 1;
    for i = 1 : features
        if isnan(a(i,Num + 7))
            gap_matrix(Y,:) = a(i,:);
            Y = Y + 1;
        end
    end
    mz_tol = 5;
    rt_tol = 30;
    mz_tol_12C_match = 8;% in most cases, the not matching comes from the imperfectness of instrumental error. pull it back using a higher tolerance
    score_threshod = 0.3;
    [gap_x, gap_y] = size(gap_matrix);
    [fid_x, fid_y] = size(fid.data);
    for L = 1 : gap_x
        int_diff = abs(log10(gap_matrix(L,6) ./ fid.data(:,5)));
        mz_diff = 1000000 * abs((gap_matrix(L,4) - fid.data(:,4)) / gap_matrix(L,4));
        rt_diff = abs(gap_matrix(L,2) - fid.data(:,3));
        score = (1 - mz_diff / mz_tol) * 2 / 4 + (1 - rt_diff / rt_tol) / 4 + (1 - int_diff / 0.5) / 4;
        if max(score) >= score_threshod  
           index_mz_rt = (find(score == max(score)));
                    for n = 1 : fid_x % find corresponding 12C matching peak
                        if fid.data(n,2) == fid.data(index_mz_rt,2) && n ~= index_mz_rt 
                        mz_dist = 1000000 * abs(fid.data(n,4) - gap_matrix(L,3)) / gap_matrix(L,3);
                            if mz_dist <= mz_tol_12C_match 
                                gap_matrix(L,Num + 7) = fid.data(n,6) / fid.data(index_mz_rt,6);
                                break
                            else
%                                 if gap_matrix(L,6) > 300000
                                    gap_matrix(L,Num + 7) = 0;
%                                 end
                            end
                        end
                    end
        end
            
        
        clear int_diff;
        clear candidacy;
        clear score;
    end
    for q = 1 : gap_x
        for p = 1 : features
            if a(p,3) == gap_matrix(q,3) && a(p,4) == gap_matrix(q,4) && a(p,2) == gap_matrix (q,2)
                for k = 8 : items
                    a(p,k) = gap_matrix(q,k);
                end
            end
        end
    end
    display(files{Num})
    clear gap_matrix
end
T = toc;
display(T);
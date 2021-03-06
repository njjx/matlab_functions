function line_spread_function = XuGetEdgeSpreadFunction(edgedata)
%line_spread_function = XuGetEdgeSpreadFunction(edgedata)

if mean(edgedata(:,1))>mean(edgedata(:,end))
    edgedata = fliplr(edgedata);
end

width = size (edgedata ,2);
height = size(edgedata, 1);

linedata=diff(edgedata,1,2);
linedata(find(isnan(linedata)))=0;

linedata(:,end+1)=linedata(:,end);
[val, indx] = max(abs(linedata),[],2);

height_vec = 1:height;

idx_outlier=false(1,height);

for height_idx = 1:height
    if mod(height_idx,30)==0
        height_roi = (height_idx-29):height_idx;
        idx_outlier(height_roi)= abs(indx(height_roi)-mean(indx(height_roi)))>2;
    end
end

%idx_outlier = abs(indx-mean(indx))>2*indx_std;
indx(idx_outlier)=[];
height_vec(idx_outlier)=[];


P=polyfit(height_vec,indx',1);

ShiftedIndx=zeros(height,width);
for rowidx=1:height
    ShiftedIndx(rowidx,:)=(1:width)-(P(1,1))*(rowidx-1)*1;
end

line_spread_function=zeros(2,height*width);

for rowidx=1:height
    for colomnidx=1:width
        num=(rowidx-1)*width+colomnidx;
        line_spread_function(1,num)=ShiftedIndx(rowidx,colomnidx);
        line_spread_function(2,num)=linedata(rowidx,colomnidx);
    end
end
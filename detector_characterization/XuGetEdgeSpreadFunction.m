function edge_spread_function = XuGetEdgeSpreadFunction(edgedata)
%

if mean(edgedata(:,1))>mean(edgedata(:,end))
    edgedata = fliplr(edgedata);
end

width = size (edgedata ,2);
height = size(edgedata, 1);

linedata=diff(edgedata,1,2);
linedata(find(isnan(linedata)))=0;

linedata(:,end+1)=linedata(:,end);
[val, indx] = max(abs(linedata),[],2);

P=polyfit(1:height,indx',1);

ShiftedIndx=zeros(height,width);
for rowidx=1:height
    ShiftedIndx(rowidx,:)=(1:width)-tan(P(1,1))*(rowidx-1)*1;
end

edge_spread_function=zeros(2,height*width);

for rowidx=1:height
    for colomnidx=1:width
        num=(rowidx-1)*width+colomnidx;
        edge_spread_function(1,num)=ShiftedIndx(rowidx,colomnidx);
        edge_spread_function(2,num)=edgedata(rowidx,colomnidx);
    end
end
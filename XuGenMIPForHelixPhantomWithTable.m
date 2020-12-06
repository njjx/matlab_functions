
function mip = XuGenMIPForHelixPhantomWithTable(s_evi, framenum, row_begin, row_end)

image = XuReadHydraEviFromDirect_ver2(s_evi,framenum);

image = image - mean(image(:,row_begin:row_end,:),2);
mip = min(image,[],3);
XuWriteRawWithDim('mip',mip);
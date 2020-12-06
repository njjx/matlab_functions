function status = XuModifyJsoncNoPmatrixCorrection(s_jsonc)

XuModifyJsoncFile(s_jsonc,'PMatrixFile',[]);
XuModifyJsoncFile(s_jsonc,'SDDFile',[]);
XuModifyJsoncFile(s_jsonc,'SIDFile',[]);
XuModifyJsoncFile(s_jsonc,'DetectorOffCenterFile',[]);
XuModifyJsoncFile(s_jsonc,'ScanAngleFile',[]);
status =1;
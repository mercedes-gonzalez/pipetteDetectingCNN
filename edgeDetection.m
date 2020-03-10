I = imread('C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019-2020 NET\CNN LabVIEW\20200220 testing\3665090461.png');
Ip = customPreprocess(I,size(I));
n = .125;

BW1 = edge(Ip,'Roberts',n);
BW2 = edge(Ip,'Prewitt',n);
imshowpair(BW1,BW2,'montage')


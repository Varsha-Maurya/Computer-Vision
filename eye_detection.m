% Please edit this function only, and submit this Matlab file in a zip file
% along with your PDF report
function [left_x, right_x, left_y, right_y] = eye_detection(img)
% INPUT: RGB image
% OUTPUT: x and y coordinates of left and right eye.
% clc; clear all;
% Convert image to grayscale
I_gray = rgb2gray(img);
% Find the gradient of the image.
[Px,Py] = imgradient(I_gray,'prewitt');
% Plot the gradient magnitude and the gradient direction.
% subplot(5,2,1);imshow(Px);subplot(5,2,2);imshow(Py);
% Find the center of the Image.
[row col] = size(I_gray);
XCenter = ceil(row/2);
Ycenter = ceil(col/2);
% Run edge detector on the image.
I_edge = edge(I_gray,'canny');
%Find the first white pixel in this row. This could be a totally unrelated 
%edge but the idea is to trim the search space if one side has more
%background. Like in image 7 this will narrow down the location of object.
LeftPixel = find(I_edge(XCenter,:)==1,1,'first');
RightPixel = find(I_edge(XCenter,:)==1,1,'last');

%Vertical Peak Region search space.
LeftSearchRegion = LeftPixel/col; 
RightSearchRegion = RightPixel/col;

% Integral projection function 
% Horizontal IPF 
% Using just the gradient magnitude.
for i=1:row
    IPF_h(i) = (sum(Px(i,:)))/row;
end

%Vertical IPF 
for j=1:col
    IPF_v(j) = (sum(Px(:,j)))/col;
end

%Find vertical peaks from the projections.
%we will use the search space we found to find the peak close to that
%region.
[rv cv] = size(IPF_v);
%%% Left vertical point.
VerticalPointOneLowerBound = ceil(LeftSearchRegion * cv);
VerticalPointOneUpperBound = ceil((0.09+LeftSearchRegion)*cv);
VerticalPointOne(1,VerticalPointOneLowerBound:VerticalPointOneUpperBound) = IPF_v(VerticalPointOneLowerBound:VerticalPointOneUpperBound);

%%% Find Peak for the vertical point one
[PositionV1,LocationV1] = findpeaks(VerticalPointOne);
VerticalPeakPL1 = [PositionV1;LocationV1];
%%% Getting the position and location for the maximum peak.
[VerticalPeakOne,b] = max(VerticalPeakPL1(1,:));
VerticalLocationOne = VerticalPeakPL1(2,b);

%%% Right vertical point
VerticalPointTwoUpperBound = ceil(RightSearchRegion * cv);
VerticalPointTwoLowerBound = ceil((RightSearchRegion-0.10)*cv);
VerticalPointTwo(1,VerticalPointTwoLowerBound:VerticalPointTwoUpperBound) = IPF_v(VerticalPointTwoLowerBound:VerticalPointTwoUpperBound);
%%% FInd Peak for the vertical point two.
[PositionV2,LocationV2] = findpeaks(VerticalPointTwo);
VerticalPeakPL2 = [PositionV2; LocationV2];
%%% Getting the position and location for the maximum peak.
[VerticalPeakTwo,b] = max(VerticalPeakPL2(1,:));
VerticalLocationTwo = VerticalPeakPL2(2,b);


%%% For Horizontal peak since we are concentrating on the eye the peak
%%% should be ideally in the first half. With no noise actually this should
%%% be the sharpest maximum peak in the entire human image.

%%% Let the search region be from 24% to 70% 

F = [0.01,0.1,1.1,1.2,1.2,1.2,0.8,0.6,0.1,0.01];

[rh ch] = size(IPF_h);
% HorizontalPointLowerBound = ceil(0.10 * ch);
% HorizontalPointUpperBound = ceil(0.70 * ch);
% HorizontalPoint(1,HorizontalPointLowerBound:HorizontalPointUpperBound) = IPF_h(HorizontalPointLowerBound:HorizontalPointUpperBound);

HorizontalPointLowerBound=1;
HorizontalPointUpperBound = floor(0.10*ch);
for i=1:length(F)
    HorizontalPoint(HorizontalPointLowerBound:HorizontalPointUpperBound) = F(i) * IPF_h(HorizontalPointLowerBound:HorizontalPointUpperBound);
    HorizontalPointLowerBound = HorizontalPointUpperBound +1;
    HorizontalPointUpperBound = HorizontalPointUpperBound + floor(0.10*ch);
end

%%% Find Peak for the vertical point two.
[PositionH,LocationH] = findpeaks(HorizontalPoint);
HorPeakPL = [PositionH; LocationH];
%%% Getting the position and location for the maximum peak.
[HorizontalPeak,b] = max(HorPeakPL(1,:));
HorizontalLocation = HorPeakPL(2,b);


%%%Don't change anything above this %%%%
median_line = insertShape(I_gray,'Line',[VerticalLocationOne HorizontalLocation VerticalLocationTwo HorizontalLocation],'LineWidth',4,'Color','blue');

%From the median line go up +15 and go down -15 to get the eye region.
x = HorizontalLocation - ceil(row/8);
y = VerticalLocationTwo - VerticalLocationOne;
z = ceil(row/4);
rect = insertShape(median_line,'Rectangle',[VerticalLocationOne x y z],'LineWidth',4,'Color','red');
extract_eye = imcrop(I_gray,[VerticalLocationOne,x,y,z]);

[er ec] = size(extract_eye);

SD = std(double(extract_eye(:)));
Max = max(extract_eye(:));
T = floor((SD/double(Max))*100)/100


SE = strel('disk',2);
smooth = imgaussfilt(extract_eye,1);
D = imdilate(smooth,SE);
% figure;imshow(D);
E = imerode(smooth,SE);
% figure;imshow(E);
diff = D-E;
% figure;imshow(diff);
B = imbinarize(diff,T);
subplot(3,2,4);imshow(B);


%%% Since hough transform is very sensitive for small regions. we try
%%% different ranges to find the best fit.
Rmin = [7,6,4];
HoughTransform_flag=false;
for j=1:3
    [centers, radii, metric] = imfindcircles(B,[Rmin(j) 15],'ObjectPolarity','bright'); 
    %Check if there are two point detected. If there are only two points on
    %each side then we can be sure that it is an eye. We will just return
    %that and break;
    if length(radii) == 2
        if (centers(1,1) < ec/2 && centers(2,1) > ec/2)
            X_left_HT = centers(1,1);
            Y_left_HT = centers(1,2);
            X_right_HT = centers(2,1);
            Y_right_HT = centers(2,2);
            HoughTransform_flag=true;
            break;
        elseif (centers(1,1) > ec/2 && centers(2,1) < ec/2)
            X_right_HT = centers(1,1);
            Y_right_HT = centers(1,2);
            X_left_HT = centers(2,1);
            Y_left_HT = centers(2,2);
            HoughTransform_flag=true;
            break;
        else
            disp("Looks like both points like on the same side")
        end
    elseif length(radii) > 2 
        break;
    end   
end

% Finding BRISK features.
points = detectBRISKFeatures(extract_eye);
strongest = points.selectStrongest(5);
Loc = strongest.Location;
%divide it in left strong and right strong 
Center = ceil(size(extract_eye)/2);
LeftStrong=[];
RightStrong=[];
for i=1:length(Loc)
    if Loc(i,1) < Center(2)
        LeftStrong = [LeftStrong;Loc(i,:)]; 
    else
        RightStrong = [RightStrong;Loc(i,:)];
    end
end
if(~isempty(LeftStrong) && ~isempty(RightStrong));BRICS_flag=true;else;BRICS_flag=false;end

if(BRICS_flag==true)
    KnnLeft = knnsearch(LeftStrong,Center,'K',1);
    KnnRight = knnsearch(RightStrong,Center,'K',1);
    X_left_BRICS = LeftStrong(KnnLeft,1);
    Y_left_BRICS = LeftStrong(KnnLeft,2);

    X_right_BRICS = RightStrong(KnnRight,1);
    Y_right_BRICS = RightStrong(KnnRight,2);
end


if(BRICS_flag==true && HoughTransform_flag ==true)
    %Strong match return BRIC
    disp("BRIC_TT");
    X_left=X_left_BRICS;
    Y_left=Y_left_BRICS;
    X_right = X_right_BRICS;
    Y_right = Y_right_BRICS;
elseif (BRICS_flag==false && HoughTransform_flag ==true)
    %Good match return HT
    disp("HT");
    X_left=X_left_HT;
    Y_left=Y_left_HT;
    X_right = X_right_HT;
    Y_right = Y_right_HT;
elseif (BRICS_flag==true && HoughTransform_flag ==false)
    %Good match return BRIC
    disp("BRIC");
    X_left=X_left_BRICS;
    Y_left=Y_left_BRICS;
    X_right = X_right_BRICS;
    Y_right = Y_right_BRICS;
else
    %No good match. return something.
    disp("No good match");
    X_left=0.75*Center(1);
    Y_left=0.30*Center(2);
    X_right = Center(1) + 0.75*Center(1);
    Y_right =0.30*Center(2);
    
end


left_x = VerticalLocationOne + X_left;
left_y = x + Y_left;
right_x = VerticalLocationOne + X_right;
right_y = x + Y_right;
end
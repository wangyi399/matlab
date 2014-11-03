function [xCoords yCoords] = getElectrodeCoords512()

% coordinate of each electrode on the 512-electrode array, in microns with
% the origin at the center of the array

% modified from getElectrodeCoords61() for the 512-electrode array by
% Lauren Grosberg 1/22/14


 xCoords = [ 465   465   465   465   435   435   435   435   405   405   405   405   375   375   375 ...
     375   345   345   345   345   315   315   315   315   285   285   285   285   255   255   255   ...
     255   225   225   225   225   195   195   195   195   165   165   165   165   135   135   135   ...
     135   105   105   105   105    75    75    75    75    45    45    45    45    15    15    15   ...
     15   -15   -15   -15   -15   -45   -45   -45   -45   -75   -75   -75   -75  -105  -105  -105  ...
     -105  -135  -135  -135  -135 -165  -165  -165  -165  -195  -195  -195  -195  -225  -225  -225 ...
     -225  -255  -255  -255  -255  -285  -285  -285  -285  -315  -315  -315 -315  -345  -345  -345  ...
     -345  -375  -375  -375  -375  -405  -405  -405  -405  -435  -435  -435 -435  -465  -465  -465  ...
     -465  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585  -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -945  -885  -825  -765  -705  -645  -585 -525  -915  -855  -795  -735  -675  -615  -555  ...
     -495  -465  -465  -465  -465  -435  -435  -435  -435  -405  -405  -405  -405  -375  -375  -375  ...
     -375  -345  -345  -345 -345  -315  -315  -315  -315  -285  -285  -285  -285  -255  -255  -255  ...
     -255  -225  -225  -225  -225  -195  -195  -195  -195  -165  -165  -165  -165  -135  -135  -135  ...
     -135  -105  -105  -105  -105   -75   -75   -75   -75   -45   -45   -45   -45   -15   -15   -15   ...
     -15    15    15    15   15    45    45    45    45    75    75    75    75   105   105   105   ...
     105   135   135   135   135   165   165   165   165   195   195   195   195   225   225   225  ...
     225   255   255   255   255   285   285   285  285   315   315   315   315   345   345   345   ...
     345   375   375   375   375   405   405   405   405   435   435   435   435   465   465   465   ...
     465   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945  495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   ...
     915   525   585   645   705   765   825   885   945   495   555   615   675   735   795   855   915];
 
 yCoords = [-30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
   -30
  -150
  -270
  -390
   -90
  -210
  -330
  -450
  -450
  -450
  -450
  -450
  -450
  -450
  -450
  -450
  -390
  -390
  -390
  -390
  -390
  -390
  -390
  -390
  -330
  -330
  -330
  -330
  -330
  -330
  -330
  -330
  -270
  -270
  -270
  -270
  -270
  -270
  -270
  -270
  -210
  -210
  -210
  -210
  -210
  -210
  -210
  -210
  -150
  -150
  -150
  -150
  -150
  -150
  -150
  -150
   -90
   -90
   -90
   -90
   -90
   -90
   -90
   -90
   -30
   -30
   -30
   -30
   -30
   -30
   -30
   -30
    30
    30
    30
    30
    30
    30
    30
    30
    90
    90
    90
    90
    90
    90
    90
    90
   150
   150
   150
   150
   150
   150
   150
   150
   210
   210
   210
   210
   210
   210
   210
   210
   270
   270
   270
   270
   270
   270
   270
   270
   330
   330
   330
   330
   330
   330
   330
   330
   390
   390
   390
   390
   390
   390
   390
   390
   450
   450
   450
   450
   450
   450
   450
   450
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   390
   270
   150
    30
   450
   330
   210
    90
   450
   450
   450
   450
   450
   450
   450
   450
   390
   390
   390
   390
   390
   390
   390
   390
   330
   330
   330
   330
   330
   330
   330
   330
   270
   270
   270
   270
   270
   270
   270
   270
   210
   210
   210
   210
   210
   210
   210
   210
   150
   150
   150
   150
   150
   150
   150
   150
    90
    90
    90
    90
    90
    90
    90
    90
    30
    30
    30
    30
    30
    30
    30
    30
   -30
   -30
   -30
   -30
   -30
   -30
   -30
   -30
   -90
   -90
   -90
   -90
   -90
   -90
   -90
   -90
  -150
  -150
  -150
  -150
  -150
  -150
  -150
  -150
  -210
  -210
  -210
  -210
  -210
  -210
  -210
  -210
  -270
  -270
  -270
  -270
  -270
  -270
  -270
  -270
  -330
  -330
  -330
  -330
  -330
  -330
  -330
  -330
  -390
  -390
  -390
  -390
  -390
  -390
  -390
  -390
  -450
  -450
  -450
  -450
  -450
  -450
  -450
  -450];
yCoords = yCoords.'; 
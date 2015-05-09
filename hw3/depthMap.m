function [z] = depthMap( surfNormals, maskImage)

  [nr,nc] = size(maskImage);
  
  z = zeros(nr,nc);
  [fgr,fgc] = find(maskImage);
  fgpix = [fgr fgc];
  
  % Creating index matrix for faster lookup of pixel indices
  m = zeros(nr,nc);
  % Number of pixels in foreground
  numpix = size(fgpix,1);
  
  for d=1:numpix
      r = fgpix(d,1);
      c = fgpix(d,2);
      m(r,c) = d;
  end
  indMatr = zeros(nr+2,nc+2);
  indMatr(2:nr+1,2:nc+1) = m;
  
  % M: (2*pix x pix) matrix used to calculate z
  % N: (2*pix x 1) matrix which records normal vector ratio to z.
  M = sparse(2*numpix, numpix);
  b = zeros(2*numpix, 1);
  
  for d=1:numpix
      r = fgpix(d,1);
      c = fgpix(d,2);
      nx = surfNormals(r,c,1);
      ny = surfNormals(r,c,2);
      nz = surfNormals(r,c,3);
      r=r+1;
      c=c+1;
      
      if(indMatr(r,c+1) > 0) && (indMatr(r-1,c) > 0),
          M(2*d-1, indMatr(r,c))   = 1;
          M(2*d-1, indMatr(r,c+1)) = -1;
          b(2*d - 1) = nx / nz;
          M(2*d, indMatr(r,c))   = 1;
          M(2*d, indMatr(r-1,c)) = -1;
          b(2*d) = ny / nz;
      elseif( indMatr(r-1,c) > 0),
          if( indMatr(r,c-1) > 0),
              M(2*d-1, indMatr(r,c))   = 1;
              M(2*d-1, indMatr(r,c-1)) = -1;
              b(2*d-1) = -nx/nz;
          end
          M(2*d, indMatr(r,c))   = 1;
          M(2*d, indMatr(r-1,c)) = -1;
          b(2*d) = ny / nz;
      elseif( indMatr(r,c+1) > 0 ),
          if( indMatr(r-1,c) > 0),
              M(2*d, indMatr(r,c))   = 1;
              M(2*d, indMatr(r-1,c)) = -1;
              b(2*d) = -ny / nz;
          end
          M(2*d-1, indMatr(r,c) ) = 1;
          M(2*d-1, indMatr(r,c+1)) = -1;
          b(2*d-1) = nx / nz;
      else
          if( indMatr(r,c-1) > 0),
              M(2*d-1, indMatr(r,c)) = 1;
              M(2*d-1, indMatr(r,c-1)) = -1;
              b(2*d-1) = -nx/nz;
          end
          if( indMatr(r-1,c) > 0),
              M(2*d, indMatr(r,c)) = 1;
              M(2*d, indMatr(r,c-1)) = -1;
              b(2*d) = -ny / nz;
          end
      end
  end
  
  x = M \ b;
  x = x - min(x); % normalize from [0,maxx]
  
  temp = zeros(nr,nc);
  for d=1:numpix
      r = fgpix(d,1);
      c = fgpix(d,2);
      temp(r,c) = x(d,1);
  end
  
  for r=1:nr
      for c=1:nc
          z(r,c) = temp(nr-r+1,c);
      end
  end
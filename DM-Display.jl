function chopeps(epsv::Array{Float64,1},eA::Array{Float64,2},vA::Array{Float64,2};epsmax=Inf,epsmin=-Inf)
  if (epsmax < Inf )| (epsmin > -Inf)
    epsvinds = ((epsv .>= epsmin)&(epsv .<= epsmax));
    epsv = epsv[epsvinds]
    eA = eA[:,epsvinds]
    vA = vA[:,epsvinds]
  end
  return epsv, eA, vA
end


searchdir(path,key) = filter(x->contains(x,key), readdir(path))
searchdirh5(path,key) = filter(x->contains(x,".h5"),searchdir(path,key))

function synthesiseresults(PInitial,Jpathx="",extrastuff=["rs"])
  path = "$(Jpathx)"
  println("Looking in ",path)
  files = searchdirh5(path,"$(PInitial)")
  for str in extrastuff
    files = filter(x->contains(x,"$(str)"),files)
  end
  FL = length(files)
  println(FL, " files found")
  FL == 0 && (return (Nothing, Nothing))
  for i = 1:FL
    f = files[i]
    L = load("$(path)/$f")
    er = L["epsv"]
    eA = L["eA"]
    vA = L["vA"]
    if i == 1
      AN = size(eA,1)
      erv = er
      eAv = eA
      vAv = vA
      println("AN = ",AN)
    elseif size(eA,1) == AN
      erv = ([erv, er])
      eAv = ([eAv  eA])
      vAv = ([vAv vA])
    end
    println("$f contains ",length(er)," entries")
    if i == FL
      println("Total length = ",length(erv))
      return (erv, eAv, vAv)
    end
  end
end
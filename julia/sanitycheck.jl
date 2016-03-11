using HDF5

export isvalid_mdf

function isvalid_mdf(filename::AbstractString)
  # check if file is an HDF5 file
  !ishdf5(filename) && error("$filename is no valid HDF5 file.")
  ivalid = ishdf5(filename)

  # open HDF5 file
  fid = h5open(filename, "r")

  # open root group
  rootgroup = fid["/"]
  # check if dataset version exists
  !exists(rootgroup, "version") && warn("Dataset version in $rootgroup is missing.")
  isvalid = isvalid & exists(rootgroup, "version")
  # read dataset version
  version = read(rootgroup,"version")
  # give a warning, if version is not at least 1.0
  !(version >= "1.0") && warn("The dataset version in $rootgroup indicates that you use a pre-release version of MDF5.")
  close(rootgroup)

  # ckeck if all non-optional datasets are provided
  isvalid = isvalid & _hasAllNonOptDatasets(fid,version)
  # check if all datasets have the correct type
  isvalid = isvalid & _hasCorrectTypeAndNdim(fid,version)

  # close HDF5 file
  close(fid)
  return isvalid
end

function _hasAllNonOptDatasets(fid, version)
  result = true
  nonoptionalgroups1_0 = Dict{ASCIIString, Vector{ASCIIString}}(
    "/" => ["version", "uuid", "date"],
    "/scanner/" => ["facility", "operator", "manufacturer", "model", "topology"],
    "/acquisition/" => ["numFrames", "framePeriod", "numPatches", "gradient", "time"],
    "/acquisition/drivefield/" => ["numChannels", "strength", "baseFrequency", "divider", "period", "averages", "repetitionTime", "fieldOfView", "fieldOfViewCenter"],
    "/acquisition/receiver/" => ["numChannels", "bandwidth", "numSamplingPoints", "frequencies"])
  version<"2.0" && (result = result & _hasAllDatasets(fid, nonoptionalgroups1_0))
  return result
end

function _hasAllNonOptDatasets(fid, nonoptionalgroups::Dict)
  result = true
  for group in keys(nonoptionalgroups)
    hasgroup = exists(fid, group)
    result = result & hasgroup
    if hasgroup
      g = fid[group]
      for dataset in nonoptionalgroups[group]
        hasdataset = exists(g, dataset)
	result = result & hasdataset
	!hasdataset && warn("HDF5 dataset $dataset in HDF5 group $group missing in $fid.")
      end
    else
      warn("HDF5 group $group missing in $fid.")
    end
  end
  return result
end
  
function _hasCorrectTypeAndNdim(fid,version)
  result = true
  datasettypes1_0 = Dict{ASCIIString, Vector{Tuple{ASCIIString,Type,Vector{Int64}}}}(
    "/" => [("version",Char,[0]), ("uuid",Char,[0]), ("date",Char,[0])],
    "/study/" => [("name",Char,[0]), ("experiment",Char,[0]), ("description",Char,[0]), ("subject",Char,[0]), ("reference",Int64,[0]), ("simulation", Int64,[0])],
    "/tracer/" => [("name",Char,[0]), ("batch",Char,[0]), ("vendor",Char,[0]), ("volume",Float64,[0]), ("concentration",Float64,[0]), ("time", Char,[0])],
    "/scanner/" => [("facility",Char,[0]), ("operator",Char,[0]), ("manufacturer",Char,[0]), ("model",Char,[0]), ("topology",Char,[0])],
    "/acquisition/" => [("numFrames",Int64,[0]), ("framePeriod",Float64,[0]), ("numPatches",Int64,[0]), ("gradient",Float64,[1,2]), ("time",Char,[0])],
    "/acquisition/drivefield/" => [("numChannels",Int64,[0]), ("strength",Float64,[1,2]), ("baseFrequency",Float64,[0]), ("divider",Int64,[1]), ("period",Float64,[0]), ("averages",Int64,[0]), ("repetitionTime",Float64,[0]), ("fieldOfView",Float64,[1,2]), ("fieldOfViewCenter",Float64,[1,2])],
     "/acquisition/receiver/" => [("numChannels",Int64,[0]), ("bandwidth",Float64,[0]), ("numSamplingPoints",Int64,[0]), ("frequencies",Float64,[1]), ("transferFunctions",Float64,[3])],
    "/measurement/" => [("dataFD",Any,[4,5]), ("dataTD", Any,[3,4])],
    "/calibration/" => [("dataFD",Any,[4,5]), ("snrFD",Float64,[2]), ("dataTD",Any,[3,4]), ("fieldOfView", Float64,[1]), ("fieldOfViewCenter",Float64,[1]), ("size",Int64,[1]), ("order",Char,[0]), ("positions",Float64,[2]), ("deltaSampleSize",Float64,[1]), ("method",Char,[0])],
    "/reconstruction/" => [("data",Any,[2]), ("fieldOfView", Float64,[1]), ("fieldOfViewCenter",Float64,[1]), ("size",Int64,[1]), ("order",Char,[0]), ("positions",Float64,[2])])
  version<"2.0" && (result = result & _hasCorrectType(fid, datasettypes1_0))
  return result
end

function _hasCorrectTypeAndNdim(fid,datasettypes::Dict)
  result = true
  for group in keys(datasettypes)
    hasgroup = exists(fid, group)
    if hasgroup
      g = fid[group]
      for (dataset,eldatatype,datasetndims) in datasettypes[group]
        hasdataset = exists(g, dataset)
        if hasdataset
	  dset = g[dataset]
	  dsettype = eltype(HDF5.hdf5_to_julia(dset))
	  hascorrecttype = dsettype<:eldatatype
	  result = result & hascorrecttype
	  !hascorrecttype && warn("$dset has element type $dsettype but should have $eldatatype.")
	  dsetndims = ndims(dset)
	  hascorrectndims = dsetndims in datasetndims
	  result = result & hascorrectndims
	  !hascorrectndims && warn("$dset has dimension $dsetndims but should have dimensions in $datasetndims.")
	end
      end
    end
  end
  return result
end

function _hasCorrectTypeAndNdim(fid)
  L = h5read(fid,"/acquisition/numFrames")
  J = h5read(fid,"/acquisition/numPatches")
  D = h5read(fid,"/acquisition/drivefield/numChannels")
  strengthdim = size(fid["/acquisition/drivefield/strength"])
  correctstregthdim = strengthdim == (D,) || strengthdim == (D,J)
  !correctstregthdim && warn("")

end

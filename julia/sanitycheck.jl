using HDF5

export isSane

function isSane(filename::AbstractString; Debug=true)
  # check if file is an HDF5 file
  !ishdf5(filename) && error("$filename is no valid HDF5 file.")
  issane = ishdf5(filename)

  # open HDF5 file
  fid = h5open(filename, "r")

  # open root group
  rootgroup = fid["/"]
  # check if dataset version exists
  !exists(rootgroup, "version") && warn("Dataset version in $rootgroup is missing.")
  issane = issane & exists(rootgroup, "version")
  # read dataset version
  version = read(rootgroup,"version")
  # give a warning, if version is not at least 1.0
  !(version >= "1.0") && warn("The dataset version in $rootgroup indicates that you use a pre-release version of MDF5.")
  close(rootgroup)

  # ckeck if all non-optional datasets are provided
  issane = issane & _hasAllDatasets(fid,version)
  # check if all datasets have the correct type
  issane = issane & _hasCorrectType(fid,version)

  # close HDF5 file
  close(fid)
  return issane
end

function _hasAllDatasets(fid, version)
  result = true
  version<"2.0" && (result = result & _hasAllDatasets1_0(fid))
  return result
end

function _hasAllDatasets1_0(fid)
  result = true
  nonoptionalgroups = Dict{ASCIIString, Vector{ASCIIString}}(
  "/" => ["version", "uuid", "date"],
  "/scanner/" => ["facility", "operator", "manufacturer", "model", "topology"],
  "/aquisition/" => ["numFrames", "framePeriod", "numPatches", "gradient", "time"],
  "/aquisition/drivefield/" => ["numChannels", "strength", "baseFrequency", "divider", "period", "averages", "repetitionTime", "fieldOfView", "fieldOfViewCenter"],
  "/aquisition/receiver/" => ["numChannels", "bandwidth", "numSamplingPoints", "frequencies"]) 
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
  
function _hasCorrectType(fid,version)
  result = true
  version<"2.0" && (result = result & _hasCorrectType1_0(fid))
  return result
end

function _hasCorrectType1_0(fid)
  result = true
  groups = Dict{ASCIIString, Vector{Tuple{ASCIIString,Type}}}(
  "/" => [("version",ASCIIString), ("uuid",ASCIIString), ("date",ASCIIString)],
  "/scanner/" => [("facility",ASCIIString), ("operator",ASCIIString), ("manufacturer",ASCIIString), ("model",ASCIIString), ("topology",ASCIIString)],
  "/aquisition/" => [("numFrames",Int64), ("framePeriod",Float64), ("numPatches",Int64), ("gradient",Float64), ("time",ASCIIString)],
  "/aquisition/drivefield/" => [("numChannels",Int64), ("strength",Float64), ("baseFrequency",Float64), ("divider",Int64), ("period",Float64), ("averages",Int64), ("repetitionTime",Float64), ("fieldOfView",Float64), ("fieldOfViewCenter",Float64)])

  for group in keys(groups)
    hasgroup = exists(fid, group)
    if hasgroup
      g = fid[group]
      for (dataset,datatype) in groups[group]
        hasdataset = exists(g, dataset)
        if hasdataset
	  test = g[dataset]
	  correcttype = HDF5.hdf5_to_julia(test)==datatype
	  result = result & correcttype
	  !correcttype && warn("HDF5 dataset $dataset in HDF5 group $group has type $(HDF5.hdf5_to_julia(test)) but should have $datatype.")
	end
      end
    end
  end
  return result
end

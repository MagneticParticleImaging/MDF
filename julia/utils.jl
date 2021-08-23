# Utility functions since HDF5.jl does not support the complex datatypes out of the box

function getComplexType(file, dataset)
  T = HDF5.get_jl_type(
            HDF5.Datatype(
              HDF5.h5t_get_member_type( datatype(file[dataset]).id, 0 )
          )
        )
    return Complex{T}
end

function readComplexArray(file::HDF5.File, dataset)
  T = getComplexType(file, dataset)
  A = copy(HDF5.readmmap(file[dataset],getComplexType(file,dataset)))
  return A
end

function readComplexArray(filename::String, dataset)
  h5open(filename, "r") do file
    readComplexArray(file, dataset)
  end
end

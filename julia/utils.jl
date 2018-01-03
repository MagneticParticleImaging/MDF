# Utility functions since HDF5.jl does not support the complex datatypes out of the box

function getComplexType(file, dataset)
  T = HDF5.hdf5_to_julia_eltype(
            HDF5Datatype(
              HDF5.h5t_get_member_type( datatype(file[dataset]).id, 0 )
          )
        )
    return Complex{T}
end

function readComplexArray(filename::String, dataset)
  h5open(filename, "r") do file
    T = getComplexType(file, dataset)
    return copy(readmmap(file[dataset],Array{getComplexType(file,dataset)}))
  end
end

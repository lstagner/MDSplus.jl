module MDSplus

using Libdl


#= mdslib.h
  int MdsConnect(char *host);
  int descr(int *dtype, void *data, int *dim1, ...);
  int descr2(int *dtype, int *dim1, ...);
  int MdsOpen(char *tree, int *shot);
  int MdsClose(char *tree, int *shot);
  int MdsSetDefault(char *node);
  int MdsValue(char *expression, ...);
  int MdsPut(char *node, char *expression, ...);
  int MdsValue2(char *expression, ...);
  int MdsPut2(char *node, char *expression, ...);
  int MdsSetSocket(int *socket);
  void MdsDisconnect();
  int MdsConnectR(char *host);
  int MdsOpenR(int *conid, char *tree, int *shot);
  int MdsCloseR(int *conid, char *tree, int *shot);
  int MdsSetDefaultR(int *conid, char *node);
  int MdsValueR(int *conid, char *expression, ...);
  int MdsPutR(int *conid, char *node, char *expression, ...);
  int MdsValue2R(int *conid, char *expression, ...);
  int MdsPut2R(int *conid, char *node, char *expression, ...);
  void MdsDisconnectR(int *conid);
=#

#push!(Libdl.DL_LOAD_PATH,ENV["MDS_SHLIB_PATH"])
push!(Libdl.DL_LOAD_PATH,"/fusion/usc/c8/opt/mdsplus/alpha/7.139.59/lib")

MdsTypes = Dict{DataType,Int32}(UInt8 => 2, UInt16 => 3, UInt32 => 4, UInt64 => 5,
                                Int8 => 6, Int16 => 7, Int32 => 8, Int64 => 9,
                                Float32 => 10, Float64 => 11,
                                Complex{Float32} => 12, Complex{Float64} => 13,
                                Cstring => 14)

@generated function descr(mds_type::Int32, s::NTuple{N,T}, data) where {N,T}
    # int descr(int *dtype, void *data, int *dim1, ...);
    args = ((:(Int32(s[$i])) for i=1:N)...,:(zero(Int32)),)
    ccall_impl =  :(ccall( (:descr, "libMdsLib"), Cint,
                           (Ref{Cint}, Ptr{Cvoid}, Ref{Cint}...),
                            mds_type, data, $(args...)))
    # println(ccall_impl)
    return ccall_impl
end

function descr(data)
    descr(MdsTypes[eltype(data)], size(data), data)
end

function MdsConnect(server::AbstractString)
    ccall( (:MdsConnect, "libMdsLib"), Cint, (Cstring,), server)
end

function MdsDisconnect()
    ccall( (:MdsDisconnect, "libMdsLib"), Cvoid, ())
end

function MdsOpen(tree::AbstractString, shot::Int)
    ccall( (:MdsOpen, "libMdsLib"), Cint, (Cstring, Ref{Cint}), tree, Int32(shot))
end

function MdsClose(tree::AbstractString, shot::Int)
    ccall( (:MdsClose, "libMdsLib"), Cint, (Cstring, Ref{Cint}), tree, Int32(shot))
end

function MdsSetDefault(node::AbstractString)
    ccall( (:MdsSetDefault, "libMdsLib"), Cint, (Cstring,), node)
end

@generated function MdsValue(expression::AbstractString, d::Vararg{T,N}) where {T,N}
    # int MdsValue(char *expression, ...);

    args = ((:(Int32(d[$i])) for i=1:N)...,:(zero(Int32)),:(Int32[0]),)

    ccall_impl =  :(ccall( (:MdsValue, "libMdsLib"), Cint,
                           (Cstring, Ref{Cint}...),
                            expression, $(args...)))
    # println(ccall_impl)
    return ccall_impl
end

@generated function MdsPut(node::AbstractString, expression::AbstractString, d::Vararg{T,N}) where {T,N}
    # int MdsPut(char *node, char *expression, ...);

    args = ((:(Int32(d[$i])) for i=1:N)...,:(zero(Int32)),)

    ccall_impl =  :(ccall( (:MdsPut, "libMdsLib"), Cint,
                           (Cstring, Cstring, Ref{Cint}...),
                            expression, $(args...)))
    # println(ccall_impl)
    return ccall_impl
end

function MdsSetSocket(socket)
    ccall( (:MdsSetSocket, "libMdsLib"), Cint, (Ref{Cint},), Int32(socket))
end

export descr, MdsConnect, MdsDisconnect, MdsOpen, MdsClose
export MdsSetDefault, MdsValue, MdsPut, MdsSetSocket

end

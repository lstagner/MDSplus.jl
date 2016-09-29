module MDSplus

push!(Libdl.DL_LOAD_PATH,ENV["MDS_SHLIB_PATH"])

MdsTypes = Dict{DataType,Int32}(UInt8 => 2, UInt16 => 3, UInt32 => 4, UInt64 => 5,
                                Int8 => 6, Int16 => 7, Int32 => 8, Int64 => 9,
                                Float32 => 10, Float64 => 11,
                                Complex{Float32} => 12, Complex{Float64} => 13,
                                Cstring => 14)

function descr{T,N}(::Type{T}, s::NTuple{N,Int}, data)
    mds_type = MdsTypes[T]
    if N == 0
        ss = map(Int32, (s...,0))
    else
        ss = map(Int32,s)
    end
    ccall( (:descr, "libMdsLib"), Cint, (Ref{Cint}, Ptr{Void}, Ref{Cint}, Ref{Cint}...), mds_type, Ref(data), ss...,Int32(0))
end

function descr(data)
    s = size(data)
    mds_type = MdsTypes[eltype(data)]
    descr(eltype(data), s, data)
end

function MdsConnect(server::AbstractString)
    ccall( (:MdsConnect, "libMdsLib"), Cint, (Cstring,), server)
end

function MdsDisconnect()
    ccall( (:MdsDisconnect, "libMdsLib"), Void, ())
end

function MdsOpen{T<:Integer}(tree::AbstractString, shot::T)
    ccall( (:MdsOpen, "libMdsLib"), Cint, (Cstring,Ref{Cint}), tree, Int32(shot))
end

function MdsClose{T<:Integer}(tree::AbstractString, shot::T)
    ccall( (:MdsClose, "libMdsLib"), Cint, (Cstring,Ref{Cint}), tree, Int32(shot))
end

function MdsSetDefault(node::AbstractString)
    ccall( (:MdsSetDefault, "libMdsLib"), Cint, (Cstring,), node)
end

function MdsValue{N,T<:Integer}(expression::AbstractString, d::Vararg{T,N})
    dd = map(Int32, d)
    len = [Int32(0)]
    NULL = Int32(0)
    stat = ccall( (:MdsValue, "libMdsLib"), Cint, (Cstring, Ref{Cint}...), expression, dd..., NULL, len)
    return stat
end

function MdsPut{N,T<:Integer}(node::AbstractString, expression::AbstractString, d::Vararg{T,N})
    dd = map(Int32, d)
    ccall( (:Mdsput, "libMdsLib"), Cint, (Cstring, Cstring, Ref{Cint}...), expression, dd...,Int32(0))
end

function MdsSetSocket{T<:Integer}(socket::T)
    ccall( (:MdsSetSocket, "libMdsLib"), Cint, (Ref{Cint},), Int32(socket))
end

export descr, MdsConnect, MdsDisconnect, MdsOpen, MdsClose
export MdsSetDefault, MdsValue, MdsPut, MdsSetSocket

end

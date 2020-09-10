
struct MockField{T,D} <: NewField
  v::T
  function MockField{D}(v::Number) where {T,D}
    new{typeof(v),D}(v)
  end
end

MockField(D::Int,v::Number) = MockField{D}(v)

mock_field(D::Int,v::Number) = MockField{D}(v)

function return_cache(f::MockField,x::AbstractArray{<:Point})
  nx = length(x)
  c = zeros(typeof(f.v),nx)
  CachedArray(c)
end

function evaluate!(c,f::MockField,x::AbstractArray{<:Point})
  nx = length(x)
  setsize!(c,(nx,))
  for i in eachindex(x)
    @inbounds xi = x[i]
    @inbounds c[i] = f.v*xi[1]
  end
  c.array
end

@inline function gradient(f::MockField{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField{D}(vg)
end

# @santiagobadia : We want this to be an array. Result of the meeting w/
# @fverdugo 09/09/20.

struct MockBasis{V,D} <: NewField
  v::V
  ndofs::Int
  function MockBasis{D}(v::Number,ndofs::Int) where D
    new{typeof(v),D}(v,ndofs)
  end
end

function return_cache(f::MockBasis,x::AbstractArray{<:Point})
  np = length(x)
  s = (np, f.ndofs)
  c = zeros(typeof(f.v),s)
  CachedArray(c)
end

function evaluate!(v,f::MockBasis,x::AbstractArray{<:Point})
  np = length(x)
  s = (np, f.ndofs)
  setsize!(v,s)
  for i in 1:np
    @inbounds xi = x[i]
    for j in 1:f.ndofs
      @inbounds v[i,j] = f.v*xi[1]
    end
  end
  v.array
end

@inline function gradient(f::MockBasis{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockBasis{D}(vg,f.ndofs)
end

struct OtherMockBasis{D} <: NewField
  ndofs::Int
  function OtherMockBasis{D}(ndofs::Int) where D
    new{D}(ndofs)
  end
end

function return_cache(f::OtherMockBasis,x::AbstractArray{<:Point})
  np = length(x)
  s = (np, f.ndofs)
  c = zeros(eltype(x),s)
  CachedArray(c)
end

function evaluate!(v,f::OtherMockBasis,x::AbstractArray{<:Point})
  np = length(x)
  s = (np, f.ndofs)
  setsize!(v,s)
  for i in 1:np
    @inbounds xi = x[i]
    for j in 1:f.ndofs
      @inbounds v[i,j] = 2*xi
    end
  end
  v.array
end

@inline function gradient(f::OtherMockBasis{D}) where D
  E = Float64
  P = Point{D,E}
  p = zero(P)
  vg = 2*one(outer(p,p))
  MockBasis{D}(vg,f.ndofs)
end

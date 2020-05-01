struct Bin{T}
  minVal :: T
  maxVal :: T
  contents :: Vector{T}
end

placeelem(elem, bin) = Bin(min(elem, bin.minVal),
                           max(elem, bin.maxVal),
                           vcat(bin.contents, [elem]))

function binelem(elem, bins)
  idx = findfirst(x -> x.maxVal >= elem, bins)
  # If no bin has maxVal greater than elem, place in last bin
  if idx === nothing; idx = length(bins); end;
  # Is there a choice between bins?
  if elem < bins[idx].minVal && idx !== 1 &&
    # If there is, choose the smaller bin
    length(bins[idx-1].contents) <= length(bins[idx].contents)
      idx -= 1
  end
  bins[idx] = placeelem(elem, bins[idx])
  return bins
end

approxExpLambertW(x) = round(Int, x/log(x))

@views function stochasticbin(ar; bins = length(ar) |> approxExpLambertW)
  if bins >= length(ar)
    return map(x -> [x], sort(ar))
  end
  binned = map(x -> Bin(x,x,[x]), sort(ar[1:bins]))
  rest = ar[(bins + 1):end]
  while length(rest) > 0
    binned = binelem(rest[1],binned)
    rest = rest[2:end]
  end
  return map(x -> x.contents, binned)
end

binsort(ar, b) = vcat(sort.(stochasticbin(ar,bins = b))...)
binsort(ar) = vcat(sort.(stochasticbin(ar))...)

function loss(ar)
  lengths = length.(ar)
  μ = sum(lengths)/length(ar)
  return map(x -> (x - μ)^2, lengths) |> sum
end


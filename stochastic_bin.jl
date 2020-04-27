mutable struct Bin
  minVal
  maxVal
  contents
end

placeElem(elem, bin) = Bin(min(elem, bin.minVal),
                           max(elem, bin.maxVal),
                           vcat([elem], bin.contents))

function firstElemSt(p,ar)
  for idx in eachindex(ar)
    if p(ar[idx])
      return idx
    end
  end
  return 0
end

function binElem(elem, bins)
  idx = firstElemSt(x -> x.maxVal >= elem, bins)
  # If no bin has maxVal greater than elem, place in last bin
  if idx == 0; idx = length(bins); end;
  # Is there a choice between bins?
  if elem < bins[idx].minVal && idx !== 1 &&
    # If there is, choose the smaller bin
    length(bins[idx-1].contents) <= length(bins[idx].contents)
      idx -= 1
  end
  bins[idx] = placeElem(elem, bins[idx])
  return bins
end

approxLambertW(x) = round(Int, log(x) - log(log(x)))

function stochasticBin(ar; bins = length(ar) |> approxLambertW)
  if bins >= length(ar)
    return map(x -> [x], sort(ar))
  end
  binned = map(x -> Bin(x,x,[x]), sort(ar[1:bins]))
  rest = ar[(bins + 1):end]
  while length(rest) > 0
    binned = binElem(rest[1],binned)
    rest = rest[2:end]
  end
  return map(x -> x.contents, binned)
end


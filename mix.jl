using Distributions

function mix(init, mix, n; α = 1)
  distr = init
  for i in 1:n
    x = rand(distr)
    distr = MixtureModel([distr, mix(x)], [i/(α+i), α/(α+i)])
  end
  return distr
end


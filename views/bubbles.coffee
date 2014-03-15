selection = "body"
geo = new Geo()

calculateRadius = (scale, value, maxRadius) -> 
  topArea = geo.areaFromRadius(maxRadius)
  ratio = scale(value)
  area = topArea * ratio
  geo.radiusFromArea(area)

d3.csv("/data/data.csv", (error, data) ->
	groupWidth = 200
	groupHeight = 200
	cleanData = data[1..data.length - 1]
	maxRadius = 80

	maxEng = d3.max(cleanData, (d) -> 
		maleEng = (d['num_eng'] - d['num_female_eng'])
		if maleEng < d['num_female_eng'] then d['num_female_eng'] else maleEng
	)

	circleScale = d3.scale.linear().domain([0, maxEng])

	companies = d3.select(selection).selectAll('svg.company')
		.data(cleanData)
	.enter()
		.append('svg').attr(class: 'company')
		.attr(width: groupWidth).attr(height: groupHeight)

	companies.append('circle')
		.attr(class: 'male')
		.attr(fill: 'blue')
		.attr(r: (d) -> d.mr = calculateRadius(circleScale, d['num_eng'] - d['num_female_eng'], maxRadius))
		.attr(cy: groupHeight/2)
		.attr(opacity: 0.5)
		.attr(cx: (d) -> d.mr)

	companies.append('circle')
		.attr(class: 'female')
		.attr(fill: 'red')
		.attr(r: (d) -> d.fr = calculateRadius(circleScale, d['num_female_eng'], maxRadius))
		.attr(cy: groupHeight/2)
		.attr(opacity: 0.5)
		.attr(cx: (d) -> groupWidth/2)
)



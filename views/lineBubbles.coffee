selection = "body"
geo = new Geo()

calculateRadius = (scale, value, maxRadius) -> 
  topArea = geo.areaFromRadius(maxRadius)
  ratio = scale(value)
  area = topArea * ratio
  geo.radiusFromArea(area)

d3.csv("/data/data.csv", (error, data) ->
	cleanData = data[1..data.length - 1]
	rowHeight = 100
	legendHeight = 200
	width = 1000
	height = cleanData.length * rowHeight + legendHeight
	maxRadius = 100

	maxEng = d3.max(cleanData, (d) -> 
		maleEng = (d['num_eng'] - d['num_female_eng'])
		if maleEng < d['num_female_eng'] then d['num_female_eng'] else maleEng
	)

	circleScale = d3.scale.linear().domain([0, maxEng])
	xF = d3.scale.linear().domain([0, 1]).range([width/2, maxRadius])
	xM = d3.scale.linear().domain([0, 1]).range([width/2, width-maxRadius])

	svg = d3.select(selection)
		.append('svg')
		.attr(height: height)
		.attr(width: width)
	companies = svg.selectAll('g.company')
		.data(cleanData)
	.enter()
		.append('g').attr(class: 'company')
		.attr(transform: (d,i) -> "translate(0, #{i * rowHeight + legendHeight})")
	
	svg.append('line')
		.attr(class: 'middle')
		.attr(stroke: '#dddddd')
		.attr(x1: width/2)
		.attr(x2: width/2)
		.attr(y1: 0)
		.attr(y2: height)

	companies.append('circle')
		.attr(class: 'male')
		.attr(fill: 'blue')
		.attr(r: (d) -> d.mr = calculateRadius(circleScale, d['num_eng'] - d['num_female_eng'], maxRadius))
		.attr(cy: rowHeight/2)
		.attr(opacity: 0.5)
		.attr(cx: (d) -> xM((d['num_eng'] - d['num_female_eng'])/d['num_eng']))
	
	companies.append('line')
		.attr(class: 'male')
		.attr(stroke: 'blue')
		.attr(x1: width/2)
		.attr(x2: (d) -> xM((d['num_eng'] - d['num_female_eng'])/d['num_eng']) - d.mr ) 
		.attr(y1: rowHeight/2)
		.attr(y2: rowHeight/2)

	companies.append('circle')
		.attr(class: 'female')
		.attr(fill: 'red')
		.attr(r: (d) -> d.fr = calculateRadius(circleScale, d['num_female_eng'], maxRadius))
		.attr(cy: rowHeight/2)
		.attr(opacity: 0.5)
		.attr(cx: (d) -> xF(d['num_female_eng']/d['num_eng']))

	companies.append('line')
		.attr(class: 'female')
		.attr(stroke: 'red')
		.attr(x1: (d) -> xF(d['num_female_eng']/d['num_eng']) + d.fr)
		.attr(x2: width/2)
		.attr(y1: rowHeight/2)
		.attr(y2: rowHeight/2)

	companies.append('text')
)



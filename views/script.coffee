selection = "body"

d3.csv("/data/data.csv", (error, data) ->
	width = 1600
	height = 500
	cleanData = data[1..data.length - 1]
	barWidth = width/(cleanData.length * 2)
	svg = d3.select(selection).append('svg')
		.attr(width: width)
		.attr(height: height)
	maxEng = d3.max(cleanData, (d) -> 
		maleEng = (d['num_eng'] - d['num_female_eng'])
		if maleEng < d['num_female_eng'] then d['num_female_eng'] else maleEng
	)
	x = d3.scale.linear().domain([0, cleanData.length]).range([0, width])
	y = d3.scale.linear().domain([0, maxEng]).range([0, height])

	companies = svg.selectAll('g.company')
		.data(cleanData)
	.enter()
		.append('g').attr(class: 'company')

	companies.append('rect')
		.attr(class: 'male')
		.attr(fill: 'blue')
		.attr(height: (d) -> if (d['num_eng'] - d['num_female_eng']) is 0 then 0 else y(d['num_eng'] - d['num_female_eng']))
		.attr(width: barWidth)
		.attr(y: (d) -> if (d['num_eng'] - d['num_female_eng']) is 0 then height else height - y(d['num_eng'] - d['num_female_eng']))
		.attr(x: (d, i) -> i * barWidth * 2)

	companies.append('rect')
		.attr(class: 'female')
		.attr(fill: 'red')
		.attr(height: (d) -> if d['num_female_eng'] is 0 then 0 else y(d['num_female_eng']))
		.attr(width: barWidth)
		.attr(y: (d) -> if d['num_female_eng'] is 0 then height else height - y(d['num_female_eng']))
		.attr(x: (d, i) -> (i * barWidth * 2) + barWidth)
)



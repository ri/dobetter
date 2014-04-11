selection = "#bubble_graph"
geo = new Geo()

calculateRadius = (scale, value, maxRadius) -> 
  topArea = geo.areaFromRadius(maxRadius)
  ratio = scale(value)
  area = topArea * ratio
  geo.radiusFromArea(area)

class lineBubbles
	constructor: (data, selection) ->
		@cleanData = data[1..data.length - 1]
		@rowHeight = 80
		@offset = 140
		@width = 1000
		@height = @cleanData.length * @rowHeight + @offset
		@maxRadius = 100
		@colours = { male: '#0030ff', female: '#ff00a3' }
		@maxEng = d3.max(@cleanData, (d) -> 
			maleEng = (d['num_eng'] - d['num_female_eng'])
			if maleEng < d['num_female_eng'] then d['num_female_eng'] else maleEng
		)
		@avgFem = d3.mean(@cleanData, (d) -> d['num_female_eng']/d['num_eng'])
		@circleScale = d3.scale.linear().domain([0, @maxEng])
		@xF = d3.scale.linear().domain([0, 1]).range([@width/2, @maxRadius])
		@xM = d3.scale.linear().domain([0, 1]).range([@width/2, @width-@maxRadius])
		@svg = d3.select(selection)			
			.attr(height: @height)
			.attr(width: @width)
		
		@companies = @svg.selectAll('g.company')
			.data(@cleanData)
		.enter()
			.append('g').attr(class: 'company')
			.attr(transform: (d,i) => "translate(0, #{i * @rowHeight + @offset})")
			.on('mouseover', @showNumbers)
			.on('mouseout', @hideNumbers)

		@sort = 'Team size'
		@sortDirection = 'desc'

	draw: () =>
		@svg.append('line')
			.attr(class: 'middle')
			.attr(stroke: '#dddddd')
			.attr(x1: @width/2)
			.attr(x2: @width/2)
			.attr(y1: 60)
			.attr(y2: @height)

		@svg.append('circle')
			.attr(class: 'middle-circle')
			.attr(fill: '#ffffff')
			.attr(r: 5)
			.attr(cx: @width/2)
			.attr(cy: 60)

		@svg.append('text')
			.attr(class: 'avgFem-text')
			.text("Average (#{d3.format('%') @avgFem})")
			.attr('text-anchor': 'middle')
			.attr(x: @xF @avgFem)
			.attr(y: 20)

		@svg.append('text')
			.attr(class: 'avgMale-text')
			.text("Average (#{d3.format('%') 1 - @avgFem})")
			.attr('text-anchor': 'middle')
			.attr(x: @xM 1 - @avgFem)
			.attr(y: 20)

		@svg.append('line')
			.attr(class: 'avg_fem')
			.attr(stroke: @colours['female'])
			.attr('stroke-dasharray': '5,5')
			.attr(opacity: 0.7)
			.attr(x1: @xF @avgFem)
			.attr(x2: @xF @avgFem)
			.attr(y1: 30)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'avg_male')
			.attr(stroke: @colours['male'])
			.attr('stroke-dasharray': '5,5')
			.attr(opacity: 0.7)
			.attr(x1: @xM 1 - @avgFem)
			.attr(x2: @xM 1 - @avgFem)
			.attr(y1: 30)
			.attr(y2: @height)

		@companies.append('text')
			.text((d) -> 
				if d['team'] is not 'N/A'
					"#{d['company']}, #{d['team']}"
				else
					d['company']
				)
			.attr('text-anchor': 'middle')
			.attr(x: @width/2)
			.attr(y: @rowHeight/2 - 3)

		@companies.append('circle')
			.attr(class: 'male')
			.attr(fill: @colours['male'])
			.attr(r: (d) => d.mr = calculateRadius(@circleScale, d['num_eng'] - d['num_female_eng'], @maxRadius))
			.attr(cy: @rowHeight/2)
			.attr(opacity: 0.5)
			.attr(cx: (d) => @xM((d['num_eng'] - d['num_female_eng'])/d['num_eng']))
		
		@companies.append('circle')
			.attr(class: 'maleInner')
			.attr(fill: @colours['male'])
			.attr(r: 2)
			.attr(cy: @rowHeight/2)
			.attr(cx: (d) => @xM((d['num_eng'] - d['num_female_eng'])/d['num_eng']))

		@companies.append('line')
			.attr(class: 'male')
			.attr(stroke: @colours['male'])
			.attr(x1: @width/2)
			.attr(x2: (d) => @xM((d['num_eng'] - d['num_female_eng'])/d['num_eng'])) 
			.attr(y1: @rowHeight/2)
			.attr(y2: @rowHeight/2)

		@companies.append('text')
			.attr(class: 'maleNum')
			.text((d) -> unless d['num_eng'] - d['num_female_eng'] is 0 then d['num_eng'] - d['num_female_eng'])
			.attr('text-anchor': 'middle')
			.attr(y: @rowHeight/2)
			.attr(x: (d) => @xM((d['num_eng'] - d['num_female_eng'])/d['num_eng']))
			.attr(opacity: 0)

		@companies.append('circle')
			.attr(class: 'female')
			.attr(fill: @colours['female'])
			.attr(r: (d) => d.fr = calculateRadius(@circleScale, d['num_female_eng'], @maxRadius))
			.attr(cy: @rowHeight/2)
			.attr(opacity: 0.5)
			.attr(cx: (d) => @xF(d['num_female_eng']/d['num_eng']))
		
		@companies.append('circle')
			.attr(class: 'femaleInner')
			.attr(fill: @colours['female'])
			.attr(r: 2)
			.attr(cy: @rowHeight/2)
			.attr(cx: (d) => @xF(d['num_female_eng']/d['num_eng']))

		@companies.append('line')
			.attr(class: 'female')
			.attr(stroke: @colours['female'])
			.attr(x1: (d) => @xF(d['num_female_eng']/d['num_eng']))
			.attr(x2: @width/2)
			.attr(y1: @rowHeight/2)
			.attr(y2: @rowHeight/2)

		@companies.append('text')
			.attr(class: 'femaleNum')
			.text((d) -> unless d['num_female_eng'] is '0' then d['num_female_eng'] )
			.attr('text-anchor': 'middle')
			.attr(y: @rowHeight/2)
			.attr(x: (d) => @xF(d['num_female_eng']/d['num_eng']))
			.attr(opacity: 0)

	showNumbers: ->
		d3.select(this).selectAll('.femaleNum, .maleNum')
			.transition()
			.attr(opacity: 1)

	hideNumbers: ->
		d3.select(this).selectAll('.femaleNum, .maleNum')
			.transition()
			.attr(opacity: 0)

	reOrder: =>
		@companies.transition().duration(300).attr(transform: (d,i) => "translate(0, #{i * @rowHeight + @offset})")

	sortByTeamSize: (direction = 'desc') =>
		if direction is 'desc'
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.descending(parseInt(a['num_eng']), parseInt(b['num_eng'])))
		else
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.ascending(parseInt(a['num_eng']), parseInt(b['num_eng'])))
		@reOrder()

	sortByGender: (gender = 'female', direction = 'desc') =>
		if direction is 'desc'
			if gender is 'female'
				@companies
					.sort((a,b) -> d3.ascending(a['company'], b['company']))
					.sort((a,b) -> d3.descending(parseInt(a['num_female_eng']), parseInt(b['num_female_eng'])))
			else
				@companies
					.sort((a,b) -> d3.ascending(a['company'], b['company']))
					.sort((a,b) -> d3.descending(parseInt(a['num_eng']) - parseInt(a['num_female_eng']), parseInt(b['num_eng']) - parseInt(b['num_female_eng'])))
		else
			if gender is 'female'
				@companies
					.sort((a,b) -> d3.ascending(a['company'], b['company']))
					.sort((a,b) -> d3.ascending(parseInt(a['num_female_eng']), parseInt(b['num_female_eng'])))
			else
				@companies
					.sort((a,b) -> d3.ascending(a['company'], b['company']))
					.sort((a,b) -> d3.ascending(parseInt(a['num_eng']) - parseInt(a['num_female_eng']), parseInt(b['num_eng']) - parseInt(b['num_female_eng'])))		
		@reOrder()

	sortByRatio: (direction = 'desc') =>
		if direction is 'desc'
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.ascending(parseInt(a['num_female_eng']), parseInt(b['num_female_eng'])))
				.sort((a,b) -> d3.descending(parseInt(a['num_female_eng']) / parseInt(a['num_eng']), parseInt(b['num_female_eng']) / parseInt(b['num_eng'])))
		else
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.descending(parseInt(a['num_eng']) - parseInt(a['num_female_eng']), parseInt(b['num_eng']) - parseInt(b['num_female_eng'])))
				.sort((a,b) -> d3.descending((parseInt(a['num_eng']) - parseInt(a['num_female_eng'])) / parseInt(a['num_eng']), (parseInt(b['num_eng']) - parseInt(b['num_female_eng'])) / parseInt(b['num_eng'])))
		@reOrder()

	sortByMostEqual: (direction = 'desc') =>
		if direction is 'desc'
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.ascending(Math.abs(0.5 - parseInt(a['num_female_eng']) / parseInt(a['num_eng'])), Math.abs(0.5 - parseInt(b['num_female_eng']) / parseInt(b['num_eng']))))
		else
			@companies
				.sort((a,b) -> d3.ascending(a['company'], b['company']))
				.sort((a,b) -> d3.descending(Math.abs(0.5 - parseInt(a['num_female_eng']) / parseInt(a['num_eng'])), Math.abs(0.5 - parseInt(b['num_female_eng']) / parseInt(b['num_eng']))))
		@reOrder()

	filter: (filter) =>
		switch filter
			when 'all women' then
			when 'all men'	 then
			when '< 25% women'then
			when '< 10% women' then

d3.csv("data/data.csv", (error, data) ->

	console.log data
	chart = new lineBubbles(data, selection)
	chart.draw()	
	d3.select('#teamSize').on('click', () -> chart.sortByTeamSize('desc'))
	d3.select('#femaleSort').on('click', () -> chart.sortByGender('female'))
	d3.select('#maleSort').on('click', () -> chart.sortByGender('male'))
	d3.select('#ratioSort').on('click', () -> chart.sortByRatio('asc'))
	d3.select('#equalSort').on('click', () -> chart.sortByMostEqual('desc'))
)


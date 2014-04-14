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
			.sort((a,b) -> d3.ascending(a['company'], b['company']))
			.sort((a,b) -> d3.descending(parseInt(a['num_eng']), parseInt(b['num_eng'])))
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
			.attr(class: 'all_fem')
			.attr(stroke: '#ffffff')
			.attr(opacity: 0.1)
			.attr(x1: @maxRadius)
			.attr(x2: @maxRadius)
			.attr(y1: 60)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'half_fem')
			.attr(stroke: '#ffffff')
			.attr(opacity: 0.1)
			.attr(x1: @width/4 + @maxRadius/2)
			.attr(x2: @width/4 + @maxRadius/2)
			.attr(y1: 60)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'all_male')
			.attr(stroke: '#ffffff')
			.attr(opacity: 0.1)
			.attr(x1: @width - @maxRadius)
			.attr(x2: @width - @maxRadius)
			.attr(y1: 60)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'half_male')
			.attr(stroke: '#ffffff')
			.attr(opacity: 0.1)
			.attr(x1: @width/4 * 3 - @maxRadius/2)
			.attr(x2: @width/4 * 3 - @maxRadius/2)
			.attr(y1: 60)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'avg_fem')
			.attr(stroke: '#cc66a7')
			.attr('stroke-dasharray': '5,5')
			.attr(x1: @xF @avgFem)
			.attr(x2: @xF @avgFem)
			.attr(y1: 30)
			.attr(y2: @height)

		@svg.append('line')
			.attr(class: 'avg_male')
			.attr(stroke: '#6679cc')
			.attr('stroke-dasharray': '5,5')
			.attr(opacity: 0.7)
			.attr(x1: @xM 1 - @avgFem)
			.attr(x2: @xM 1 - @avgFem)
			.attr(y1: 30)
			.attr(y2: @height)

		@companies.append('text')
			.text((d) -> 
				if !(d['team'] is undefined)
					"#{d['company']}, #{d['team']}"
				else
					d['company']
				)
			.attr('text-anchor': 'middle')
			.attr(x: @width/2)
			.attr(y: @rowHeight/2 - 5)

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

d3.json("/data.json", (error, data) ->

	data = d3.values data
	chart = new lineBubbles(data, selection)
	chart.draw()	
	d3.select('#teamSize').on('click', () -> dir = reverse(d3.select(this).node().nextSibling); chart.sortByTeamSize(dir); activate(this);)
	d3.select('#teamSize + .reverse').on('click', () -> 
		dir = reverse(this)
		chart.sortByTeamSize(dir)
	)
	d3.select('#femaleSort').on('click', () -> dir = reverse(d3.select(this).node().nextSibling); chart.sortByGender('female', dir); activate(this))
	d3.select('#femaleSort + .reverse').on('click', () -> 
		dir = reverse(this)
		chart.sortByGender('female', dir)
	)	
	d3.select('#maleSort').on('click', () -> dir = reverse(d3.select(this).node().nextSibling); chart.sortByGender('male', dir); activate(this))
	d3.select('#maleSort + .reverse').on('click', () -> 
		dir = reverse(this)
		chart.sortByGender('male', dir)
	)	
	d3.select('#ratioSort').on('click', () -> dir = reverse(d3.select(this).node().nextSibling); chart.sortByRatio(dir); activate(this))
	d3.select('#ratioSort + .reverse').on('click', () -> 
		dir = reverse(this)
		chart.sortByRatio(dir)
	)	
	d3.select('#equalSort').on('click', () -> dir = reverse(d3.select(this).node().nextSibling); chart.sortByMostEqual(dir); activate(this))
	d3.select('#equalSort + .reverse').on('click', () -> 
		dir = reverse(element)
		chart.sortByMostEqual(dir)
	)	
)

activate = (element) ->
	parent = d3.select(element).node().parentNode
	d3.selectAll('#sort span').classed('active', false)
	d3.select(parent).classed('active', true)

reverse = (element) ->
	dir = 'desc'
	el = d3.select(element)
	elDir = el.classed('desc')
	d3.selectAll('.reverse').classed('desc', false).classed('asc', true)
	if elDir is true
		dir = 'asc'
		el.classed('asc', true)
		el.classed('desc', false)
	else
		el.classed('asc', false)
		el.classed('desc', true)
	dir
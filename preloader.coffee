class Framer.Preloader
	constructor: () ->
		@imagesToLoad = []

		for layer in Framer.CurrentContext._layerList
			if layer.image
				@imagesToLoad.push(layer.image)

		@imagesTotalCount = @imagesToLoad.length
		@imagesLoadedCount = 0	
		
		@loadingLayer = new Layer
		@loadingLayer.backgroundColor = '#222'

		@loadingLayer.superLayer = Framer.Device.screen
		@loadingLayer.frame = Framer.Device.viewport.frame
		@loadingLayer.bringToFront()

		@loadingText = new Layer x: 100, y: 130, width: 400, height: 100, backgroundColor: 'transparent'
		@loadingText.style = 
			font: '100 48px Helvetica'
			color: '#999'
		@loadingText.html = "Hang tight"
		@loadingText.superLayer = @loadingLayer
		
		@loadingText.animation1 = @loadingText.animate
			properties: x: 400
			curve: 'linear'
			time: 20
		@loadingText.animation2 = @loadingText.animation1.reverse()
		@loadingText.animation1.on 'end', => @loadingText.animation2.start()
		@loadingText.animation2.on 'end', => @loadingText.animation1.start()
		
		@loadingBar = new Layer x: 100, y: 200, width: 10, height: 2, backgroundColor: 'white'
		@loadingBar.superLayer = @loadingLayer
		

		# Wait a little, otherwise we hold up the page and nothing shows as the images load.
		Utils.delay 0.1, =>
			@imagesToLoad.forEach (image) =>
				loader = new Image()
				loader.name = image
				loader.src = image
				loader.onload = =>
					@imagesLoadedCount++
					
		@loadingInterval = setInterval =>
			if @imagesLoadedCount >= @imagesTotalCount
				@loadingLayer.animation1 = @loadingLayer.animate
					properties: opacity: 0
					curve: 'bezier-curve'
					time: 0.2
				@loadingLayer.animation1.on 'end', =>
					@loadingLayer.visible = false
				clearInterval @loadingInterval
			else
				@loadingBar.animate
					properties:
						width: Utils.modulate @imagesLoadedCount, [0, @imagesTotalCount], [0, 550]
					curve: 'bezier-curve'
					time: 0.1
		, 200	
class Framer.Preloader
	constructor: () ->
		@imagesToLoad = []

		for layer in Framer.CurrentContext._layerList
			if layer.image
				@imagesToLoad.push(layer)

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
		

		@tempLayer = new Layer x: 0, y: 0, width: 750, height: 1334, backgroundColor: 'transparent'
		@tempLayer.superLayer = @loadingLayer
		@tempLayer.sendToBack()
		# Wait a little, otherwise we hold up the page and nothing shows as the images load.
		Utils.delay 0.5, =>
			@imagesToLoad.forEach (layer, k) =>

				# Remember its original place
				layer.original =
					superLayer: layer.superLayer
					frame: layer.frame
					opacity: layer.opacity
					visible: layer.visible
					index: layer.index
					scale: layer.scale

				# Show it on screen
				layer.superLayer = @tempLayer
				layer.scale = 1 / Math.max(layer.height/1334, 1)
				layer.center()
				layer.opacity = 0.1
				layer.visible = true
				
				loader = new Image()
				loader.name = layer.image
				loader.src =  layer.image

				loader.onload = =>
					layer.superLayer = layer.original.superLayer
					layer.frame = layer.original.frame
					layer.opacity = layer.original.opacity
					layer.visible = layer.original.visible
					layer.index = layer.original.index
					layer.scale = layer.original.scale
					console.log("Preloader: OK " + layer.image)
					@imagesLoadedCount++

				# TODO: Refactor
				loader.onerror = =>
					layer.superLayer = layer.original.superLayer
					layer.frame = layer.original.frame
					layer.opacity = layer.original.opacity
					layer.visible = layer.original.visible
					layer.index = layer.original.index
					layer.scale = layer.original.scale
					console.log("Preloader: Err " + layer.image)
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
